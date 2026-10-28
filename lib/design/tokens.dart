// lib/design/tokens.dart
import 'package:flutter/material.dart';

/// Espaciado estándar del sistema.
class Sp {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

/// Radios de bordes redondeados estilo iOS (Squircle).
class Rad {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;

  static BorderRadius get rSm => BorderRadius.circular(sm);
  static BorderRadius get rMd => BorderRadius.circular(md);
  static BorderRadius get rLg => BorderRadius.circular(lg);
  static BorderRadius get rXl => BorderRadius.circular(xl);
  static BorderRadius get rPill => BorderRadius.circular(pill);
}

/// Intensidades de desenfoque para efecto Glassmorphism (iOS).
class GlassBlur {
  static const double subtle = 12.0;
  static const double medium = 22.0;
  static const double heavy = 35.0;
}

/// Duraciones de animación suaves.
class Dur {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
}

/// Sombras ambientales profundas y suaves estilo Apple.
class Elev {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 16,
          spreadRadius: -2,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 24,
          spreadRadius: -4,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.20),
          blurRadius: 36,
          spreadRadius: -6,
          offset: const Offset(0, 16),
        ),
      ];
}
