// lib/core/design/motion.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema de movimiento élite.
///
/// Todas las animaciones de la app pasan por acá.
/// Regla: ninguna `Duration` suelta en el código — se usa el token.
/// Regla: ninguna `Curve` suelta — se usa el token.
class AppMotion {
  AppMotion._();

  // ─── Duraciones ─────────────────────────────────────────────
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration reveal = Duration(milliseconds: 650);

  // ─── Curvas de física ───────────────────────────────────────

  /// Spring con overshoot suave. El sello Apple.
  /// Se usa en botones, cards, chips, iconos que se presionan.
  static const Curve spring = Cubic(0.175, 0.885, 0.32, 1.275);

  /// Overshoot más agresivo. Para héroes, FABs, y transiciones de entrada.
  static const Curve bouncy = Cubic(0.34, 1.56, 0.64, 1.0);

  /// Resorte rápido y tenso para micro-interacciones (iconos, tabs).
  static const Curve springSnappy = Cubic(0.2, 1.2, 0.3, 1.0);

  /// Resorte suave para modales y navegación de cristal.
  static const Curve springGentle = Cubic(0.16, 1.0, 0.3, 1.0);

  /// Ease out clásico. Compatible con el ThemeData existente.
  static const Curve easeOut = Curves.easeOutCubic;

  /// Ease out quart. Ideal para entradas de listas y reveals.
  static const Curve easeOutQuart = Cubic(0.25, 1.0, 0.5, 1.0);

  /// Anticipación: se agacha antes de saltar.
  /// Para modales y sheets.
  static const Curve anticipation = Cubic(0.5, -0.5, 0.5, 1.5);

  /// Curva de entrada para filas de lista.
  static const Curve entry = Cubic(0.2, 0.9, 0.3, 1.0);

  // ─── Simulaciones de Resorte Físico (SpringSimulations) ──────

  /// Resorte elástico para rebote de botones y tarjetas.
  static const SpringDescription springBouncy = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 12.0,
  );

  /// Resorte fluido para cápsulas flotantes y navegación de cristal.
  static const SpringDescription springSmooth = SpringDescription(
    mass: 1.0,
    stiffness: 140.0,
    damping: 20.0,
  );

  /// Resorte para modales tridimensionales con peso.
  static const SpringDescription springModal = SpringDescription(
    mass: 1.2,
    stiffness: 200.0,
    damping: 22.0,
  );

  // ─── Alias legacy (no romper imports existentes) ────────────
  static const Curve bounce = Curves.elasticOut;

  // ─── Feedback háptico ───────────────────────────────────────

  static Future<void> hapticLight() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> hapticHeavy() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> hapticSelection() async {
    await HapticFeedback.selectionClick();
  }
}