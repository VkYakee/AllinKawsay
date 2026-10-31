// lib/core/design/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === PALETA PRINCIPAL MEJORADA (Más viva) ===
  static const Color granate = Color(0xFF8B1A2B); // Un rojo vino más vivo
  static const Color granateOscuro = Color(0xFF4A0D18);
  static const Color granateClaro = Color(0xFFA82235);
  static const Color dorado = Color(0xFFF5D061); // Dorado más brillante
  static const Color doradoClaro = Color(0xFFFFEAA0);
  static const Color doradoOscuro = Color(0xFFC89B29);

  // === FONDOS Y SUPERFICIES (OLED Profundo) ===
  static const Color negroPuro = Color(0xFF000000);
  static const Color fondoOscuro = Color(0xFF0A0A0A);
  static const Color fondoClaro = Color(0xFFF5F5F7);

  // Las superficies en modo oscuro deben ser ligeramente más claras para crear contraste
  static const Color surfaceDark = Color(0xFF161616); 
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // === TEXTOS ===
  static const Color textDarkPrimario = Color(0xFFF2F2F2);
  static const Color textDarkSecundario = Color(0xFFA0A0A0);
  static const Color textLightPrimario = Color(0xFF111111);
  static const Color textLightSecundario = Color(0xFF666666);

  // === HELPERS ADAPTATIVOS ===
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? fondoOscuro : fondoClaro;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color onSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textDarkPrimario : textLightPrimario;

  static Color onSurfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textDarkSecundario : textLightSecundario;

  // === CRISTAL LÍQUIDO (LIQUID GLASS REAL) ===
  // En modo oscuro usamos un tinte vino muy sutil, no un blanco grisáceo.
  static Color glassFill(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? granateOscuro.withOpacity(0.4) // Fondo vino translúcido
        : Colors.white.withOpacity(0.7);
  }

  // El borde del cristal debe brillar
  static Color glassBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dorado.withOpacity(0.25) // Borde dorado
        : Colors.white.withOpacity(0.9);
  }

  // === GRADIENTES ===
  static const LinearGradient gradienteGranate = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [granateClaro, granateOscuro],
  );

  static const LinearGradient gradienteDorado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [doradoClaro, dorado, doradoOscuro],
  );
}