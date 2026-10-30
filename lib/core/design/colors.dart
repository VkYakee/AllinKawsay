// lib/core/design/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === PALETA PRINCIPAL ===
  static const Color granate = Color(0xFF6E1423);
  static const Color granateOscuro = Color(0xFF4A0D18);
  static const Color granateClaro = Color(0xFF8B1F35);
  static const Color dorado = Color(0xFFD4AF37);
  static const Color doradoClaro = Color(0xFFE8C86A);
  static const Color doradoOscuro = Color(0xFFA67C00);

  // === FONDOS Y SUPERFICIES ===
  static const Color negroPuro = Color(0xFF000000); // OLED
  static const Color fondoOscuro = Color(0xFF0F0F0F);
  static const Color fondoClaro = Color(0xFFF2F2F7); // Gris iOS

  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // === TEXTOS ===
  static const Color textDarkPrimario = Color(0xFFE8E8E8);
  static const Color textDarkSecundario = Color(0xFFB0B0B0);
  static const Color textLightPrimario = Color(0xFF1A1A1A);
  static const Color textLightSecundario = Color(0xFF8E8E93);

  // === HELPERS ADAPTATIVOS ===
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? fondoOscuro : fondoClaro;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color onSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textDarkPrimario : textLightPrimario;

  static Color onSurfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textDarkSecundario : textLightSecundario;

  // === CRISTAL (LIQUID GLASS) ===
  static Color glassFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.08)
          : Colors.white.withOpacity(0.6);

  static Color glassBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.15)
          : Colors.white.withOpacity(0.8);

  // === GRADIENTES ===
  static const LinearGradient gradienteGranate = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [granateOscuro, granate],
  );

  static const LinearGradient gradienteDorado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dorado, doradoOscuro],
  );
}