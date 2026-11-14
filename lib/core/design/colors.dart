// lib/core/design/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === PALETA PRINCIPAL NEO-ANDINA ===
  static const Color granate = Color(0xFF6E1423);
  static const Color granateOscuro = Color(0xFF4A0D18);
  static const Color granateClaro = Color(0xFF8B1F35);
  static const Color granateSagrado = Color(0xFF7A1526);
  static const Color granateVivo = Color(0xFF9E1B32);

  static const Color dorado = Color(0xFFD4AF37);
  static const Color doradoClaro = Color(0xFFE8C86A);
  static const Color doradoOscuro = Color(0xFFA67C00);
  static const Color oroSolar = Color(0xFFE5B842);
  static const Color oroReflejo = Color(0xFFFFE79A);

  // === FONDOS Y SUPERFICIES OLED ===
  static const Color negroPuro = Color(0xFF000000); // OLED
  static const Color fondoOLED = Color(0xFF070709);
  static const Color fondoOscuro = Color(0xFF0A0A0E);
  static const Color grafitoCarbon = Color(0xFF121216);
  static const Color superficieCard = Color(0xFF16161C);
  static const Color fondoClaro = Color(0xFFF2F2F7); // Gris iOS

  static const Color surfaceDark = Color(0xFF141418);
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
    colors: [oroReflejo, oroSolar, doradoOscuro],
  );

  static const LinearGradient gradienteShimmer = LinearGradient(
    begin: Alignment(-1.5, -0.5),
    end: Alignment(1.5, 0.5),
    colors: [
      Color(0x00FFFFFF),
      Color(0x40FFE79A),
      Color(0x90FFE79A),
      Color(0x40FFE79A),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.35, 0.5, 0.65, 1.0],
  );

  static const LinearGradient gradienteCristal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x18FFFFFF),
      Color(0x05FFFFFF),
    ],
  );

  // === RESPLANDORES Y SOMBRAS (GLOW) ===
  static List<BoxShadow> glowDorado({double intens = 0.35, double blur = 20, double spread = 0}) => [
        BoxShadow(
          color: oroSolar.withOpacity(intens),
          blurRadius: blur,
          spreadRadius: spread,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> glowGranate({double intens = 0.4, double blur = 24}) => [
        BoxShadow(
          color: granateSagrado.withOpacity(intens),
          blurRadius: blur,
          offset: const Offset(0, 8),
        ),
      ];
}