// lib/features/suscripcion/services/paywall_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/estado_suscripcion.dart';
import '../models/plan_suscripcion.dart';

/// Servicio central de monetización.
///
/// Responsabilidades:
///   - Evaluar el estado de un usuario (rol + plan + trial).
///   - Iniciar el trial la primera vez con hora del servidor.
///   - Protegerse contra cambio de hora del dispositivo (3 relojes).
///   - Exponer un stream reactivo para la UI.
///   - Permitir a la Cloud Function activar/cancelar suscripciones.
///
/// IMPORTANTE — SEGURIDAD:
/// Las reglas de Firestore deben impedir que el propio usuario
/// escriba el campo `suscripcion`. Solo la Cloud Function (admin)
/// puede hacerlo. Ver documento de reglas.
class PaywallService {
  static final _db = FirebaseFirestore.instance;

  static const String _keyUltimoCheckMs = 'paywall_ultimo_check_ms';
  static const String _keyTrialFinMs = 'paywall_trial_fin_ms';

  // ═══════════════════════════════════════════════════════════
  // EVALUACIÓN PRINCIPAL
  // ═══════════════════════════════════════════════════════════

  /// Evalúa el estado completo del usuario. Debe llamarse al abrir
  /// la app y cuando se sospeche un cambio (login, vuelta del background).
  static Future<EstadoSuscripcion> evaluar(String uid) async {
    if (uid.isEmpty) return EstadoSuscripcion.cargando0;

    try {
      final doc = await _db.collection('usuarios').doc(uid).get();
      if (!doc.exists) return EstadoSuscripcion.inicial;

      final data = doc.data() ?? {};
      final rol = (data['rol'] ?? 'publico').toString();

      // Roles privilegiados: no les aplica trial ni paywall
      if (rol == 'miembro' || rol == 'admin' || rol == 'dev') {
        return EstadoSuscripcion(
          estado: EstadoTrial.privilegiado,
          rol: rol,
          plan: 'privilegiado',
          activa: true,
        );
      }

      final sus = data['suscripcion'] as Map<String, dynamic>?;

      // Sin suscripción creada: iniciar trial ahora
      if (sus == null) {
        return _iniciarTrial(uid);
      }

      // ¿Tiene plan pagado vigente?
      final plan = (sus['plan'] ?? 'ninguno').toString();
      final activa = sus['activa'] == true;
      final hasta = (sus['hasta'] as Timestamp?)?.toDate();
      final ahora = DateTime.now();

      if (activa &&
          hasta != null &&
          hasta.isAfter(ahora) &&
          plan != 'ninguno' &&
          plan != 'trial') {
        final esVip = plan == 'vip';
        return EstadoSuscripcion(
          estado: esVip ? EstadoTrial.vip : EstadoTrial.suscriptor,
          suscripcionHasta: hasta,
          plan: plan,
          activa: true,
          rol: rol,
        );
      }

      // Trial
      final trialInicio = (sus['trialInicio'] as Timestamp?)?.toDate();
      final trialFin = (sus['trialFin'] as Timestamp?)?.toDate();

      if (trialInicio == null || trialFin == null) {
        return _iniciarTrial(uid);
      }

      // ─── PROTECCIÓN CONTRA CAMBIO DE HORA ───
      // 1. Actualizamos ultimoCheck con hora del servidor.
      await _db.collection('usuarios').doc(uid).update({
        'suscripcion.ultimoCheck': FieldValue.serverTimestamp(),
      });

      // 2. Releemos para obtener el serverTimestamp real.
      final checkDoc = await _db.collection('usuarios').doc(uid).get();
      final ultimoCheckServer =
          (checkDoc.data()?['suscripcion']?['ultimoCheck'] as Timestamp?)
              ?.toDate();

      // 3. Guardamos en caché local por si no hay red en el futuro.
      if (ultimoCheckServer != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
          _keyUltimoCheckMs,
          ultimoCheckServer.millisecondsSinceEpoch,
        );
        await prefs.setInt(
          _keyTrialFinMs,
          trialFin.millisecondsSinceEpoch,
        );
      }

      // 4. La "hora real" es la mayor entre servidor, caché local y dispositivo.
      //    Nadie puede retroceder el tiempo para estirar el trial.
      final prefs = await SharedPreferences.getInstance();
      final ultimoCheckLocalMs = prefs.getInt(_keyUltimoCheckMs);
      final ultimoCheckLocal = ultimoCheckLocalMs != null
          ? DateTime.fromMillisecondsSinceEpoch(ultimoCheckLocalMs)
          : null;

      final candidatos = <DateTime>[
        ahora,
        if (ultimoCheckServer != null) ultimoCheckServer,
        if (ultimoCheckLocal != null) ultimoCheckLocal,
      ];
      final horaReal = candidatos.reduce(
        (a, b) => a.isAfter(b) ? a : b,
      );

      // 5. Comparar con trialFin.
      if (horaReal.isAfter(trialFin) ||
          horaReal.isAtSameMomentAs(trialFin)) {
        return EstadoSuscripcion(
          estado: EstadoTrial.trialExpirado,
          trialInicio: trialInicio,
          trialFin: trialFin,
          plan: 'trial',
          rol: rol,
        );
      }

      final restante = trialFin.difference(horaReal);
      final dias = restante.inDays;
      return EstadoSuscripcion(
        estado: EstadoTrial.trialActivo,
        diasRestantes: dias < 0 ? 0 : dias,
        trialInicio: trialInicio,
        trialFin: trialFin,
        plan: 'trial',
        activa: true,
        rol: rol,
      );
    } catch (e) {
      debugPrint('⚠️ PaywallService.evaluar error: $e');
      // Fallback: si hay error de red, usar caché.
      return _evaluarDesdeCache(uid);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // INICIALIZACIÓN DEL TRIAL
  // ═══════════════════════════════════════════════════════════

  static Future<EstadoSuscripcion> _iniciarTrial(String uid) async {
    try {
      final ahora = DateTime.now();
      final fin = ahora.add(
        const Duration(days: PlanSuscripcion.diasTrial),
      );

      await _db.collection('usuarios').doc(uid).update({
        'suscripcion': {
          'trialInicio': FieldValue.serverTimestamp(),
          'trialFin': Timestamp.fromDate(fin),
          'ultimoCheck': FieldValue.serverTimestamp(),
          'plan': 'trial',
          'activa': true,
          'hasta': Timestamp.fromDate(fin),
        },
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _keyUltimoCheckMs,
        ahora.millisecondsSinceEpoch,
      );
      await prefs.setInt(
        _keyTrialFinMs,
        fin.millisecondsSinceEpoch,
      );

      final doc = await _db.collection('usuarios').doc(uid).get();
      final rol = (doc.data()?['rol'] ?? 'publico').toString();

      return EstadoSuscripcion(
        estado: EstadoTrial.trialActivo,
        diasRestantes: PlanSuscripcion.diasTrial,
        trialInicio: ahora,
        trialFin: fin,
        plan: 'trial',
        activa: true,
        rol: rol,
      );
    } catch (e) {
      debugPrint('⚠️ PaywallService._iniciarTrial error: $e');
      return EstadoSuscripcion.cargando0;
    }
  }
  // ═══════════════════════════════════════════════════════════
  // FALLBACK SIN RED
  // ═══════════════════════════════════════════════════════════

  /// Si Firestore falla (sin red), usamos los datos del último
  /// check guardado en caché. Nunca desbloquea a alguien que ya venció.
  static Future<EstadoSuscripcion> _evaluarDesdeCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trialFinMs = prefs.getInt(_keyTrialFinMs);
      final ultimoCheckMs = prefs.getInt(_keyUltimoCheckMs);

      if (trialFinMs == null || ultimoCheckMs == null) {
        return EstadoSuscripcion.cargando0;
      }

      final trialFin =
          DateTime.fromMillisecondsSinceEpoch(trialFinMs);
      final ultimoCheck =
          DateTime.fromMillisecondsSinceEpoch(ultimoCheckMs);
      final ahora = DateTime.now();

      // La "hora real" es la mayor entre ahora y el último check.
      final horaReal =
          ahora.isAfter(ultimoCheck) ? ahora : ultimoCheck;

      if (horaReal.isAfter(trialFin)) {
        return const EstadoSuscripcion(
          estado: EstadoTrial.trialExpirado,
          plan: 'trial',
        );
      }

      return EstadoSuscripcion(
        estado: EstadoTrial.trialActivo,
        diasRestantes: trialFin.difference(horaReal).inDays,
        trialFin: trialFin,
        plan: 'trial',
        activa: true,
      );
    } catch (_) {
      return EstadoSuscripcion.cargando0;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // VERSIÓN LIVIANA (sin escrituras)
  // ═══════════════════════════════════════════════════════════

  /// Igual que `evaluar` pero NO actualiza `ultimoCheck` en Firestore.
  /// Sirve para pantallas que solo quieren mostrar el estado sin
  /// gastar una escritura. Ejemplo: la pantalla de perfil.
  ///
  /// OJO: no es tan seguro como `evaluar` porque no refresca la
  /// hora del servidor. Para el gate principal de la app, usar `evaluar`.
  static Future<EstadoSuscripcion> evaluarSinActualizar(String uid) async {
    if (uid.isEmpty) return EstadoSuscripcion.cargando0;

    try {
      final doc = await _db.collection('usuarios').doc(uid).get();
      if (!doc.exists) return EstadoSuscripcion.inicial;

      final data = doc.data() ?? {};
      final rol = (data['rol'] ?? 'publico').toString();

      if (rol == 'miembro' || rol == 'admin' || rol == 'dev') {
        return EstadoSuscripcion(
          estado: EstadoTrial.privilegiado,
          rol: rol,
          plan: 'privilegiado',
          activa: true,
        );
      }

      final sus = data['suscripcion'] as Map<String, dynamic>?;
      if (sus == null) {
        return EstadoSuscripcion.inicial.copyWith(rol: rol);
      }

      final plan = (sus['plan'] ?? 'ninguno').toString();
      final activa = sus['activa'] == true;
      final hasta = (sus['hasta'] as Timestamp?)?.toDate();
      final ahora = DateTime.now();

      if (activa &&
          hasta != null &&
          hasta.isAfter(ahora) &&
          plan != 'ninguno' &&
          plan != 'trial') {
        final esVip = plan == 'vip';
        return EstadoSuscripcion(
          estado: esVip ? EstadoTrial.vip : EstadoTrial.suscriptor,
          suscripcionHasta: hasta,
          plan: plan,
          activa: true,
          rol: rol,
        );
      }

      final trialFin = (sus['trialFin'] as Timestamp?)?.toDate();
      final trialInicio = (sus['trialInicio'] as Timestamp?)?.toDate();
      if (trialFin == null) {
        return EstadoSuscripcion.inicial.copyWith(rol: rol);
      }

      // Para no escribir, usamos solo la hora del dispositivo
      // Y el cached local.
      final prefs = await SharedPreferences.getInstance();
      final ultimoCheckMs = prefs.getInt(_keyUltimoCheckMs);
      final ultimoCheckLocal = ultimoCheckMs != null
          ? DateTime.fromMillisecondsSinceEpoch(ultimoCheckMs)
          : null;

      final horaReal = (ultimoCheckLocal != null &&
              ultimoCheckLocal.isAfter(ahora))
          ? ultimoCheckLocal
          : ahora;

      if (horaReal.isAfter(trialFin)) {
        return EstadoSuscripcion(
          estado: EstadoTrial.trialExpirado,
          trialInicio: trialInicio,
          trialFin: trialFin,
          plan: 'trial',
          rol: rol,
        );
      }

      return EstadoSuscripcion(
        estado: EstadoTrial.trialActivo,
        diasRestantes: trialFin.difference(horaReal).inDays,
        trialInicio: trialInicio,
        trialFin: trialFin,
        plan: 'trial',
        activa: true,
        rol: rol,
      );
    } catch (_) {
      return EstadoSuscripcion.cargando0;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STREAM REACTIVO
  // ═══════════════════════════════════════════════════════════

  /// Emite el estado cada vez que el documento del usuario cambia.
  /// Esto permite que, cuando la Cloud Function activa la suscripción
  /// tras un pago, la app se desbloquee automáticamente sin reiniciar.
  ///
  /// Estrategia: escucha los cambios del doc, pero solo recalcula el
  /// estado cuando cambia algún campo relevante (plan, activa, hasta,
  /// rol, baneado). No hace polling.
  static Stream<EstadoSuscripcion> stream(String uid) {
    if (uid.isEmpty) {
      return Stream.value(EstadoSuscripcion.cargando0);
    }

    String _firma(Map<String, dynamic>? data) {
      if (data == null) return '';
      final sus = data['suscripcion'] as Map<String, dynamic>?;
      return [
        data['rol'],
        data['baneado'],
        sus?['plan'],
        sus?['activa'],
        (sus?['hasta'] as Timestamp?)?.millisecondsSinceEpoch,
        (sus?['trialFin'] as Timestamp?)?.millisecondsSinceEpoch,
      ].join('|');
    }

    String? ultimaFirma;

    return _db
        .collection('usuarios')
        .doc(uid)
        .snapshots()
        .asyncMap((snap) async {
      final firma = _firma(snap.data());
      // Primera emisión o cambio real → recalcular.
      if (firma != ultimaFirma) {
        ultimaFirma = firma;
        return evaluar(uid);
      }
      // Cambio sin relevancia (ej. ultimoCheck) → no hacemos nada.
      // Devolvemos el último estado que el llamador ya tiene.
      return null;
    }).where((e) => e != null).cast<EstadoSuscripcion>();
  }

  // ═══════════════════════════════════════════════════════════
  // ACTIVACIÓN / CANCELACIÓN (red de seguridad admin)
  // ═══════════════════════════════════════════════════════════

  /// Activa un plan manualmente. Diseñada para ser llamada desde:
  ///   - La Cloud Function (webhook de Culqi).
  ///   - El panel de admin (si el webhook falló y hay que forzar).
  ///
  /// `aprobadaPor` queda registrado para auditoría.
  static Future<void> activarSuscripcion({
    required String uid,
    required String plan, // 'sikurito' o 'vip'
    required int duracionDias,
    String aprobadaPor = 'cloud_function',
  }) async {
    final ahora = DateTime.now();
    final hasta = ahora.add(Duration(days: duracionDias));

    await _db.collection('usuarios').doc(uid).update({
      'suscripcion.plan': plan,
      'suscripcion.activa': true,
      'suscripcion.hasta': Timestamp.fromDate(hasta),
      'suscripcion.aprobadaPor': aprobadaPor,
      'suscripcion.fechaActivacion': FieldValue.serverTimestamp(),
      'suscripcion.ultimoCheck': FieldValue.serverTimestamp(),
    });
  }

  /// Cancela la suscripción activa. La llama el panel de admin o
  /// la Cloud Function cuando Culqi reporta un cobro fallido.
  static Future<void> cancelarSuscripcion(String uid) async {
    await _db.collection('usuarios').doc(uid).update({
      'suscripcion.activa': false,
      'suscripcion.plan': 'ninguno',
      'suscripcion.fechaCancelacion': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════════════
  // LISTA DE SUSCRIPTORES (para panel admin)
  // ═══════════════════════════════════════════════════════════

  /// Stream con todos los usuarios que tengan suscripción activa.
  /// Se usa en el panel de admin.
  static Stream<QuerySnapshot<Map<String, dynamic>>> listarSuscriptores() {
    return _db
        .collection('usuarios')
        .where('suscripcion.activa', isEqualTo: true)
        .where('suscripcion.plan', whereIn: ['sikurito', 'vip'])
        .snapshots();
  }

  // ═══════════════════════════════════════════════════════════
  // DONACIONES — REGISTRO DESDE LA APP
  // ═══════════════════════════════════════════════════════════

  /// Registra una donación en Firestore cuando el usuario vuelve del
  /// link de pago de Culqi. La Cloud Function confirma luego contra
  /// el webhook real de Culqi y marca `verificada = true`.
  ///
  /// Esto es solo un registro optimista. La barra de progreso de la
  /// meta de donación se actualiza con lo verificado por la Cloud
  /// Function, no con esto.
  static Future<void> registrarDonacion({
    required String uid,
    required String emailUsuario,
    required String tipo, // 'cafe' o 'apoyo'
    required int montoCentimos,
    String? culqiChargeId,
  }) async {
    await _db.collection('donaciones').add({
      'uid': uid,
      'email': emailUsuario,
      'tipo': tipo,
      'montoCentimos': montoCentimos,
      'culqiChargeId': culqiChargeId,
      'verificada': false,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }

  /// Stream con la meta de donación y lo recaudado hasta ahora.
  /// La Cloud Function actualiza `config/meta_donacion` cada vez
  /// que entra una donación verificada.
  static Stream<Map<String, dynamic>> streamMetaDonacion() {
    return _db
        .collection('config')
        .doc('meta_donacion')
        .snapshots()
        .map((snap) {
      final data = snap.data() ?? {};
      return {
        'meta': (data['meta'] ?? PlanSuscripcion.metaDonacionCentimos),
        'recaudado': (data['recaudado'] ?? 0),
        'actualizadoEn': data['actualizadoEn'],
      };
    });
  }

  // ═══════════════════════════════════════════════════════════
  // COMUNIDAD — LISTA PÚBLICA
  // ═══════════════════════════════════════════════════════════

  /// Stream con la lista pública de comunidad.
  /// La Cloud Function mantiene esta colección sincronizada.
  /// Solo expone: nombre, rol, esSuscriptor, esVip, baneado.
  static Stream<List<Map<String, dynamic>>> listarComunidad() {
    return _db
        .collection('comunidad')
        .snapshots()
        .map((snap) {
      final lista = snap.docs.map((doc) {
        final d = doc.data();
        return {
          'uid': doc.id,
          'nombre': (d['nombre'] ?? 'Usuario').toString(),
          'rol': (d['rol'] ?? 'publico').toString(),
          'esSuscriptor': d['esSuscriptor'] == true,
          'esVip': d['esVip'] == true,
          'baneado': d['baneado'] == true,
        };
      }).toList();

      // Orden: dev > admin > miembro > suscriptor > vip > público
      // Baneados siempre al final.
      int peso(Map<String, dynamic> u) {
        if (u['baneado'] == true) return 100;
        switch (u['rol']) {
          case 'dev':
            return 0;
          case 'admin':
            return 1;
          case 'miembro':
            return 2;
        }
        if (u['esSuscriptor'] == true) return 3;
        if (u['esVip'] == true) return 4;
        return 5;
      }

      lista.sort((a, b) {
        final p = peso(a).compareTo(peso(b));
        if (p != 0) return p;
        return (a['nombre'] as String)
            .toLowerCase()
            .compareTo((b['nombre'] as String).toLowerCase());
      });

      return lista;
    });
  }
}