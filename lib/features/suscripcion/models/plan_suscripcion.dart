// lib/features/suscripcion/models/plan_suscripcion.dart
import 'package:flutter/material.dart';

/// Catálogo de planes y límites del sistema de monetización.
///
/// IMPORTANTE: los precios de acá son los PVP (lo que ve el usuario).
/// Ya incluyen la comisión de Mercado Pago, redondeados para que al
/// grupo le llegue el monto neto deseado.
///
/// Comisión Mercado Pago aplicada (Cobro instantáneo):
///   3.49% + S/ 1.00 + IGV 18% ≈ S/ 1.18 fijo + 3.49% variable.
class PlanSuscripcion {
  final String id;
  final String nombre;
  final String descripcion;
  final int precioCentimos;
  final int duracionDias;
  final String linkPago;
  final IconData icono;
  final bool recomendado;
  final bool esPagoUnico;

  const PlanSuscripcion({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioCentimos,
    required this.duracionDias,
    required this.linkPago,
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

  // ═══════════════════════════════════════════════════════════
  // PLANES ACTIVOS (Mercado Pago)
  // ═══════════════════════════════════════════════════════════

  static const PlanSuscripcion sikurito = PlanSuscripcion(
    id: 'sikurito',
    nombre: 'Sikurito',
    descripcion: 'Acceso total · pago manual mensual',
    precioCentimos: 2700, // S/ 27.00
    duracionDias: 30,
    linkPago: 'https://mpago.la/2iMQG2E',
    icono: Icons.workspace_premium,
    recomendado: true,
  );

  static const PlanSuscripcion vip = PlanSuscripcion(
    id: 'vip',
    nombre: 'VIP de por vida',
    descripcion: 'Pago único · acceso para siempre',
    precioCentimos: 8650, // S/ 86.50
    duracionDias: 99999,
    linkPago: 'https://mpago.la/1snvMcd',
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

  /// Monto mínimo para "Invítame un café" (S/ 12.50).
  static const int cafeMinimoCentimos = 1250;

  /// Meta de recaudación para lanzar a Google Play + servidores.
  static const int metaDonacionCentimos = 32000; // S/ 320.00

  /// Link de pago para donaciones (Mercado Pago monto abierto).
  static const String linkDonacion =
      'https://link.mercadopago.com.pe/allinkawsay';

  /// Montos sugeridos para el café.
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