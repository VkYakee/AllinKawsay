// lib/core/design/app_theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';
import 'tokens.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.fondoClaro,
      colorScheme: const ColorScheme.light(
        primary: AppColors.granate,
        onPrimary: AppColors.dorado,
        secondary: AppColors.dorado,
        onSecondary: AppColors.negroPuro,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textLightPrimario,
        outline: AppColors.dorado,
      ),
      textTheme: const TextTheme(
        displayLarge: AppText.h1,
        headlineMedium: AppText.h2,
        titleLarge: AppText.title,
        bodyLarge: AppText.body,
        bodyMedium: AppText.bodySm,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.dorado,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.dorado,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        iconTheme: IconThemeData(color: AppColors.dorado),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dorado.withOpacity(0.2),
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.negroPuro,
        contentTextStyle: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: Rad.rXl),
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.granate),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        showDragHandle: false,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.fondoOscuro,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.granate,
        onPrimary: AppColors.dorado,
        secondary: AppColors.dorado,
        onSecondary: AppColors.negroPuro,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textDarkPrimario,
        outline: AppColors.dorado,
      ),
      textTheme: const TextTheme(
        displayLarge: AppText.h1,
        headlineMedium: AppText.h2,
        titleLarge: AppText.title,
        bodyLarge: AppText.body,
        bodyMedium: AppText.bodySm,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.dorado,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.dorado,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        iconTheme: IconThemeData(color: AppColors.dorado),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dorado.withOpacity(0.2),
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.granateOscuro,
        contentTextStyle: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: Rad.rXl),
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dorado),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        showDragHandle: false,
      ),
    );
  }
}