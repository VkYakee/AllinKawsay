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
