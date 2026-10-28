// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // === PALETA PRINCIPAL DEL GRUPO ===
  static const granate = Color(0xFF6E1423);
  static const granateOscuro = Color(0xFF4A0D18);
  static const granateClaro = Color(0xFF8B1F35);
  static const dorado = Color(0xFFD4AF37);
  static const doradoClaro = Color(0xFFE8C86A);
  static const doradoOscuro = Color(0xFFA67C00);
  static const negro = Color(0xFF1A1A1A);
  static const blanco = Color(0xFFFFFFFF);
  static const grisClaro = Color(0xFFF5F5F5);

  // === MODO OSCURO OLED ===
  static const fondoOscuro = Color(0xFF000000); // Negro puro
  static const fondoCardOscuro = Color(0xFF1A1A1A);
  static const fondoCardOscuroElevado = Color(0xFF242424);
  static const textoOscuroClaro = Color(0xFFE8E8E8);
  static const textoOscuroMedio = Color(0xFFB0B0B0);

  // === GRADIENTES ===
  static const gradienteGranate = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [granateOscuro, granate],
  );

  static const gradienteDorado = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dorado, doradoOscuro],
  );

  // === HELPERS DE CRISTAL ===
  static Color glassFill(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.6);
  }

  static Color glassBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.8);
  }

  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? fondoCardOscuro
        : blanco;
  }

  static Color seccionTitulo(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? dorado
        : granate;
  }
}