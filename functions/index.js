// functions/index.js
//
// Cloud Function de Allin Kawsay.
//
// Responsabilidades:
//   1. webhookCulqi       → recibe pagos confirmados y activa planes.
//   2. sincronizarComunidad → mantiene la colección `comunidad` al día.
//   3. recalcularMetaDonacion → suma donaciones verificadas a la meta.
//
// Deploy:
//   firebase deploy --only functions
//
// Logs en vivo:
//   firebase functions:log

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();
const db = admin.firestore();

// ═══════════════════════════════════════════════════════════
// CONFIGURACIÓN
// ═══════════════════════════════════════════════════════════

// Se configuran con:
//   firebase functions:config:set culqi.secret="sk_live_..." culqi.public="pk_live_..."
//
// En el código se leen con functions.config().culqi.secret
// Si prefieres variables de entorno modernas, se cambia a process.env.CULQI_SECRET
const CULQI_API = "https://api.culqi.com/v2";

// Duración de cada plan en días.
const DURACION = {
  sikurito: 30,
  vip: 99999, // ~273 años = "para siempre"
};

// Metas y montos.
const META_DONACION_CENTIMOS = 32000; // S/ 320.00

// ═══════════════════════════════════════════════════════════
// WEBHOOK DE CULQI
// ═══════════════════════════════════════════════════════════

/**
 * Endpoint que Culqi llama cuando un pago se confirma.
 *
 * Configurarlo en el panel de Culqi → Webhooks con la URL:
 *   https://<region>-<project>.cloudfunctions.net/webhookCulqi
 *
 * Culqi envía un JSON con la forma:
 *   { "type": "charge.creation.succeeded", "data": { "id": "chr_xxx", ... } }
 */
exports.webhookCulqi = functions
  .region("us-central1")
  .https.onRequest(async (req, res) => {
    // Solo POST.
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const evento = req.body || {};
      const tipo = evento.type || "";
      const chargeId = evento.data && evento.data.id;

      functions.logger.info("Webhook recibido:", {
        tipo,
        chargeId,
      });

      // Solo nos interesan los cobros exitosos.
      if (!tipo.startsWith("charge.creation") || tipo.includes("failed")) {
        res.status(200).send({ ok: true, ignorado: true });
        return;
      }

      if (!chargeId) {
        res.status(400).send({ error: "Sin chargeId" });
        return;
      }

      // ═══════════════════════════════════════════════════════
      // VERIFICACIÓN CONTRA LA API REAL DE CULQI
      // ═══════════════════════════════════════════════════════
      // No confiamos solo en el webhook: un atacante podría
      // enviar un POST falso. Consultamos a Culqi para confirmar
      // que el cobro existe y está aprobado.
      const secretKey = functions.config().culqi?.secret;
      if (!secretKey) {
        functions.logger.error("Falta culqi.secret en la configuración.");
        res.status(500).send({ error: "Sin configuración" });
        return;
      }

      const verifyRes = await fetch(`${CULQI_API}/charges/${chargeId}`, {
        method: "GET",
        headers: {
          Authorization: `Bearer ${secretKey}`,
          "Content-Type": "application/json",
        },
      });

      if (!verifyRes.ok) {
        functions.logger.error("Culqi no confirma el cargo:", verifyRes.status);
        res.status(400).send({ error: "Cargo no verificado" });
        return;
      }

      const cargo = await verifyRes.json();

      // Verificar que el cargo está aprobado (outcome.type === 'venta_exitosa').
      const outcome = cargo.outcome && cargo.outcome.type;
      if (outcome !== "venta_exitosa" && cargo.outcome !== undefined) {
        functions.logger.warn("Cargo no exitoso:", outcome);
        res.status(200).send({ ok: true, ignorado: true });
        return;
      }

      const montoCentimos = cargo.amount || 0;
      const email = (cargo.source && cargo.source.email) || "";
      const metadata = cargo.metadata || {};
      const tipoCompra = metadata.tipo || inferirTipoPorMonto(montoCentimos);

      functions.logger.info("Cargo verificado:", {
        montoCentimos,
        email,
        tipoCompra,
      });

      // ═══════════════════════════════════════════════════════
      // REGISTRAR LOG DE AUDITORÍA
      // ═══════════════════════════════════════════════════════
      await db.collection("pagos_log").add({
        chargeId,
        montoCentimos,
        email,
        tipoCompra,
        metadata,
        cargoCompleto: cargo,
        fecha: admin.firestore.FieldValue.serverTimestamp(),
      });

      // ═══════════════════════════════════════════════════════
      // RUTEO SEGÚN EL TIPO DE COMPRA
      // ═══════════════════════════════════════════════════════

      if (tipoCompra === "sikurito" || tipoCompra === "vip") {
        await activarPlan(email, tipoCompra, cargo);
      } else if (tipoCompra === "cafe" || tipoCompra === "apoyo") {
        await registrarDonacion(email, tipoCompra, montoCentimos, chargeId);
      } else {
        functions.logger.warn("Tipo desconocido:", tipoCompra);
      }

      res.status(200).send({ ok: true });
    } catch (err) {
      functions.logger.error("Error webhook:", err);
      res.status(500).send({ error: "Error interno" });
    }
  });

// ═══════════════════════════════════════════════════════════
// ACTIVAR PLAN
// ═══════════════════════════════════════════════════════════

async function activarPlan(email, tipo, cargo) {
  if (!email) {
    functions.logger.warn("Cargo sin email, no se puede activar:", cargo.id);
    return;
  }

  // Buscamos el usuario por email.
  const usuariosSnap = await db
    .collection("usuarios")
    .where("email", "==", email)
    .limit(1)
    .get();

  if (usuariosSnap.empty) {
    functions.logger.warn("No existe usuario con email:", email);
    return;
  }

  const userDoc = usuariosSnap.docs[0];
  const duracion = DURACION[tipo] || 30;
  const hasta = new Date();
  hasta.setDate(hasta.getDate() + duracion);

  await userDoc.ref.update({
    "suscripcion.plan": tipo,
    "suscripcion.activa": true,
    "suscripcion.hasta": admin.firestore.Timestamp.fromDate(hasta),
    "suscripcion.aprobadaPor": "culqi_webhook",
    "suscripcion.fechaActivacion":
      admin.firestore.FieldValue.serverTimestamp(),
    "suscripcion.ultimoCheck":
      admin.firestore.FieldValue.serverTimestamp(),
    "suscripcion.ultimoChargeId": cargo.id,
    "suscripcion.ultimoMontoCentimos": cargo.amount || 0,
  });

  functions.logger.info("Plan activado:", { email, tipo, hasta });
}

// ═══════════════════════════════════════════════════════════
// REGISTRAR DONACIÓN
// ═══════════════════════════════════════════════════════════

async function registrarDonacion(email, tipo, montoCentimos, chargeId) {
  // Crear el documento de donación verificado.
  await db.collection("donaciones").add({
    email: email || "anonimo",
    tipo,
    montoCentimos,
    culqiChargeId: chargeId,
    verificada: true,
    fecha: admin.firestore.FieldValue.serverTimestamp(),
  });

  functions.logger.info("Donación registrada:", {
    email,
    tipo,
    montoCentimos,
  });

  // Actualizar la meta de recaudación (el trigger onWrite lo hace).
}

// ═══════════════════════════════════════════════════════════
// INFERIR TIPO POR MONTO (fallback si no viene metadata)
// ═══════════════════════════════════════════════════════════

function inferirTipoPorMonto(montoCentimos) {
  // 2700 → sikurito, 8650 → vip.
  if (montoCentimos === 2700) return "sikurito";
  if (montoCentimos === 8650) return "vip";
  // Si viene entre 1250 y 2000 → café; mayor → apoyo.
  if (montoCentimos >= 1250 && montoCentimos < 3000) return "cafe";
  return "apoyo";
}

// ═══════════════════════════════════════════════════════════
// TRIGGER: RECALCULAR META AL ENTRAR DONACIÓN
// ═══════════════════════════════════════════════════════════

exports.recalcularMetaDonacion = functions
  .region("us-central1")
  .firestore.document("donaciones/{docId}")
  .onWrite(async (change, context) => {
    // Solo procesar si la donación está verificada.
    const after = change.after.data();
    if (!after || after.verificada !== true) return;

    // Sumar todas las donaciones verificadas.
    const snap = await db
      .collection("donaciones")
      .where("verificada", "==", true)
      .get();

    let total = 0;
    snap.forEach((doc) => {
      total += doc.data().montoCentimos || 0;
    });

    await db.collection("config").doc("meta_donacion").set(
      {
        meta: META_DONACION_CENTIMOS,
        recaudado: total,
        actualizadoEn: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    functions.logger.info("Meta actualizada:", total);
  });

// ═══════════════════════════════════════════════════════════
// TRIGGER: SINCRONIZAR COMUNIDAD
// ═══════════════════════════════════════════════════════════

/**
 * Cada vez que un usuario cambia (rol, suscripción, baneado, nombre),
 * sincroniza su documento público en la colección `comunidad`.
 */
exports.sincronizarComunidad = functions
  .region("us-central1")
  .firestore.document("usuarios/{uid}")
  .onWrite(async (change, context) => {
    const uid = context.params.uid;
    const after = change.after.data();

    // Si el doc se borró → borrar de comunidad.
    if (!after) {
      await db.collection("comunidad").doc(uid).delete().catch(() => {});
      return;
    }

    const sus = after.suscripcion || {};
    const plan = sus.plan || "ninguno";
    const activa = sus.activa === true;
    const hasta = sus.hasta && sus.hasta.toDate
      ? sus.hasta.toDate()
      : null;
    const vigente = activa && hasta && hasta > new Date();

    const esSuscriptor = vigente && plan === "sikurito";
    const esVip = vigente && plan === "vip";

    await db.collection("comunidad").doc(uid).set(
      {
        nombre: after.nombre || "Usuario",
        rol: after.rol || "publico",
        esSuscriptor,
        esVip,
        baneado: after.baneado === true,
        actualizadoEn: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  });