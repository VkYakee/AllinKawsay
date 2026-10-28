// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // === PALETA PRINCIPAL DEL GRUPO ===
  static const granate = Color(0xFF7A1628);
  static const granateOscuro = Color(0xFF420A14);
  static const granateClaro = Color(0xFF9E243B);
  static const dorado = Color(0xFFD9B64E);
  static const doradoClaro = Color(0xFFF0D78C);
  static const doradoOscuro = Color(0xFFA67C00);
  static const negro = Color(0xFF121011);
  static const blanco = Color(0xFFFFFFFF);
  static const grisClaro = Color(0xFFF2F2F7);
  static const grisMedio = Color(0xFFAEAEB2);
  static const grisOscuro = Color(0xFF3A3A3C);

  // === MODO OSCURO (OLED Profundo con matiz cálido) ===
  static const fondoOscuro = Color(0xFF090507);
  static const fondoCardOscuro = Color(0xFF171114);
  static const fondoCardOscuroElevado = Color(0xFF241B1F);
  static const textoOscuroClaro = Color(0xFFF5F3F4);
  static const textoOscuroMedio = Color(0xFFA89F91);

  // === GRADIENTES ===
  static const gradienteGranate = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [granateClaro, granate, granateOscuro],
  );

  static const gradienteOscuro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [fondoOscuro, granateOscuro],
  );

  static const gradienteDorado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [doradoClaro, dorado, doradoOscuro],
  );

  // === HELPERS DE CRISTAL (LIQUID GLASS) ===
  static Color glassFill(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.white.withOpacity(0.74);
  }

  static Color glassBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withOpacity(0.14)
        : Colors.white.withOpacity(0.88);
  }

  // === HELPERS DE TEXTO Y SUPERFICIE ===
  static Color textoPrincipal(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textoOscuroClaro
        : negro;
  }

  static Color textoSecundario(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textoOscuroMedio
        : negro.withOpacity(0.62);
  }

  static Color textoTerciario(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textoOscuroMedio.withOpacity(0.68)
        : negro.withOpacity(0.45);
  }

  static Color borde(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dorado.withOpacity(0.28)
        : dorado.withOpacity(0.42);
  }

  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? fondoCardOscuro.withOpacity(0.82)
        : blanco.withOpacity(0.85);
  }

  static Color fondoApp(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? fondoOscuro
        : const Color(0xFFF2F2F7);
  }

  static Color seccionTitulo(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dorado
        : granate;
  }
}
