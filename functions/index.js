// functions/index.js
//
// Cloud Function de Allin Kawsay adaptada para MERCADO PAGO.
//
// Responsabilidades:
//   1. webhookMercadoPago → recibe avisos de pago y activa planes.
//   2. sincronizarComunidad → mantiene la colección `comunidad` al día.
//   3. recalcularMetaDonacion → suma donaciones verificadas a la meta.

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { MercadoPagoConfig, Payment } = require("mercadopago");

admin.initializeApp();
const db = admin.firestore();

// ═══════════════════════════════════════════════════════════
// CONFIGURACIÓN
// ═══════════════════════════════════════════════════════════

// Se configuran con:
//   firebase functions:config:set mp.access_token="APP_USR-..."
const DURACION = {
  sikurito: 30,
  vip: 99999,
};

const META_DONACION_CENTIMOS = 32000; // S/ 320.00

// ═══════════════════════════════════════════════════════════
// WEBHOOK DE MERCADO PAGO
// ═══════════════════════════════════════════════════════════

exports.webhookMercadoPago = functions
  .region("us-central1")
  .https.onRequest(async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const body = req.body || {};
      const tipo = body.type || body.topic;
      const paymentId = body.data?.id || body.id;

      functions.logger.info("Webhook MP recibido:", { tipo, paymentId });

      // Mercado Pago envía avisos de muchos tipos. Solo nos interesan los pagos.
      if (tipo !== "payment" || !paymentId) {
        res.status(200).send({ ok: true, ignorado: true });
        return;
      }

      // ═══════════════════════════════════════════════════════
      // VERIFICACIÓN CONTRA LA API DE MERCADO PAGO
      // ═══════════════════════════════════════════════════════
      const accessToken = functions.config().mp?.access_token;
      if (!accessToken) {
        functions.logger.error("Falta mp.access_token en la configuración.");
        res.status(500).send({ error: "Sin configuración" });
        return;
      }

      const client = new MercadoPagoConfig({ accessToken });
      const payment = new Payment(client);

      let pago;
      try {
        pago = await payment.get({ id: paymentId });
      } catch (e) {
        functions.logger.error("Error consultando pago MP:", e);
        res.status(400).send({ error: "Pago no verificado" });
        return;
      }

      // Verificar que el pago esté aprobado.
      if (pago.status !== "approved") {
        functions.logger.warn("Pago no aprobado:", pago.status);
        res.status(200).send({ ok: true, ignorado: true });
        return;
      }

      // ═══════════════════════════════════════════════════════
      // EXTRAER DATOS DEL PAGO
      // ═══════════════════════════════════════════════════════
      const montoCentimos = Math.round((pago.transaction_amount || 0) * 100);
      const email = pago.payer?.email || "";
      const metadata = pago.metadata || {};
      
      // Si el link de pago no tiene metadata, inferimos por el monto.
      const tipoCompra = metadata.tipo || inferirTipoPorMonto(montoCentimos);

      functions.logger.info("Pago MP verificado:", {
        montoCentimos,
        email,
        tipoCompra,
        status: pago.status,
      });

      // Registrar log de auditoría
      await db.collection("pagos_log").add({
        mpPaymentId: paymentId.toString(),
        montoCentimos,
        email,
        tipoCompra,
        metadata,
        pagoCompleto: pago,
        fecha: admin.firestore.FieldValue.serverTimestamp(),
      });

      // ═══════════════════════════════════════════════════════
      // RUTEO SEGÚN EL TIPO DE COMPRA
      // ═══════════════════════════════════════════════════════

      if (tipoCompra === "sikurito" || tipoCompra === "vip") {
        await activarPlan(email, tipoCompra, pago);
      } else if (tipoCompra === "cafe" || tipoCompra === "apoyo") {
        await registrarDonacion(email, tipoCompra, montoCentimos, paymentId);
      } else {
        functions.logger.warn("Tipo desconocido:", tipoCompra);
      }

      res.status(200).send({ ok: true });
    } catch (err) {
      functions.logger.error("Error webhook MP:", err);
      res.status(500).send({ error: "Error interno" });
    }
  });

// ═══════════════════════════════════════════════════════════
// ACTIVAR PLAN
// ═══════════════════════════════════════════════════════════

async function activarPlan(email, tipo, pago) {
  if (!email) {
    functions.logger.warn("Pago sin email, no se puede activar:", pago.id);
    return;
  }

  // Buscar usuario por email
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
    "suscripcion.aprobadaPor": "mercadopago_webhook",
    "suscripcion.fechaActivacion": admin.firestore.FieldValue.serverTimestamp(),
    "suscripcion.ultimoCheck": admin.firestore.FieldValue.serverTimestamp(),
    "suscripcion.ultimoPagoId": pago.id.toString(),
    "suscripcion.ultimoMontoCentimos": Math.round((pago.transaction_amount || 0) * 100),
  });

  functions.logger.info("Plan activado:", { email, tipo, hasta });
}

// ═══════════════════════════════════════════════════════════
// REGISTRAR DONACIÓN
// ═══════════════════════════════════════════════════════════

async function registrarDonacion(email, tipo, montoCentimos, paymentId) {
  await db.collection("donaciones").add({
    email: email || "anonimo",
    tipo,
    montoCentimos,
    mpPaymentId: paymentId.toString(),
    verificada: true,
    fecha: admin.firestore.FieldValue.serverTimestamp(),
  });

  functions.logger.info("Donación registrada:", { email, tipo, montoCentimos });
}

// ═══════════════════════════════════════════════════════════
// INFERIR TIPO POR MONTO
// ═══════════════════════════════════════════════════════════

function inferirTipoPorMonto(montoCentimos) {
  if (montoCentimos === 2700) return "sikurito";
  if (montoCentimos === 8650) return "vip";
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
    const after = change.after.data();
    if (!after || after.verificada !== true) return;

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
  });

// ═══════════════════════════════════════════════════════════
// TRIGGER: SINCRONIZAR COMUNIDAD
// ═══════════════════════════════════════════════════════════

exports.sincronizarComunidad = functions
  .region("us-central1")
  .firestore.document("usuarios/{uid}")
  .onWrite(async (change, context) => {
    const uid = context.params.uid;
    const after = change.after.data();

    if (!after) {
      await db.collection("comunidad").doc(uid).delete().catch(() => {});
      return;
    }

    const sus = after.suscripcion || {};
    const plan = sus.plan || "ninguno";
    const activa = sus.activa === true;
    const hasta = sus.hasta && sus.hasta.toDate ? sus.hasta.toDate() : null;
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