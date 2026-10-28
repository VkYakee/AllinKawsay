// lib/design/typography.dart
import 'package:flutter/material.dart';

class AppType {
  AppType._();

  // ═══════════════════════════════════════════════
  // HEADINGS — Estilo Apple HIG (tracking ajustado)
  // ═══════════════════════════════════════════════

  static const h1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    height: 1.12,
  );

  static const h2 = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.18,
  );

  static const h3 = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.22,
  );

  static const title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.28,
  );

  static const subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.32,
  );

  // ═══════════════════════════════════════════════
  // BODY — Lectura limpia y fluida
  // ═══════════════════════════════════════════════

  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.48,
  );

  static const bodySm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.42,
  );

  // ═══════════════════════════════════════════════
  // LABELS — Botones, chips y metadatos
  // ═══════════════════════════════════════════════

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.35,
  );

  static const captionXs = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.3,
  );

  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    height: 1.25,
  );

  static const labelXs = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.9,
    height: 1.25,
  );

  static const eyebrow = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.25,
  );

  // ═══════════════════════════════════════════════
  // ESPECIALES
  // ═══════════════════════════════════════════════

  static const mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
}
