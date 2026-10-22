// lib/design/typography.dart
//
// Sistema tipográfico. Usar SIEMPRE estas constantes, nunca TextStyle ad-hoc.
//
// Uso:
//   Text('Cancionero', style: AppType.h2)
//   Text('32 canciones', style: AppType.caption)

import 'package:flutter/material.dart';

class AppType {
  AppType._();

  // ═══════════════════════════════════════════════
  // HEADINGS — títulos de pantalla y sección
  // ═══════════════════════════════════════════════

  /// Título de pantalla principal (ej: "Cancionero")
  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.15,
  );

  /// Título de sección importante (ej: "Últimas canciones")
  static const h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
    height: 1.2,
  );

  /// Título de card destacada (ej: nombre de canción en hero)
  static const h3 = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.25,
  );

  /// Título de card normal (ej: nombre de canción en lista)
  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.3,
  );

  /// Subtítulo (ej: autor de la canción)
  static const subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
  );

  // ═══════════════════════════════════════════════
  // BODY — texto general
  // ═══════════════════════════════════════════════

  /// Texto general (descripciones, párrafos)
  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Texto chico (metadata, subtítulos secundarios)
  static const bodySm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.45,
  );

  // ═══════════════════════════════════════════════
  // LABELS — botones, chips, tags
  // ═══════════════════════════════════════════════

  /// Caption (fechas, conteos, hints)
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
  );

  /// Caption extra chico (metadata muy secundaria)
  static const captionXs = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.35,
  );

  /// Label de botón / chip (mayúsculas)
  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.3,
  );

  /// Label extra chico (badges tipo "PRÓXIMO", "NUEVO")
  static const labelXs = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.3,
  );

  /// Eyebrow text — texto arriba de títulos (ej: "SECCIÓN")
  static const eyebrow = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
    height: 1.3,
  );

  // ═══════════════════════════════════════════════
  // ESPECIALES
  // ═══════════════════════════════════════════════

  /// Monoespaciado (numerofonía, timings)
  static const mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    height: 1.4,
  );
}