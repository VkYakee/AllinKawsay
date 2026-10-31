// lib/features/suscripcion/models/plan_suscripcion.dart
import 'package:flutter/material.dart';

/// Catálogo de planes y límites del sistema de monetización.
///
/// IMPORTANTE: los precios de acá son los PVP (lo que ve el usuario).
/// Ya incluyen la comisión de Culqi, redondeados para que al grupo
/// le llegue el monto neto deseado.
///
/// Comisión Culqi Yape aplicada:
///   3.44% + S/ 0.20 + IGV 18% ≈ S/ 0.81 fijo + 3.44% variable.
///
/// Dólar de referencia: S/ 3.46 (ajustar acá si cambia mucho).
class PlanSuscripcion {
  final String id;
  final String nombre;
  final String descripcion;
  final int precioCentimos;
  final int duracionDias;
  final String linkCulqi;
  final IconData icono;
  final bool recomendado;
  final bool esPagoUnico;

  const PlanSuscripcion({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioCentimos,
    required this.duracionDias,
    required this.linkCulqi,
    required this.icono,
    this.recomendado = false,
    this.esPagoUnico = false,
  });

  String get precioFormateado {
    final soles = precioCentimos / 100;
    return 'S/ ${soles.toStringAsFixed(2)}';
  }

  String get duracionTexto {
    if (esPagoUnico) return 'para siempre';
    if (duracionDias >= 365) {
      final anos = duracionDias ~/ 365;
      return '$anos ${anos == 1 ? "año" : "años"}';
    }
    if (duracionDias >= 30) {
      final meses = duracionDias ~/ 30;
      return '$meses ${meses == 1 ? "mes" : "meses"}';
    }
    return '$duracionDias días';
  }

  /// Neto aproximado que recibe el grupo después de comisión Culqi.
  String get netoFormateado {
    final pvp = precioCentimos / 100;
    final comision = 0.81 + (pvp * 0.0344);
    final neto = pvp - comision;
    return 'S/ ${neto.toStringAsFixed(2)}';
  }

  // ═══════════════════════════════════════════════════════════
  // PLANES ACTIVOS
  // ═══════════════════════════════════════════════════════════

  static const PlanSuscripcion sikurito = PlanSuscripcion(
    id: 'sikurito',
    nombre: 'Sikurito',
    descripcion: 'Acceso total · renovación mensual',
    precioCentimos: 2700, // S/ 27.00 → neto ~S/ 25.26
    duracionDias: 30,
    linkCulqi: 'https://checkout.culqi.com/link-placeholder-sikurito',
    icono: Icons.workspace_premium,
    recomendado: true,
  );

  static const PlanSuscripcion vip = PlanSuscripcion(
    id: 'vip',
    nombre: 'VIP de por vida',
    descripcion: 'Pago único · acceso para siempre',
    precioCentimos: 8650, // S/ 86.50 → neto ~S/ 80.00
    duracionDias: 99999,
    linkCulqi: 'https://checkout.culqi.com/link-placeholder-vip',
    icono: Icons.diamond,
    esPagoUnico: true,
  );

  static const List<PlanSuscripcion> planes = [sikurito, vip];

  // ═══════════════════════════════════════════════════════════
  // CONFIGURACIÓN DEL TRIAL
  // ═══════════════════════════════════════════════════════════

  /// Días del trial gratuito.
  static const int diasTrial = 3;

  /// Canciones desbloqueadas durante el trial.
  static const int cancionesTrial = 8;

  /// Canciones desbloqueadas después del trial (sin pagar).
  static const int cancionesPostTrial = 15;

  /// Canciones de ensayo disponibles en el trial.
  static const int cancionesEnsayaTrial = 1;

  // ═══════════════════════════════════════════════════════════
  // CONFIGURACIÓN DE DONACIONES
  // ═══════════════════════════════════════════════════════════

  /// Monto mínimo para "Invítame un café" (S/ 12.50 → neto S/ 10+).
  static const int cafeMinimoCentimos = 1250;

  /// Meta de recaudación para lanzar a Google Play + servidores.
  static const int metaDonacionCentimos = 32000; // S/ 320.00

  /// Link de pago para donaciones (mismo para ambas).
  static const String linkDonacion =
      'https://checkout.culqi.com/link-placeholder-donacion';

  /// Montos sugeridos para el café (además del mínimo).
  static const List<int> montosCafeSugeridos = [
    1250, // S/ 12.50
    2000, // S/ 20.00
    5000, // S/ 50.00
  ];

  /// Montos sugeridos para "Apoya a lanzar la app".
  static const List<int> montosApoyoYSugeridos = [
    2000, // S/ 20.00
    5000, // S/ 50.00
    10000, // S/ 100.00
  ];
}