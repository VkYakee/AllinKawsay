// lib/design/components/app_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../tokens.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    final (bg, fg, borderColor) = _resolve(disabled);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 50,
      child: Material(
        color: bg,
        borderRadius: Rad.rMd,
        child: InkWell(
          borderRadius: Rad.rMd,
          onTap: disabled ? null : () {
            HapticFeedback.lightImpact();
            onPressed!();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Sp.xl),
            decoration: BoxDecoration(
              borderRadius: Rad.rMd,
              border: borderColor == null ? null : Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: fg, strokeWidth: 2.5))
                else if (icon != null)
                  Icon(icon, color: fg, size: 20),
                if (loading || icon != null) const SizedBox(width: Sp.sm),
                Text(
                  label,
                  style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
        return (disabled ? AppColors.granate.withOpacity(0.4) : AppColors.granate, AppColors.dorado, null);
      case AppButtonVariant.secondary:
        return (Colors.transparent, disabled ? AppColors.granate.withOpacity(0.4) : AppColors.granate, AppColors.granate.withOpacity(disabled ? 0.2 : 0.6));
      case AppButtonVariant.ghost:
        return (Colors.transparent, disabled ? AppColors.granate.withOpacity(0.4) : AppColors.granate, null);
      case AppButtonVariant.danger:
        return (disabled ? Colors.red.withOpacity(0.4) : Colors.red.shade700, Colors.white, null);
    }
  }
}