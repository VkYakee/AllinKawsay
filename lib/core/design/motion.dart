// lib/core/design/motion.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppMotion {
  AppMotion._();

  // Duraciones estándar
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Curvas de física (El toque mágico de Apple)
  static const Curve spring = Cubic(0.175, 0.885, 0.32, 1.275);
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;

  /// Ejecuta un feedback háptico ligero (vibración sutil).
  /// Úsalo en cada toque de botón o cambio de estado.
  static Future<void> hapticLight() async {
    await HapticFeedback.lightImpact();
  }

  /// Feedback más fuerte (para acciones importantes o errores).
  static Future<void> hapticHeavy() async {
    await HapticFeedback.heavyImpact();
  }
}