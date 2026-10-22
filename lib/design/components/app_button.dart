// lib/design/components/app_button.dart
//
// Botón unificado. Reemplaza FilledButton / OutlinedButton / TextButton
// en TODA la app nueva. Tiene estados: primary, secondary, ghost, danger.
// Auto-maneja loading y disabled.

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final (bg, fg, borderColor) = _resolve(disabled);

    final height = switch (size) {
      AppButtonSize.sm => 40.0,
      AppButtonSize.md => 50.0,
      AppButtonSize.lg => 56.0,
    };
    final fontSize = switch (size) {
      AppButtonSize.sm => 11.0,
      AppButtonSize.md => 12.0,
      AppButtonSize.lg => 13.0,
    };

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: Material(
        color: bg,
        borderRadius: Rad.rMd,
        child: InkWell(
          borderRadius: Rad.rMd,
          onTap: disabled ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Sp.xl),
            decoration: BoxDecoration(
              borderRadius: Rad.rMd,
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: fg,
                      strokeWidth: 2.5,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, color: fg, size: 18),
                if (loading || icon != null) const SizedBox(width: Sp.sm),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: fg,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color?) _resolve(bool disabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return (
          disabled ? AppColors.granate.withOpacity(0.4) : AppColors.granate,
          AppColors.dorado,
          null,
        );
      case AppButtonVariant.secondary:
        return (
          Colors.transparent,
          disabled ? AppColors.granate.withOpacity(0.4) : AppColors.granate,
          AppColors.granate.withOpacity(disabled ? 0.2 : 0.6),
        );
      case AppButtonVariant.ghost:
        return (
          Colors.transparent,
          disabled ? AppColors.granate.withOpacity(0.4) : AppColors.granate,
          null,
        );
      case AppButtonVariant.danger:
        return (
          disabled ? Colors.red.withOpacity(0.4) : Colors.red.shade700,
          Colors.white,
          null,
        );
    }
  }
}