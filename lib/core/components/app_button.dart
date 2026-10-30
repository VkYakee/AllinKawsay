// lib/core/components/app_button.dart
import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/motion.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final (bg, fg, borderColor) = _resolve(disabled);

    return SizedBox(
      width: widget.fullWidth ? double.infinity : null,
      height: 50,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _isPressed = false),
        onTapCancel: disabled ? null : () => setState(() => _isPressed = false),
        onTap: disabled ? null : () {
          AppMotion.hapticLight();
          widget.onPressed!();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.spring,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Sp.xl),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: Rad.rMd,
              border: borderColor == null ? null : Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading)
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: fg, strokeWidth: 2.5))
                else if (widget.icon != null)
                  Icon(widget.icon, color: fg, size: 20),
                if (widget.loading || widget.icon != null) const SizedBox(width: Sp.sm),
                Text(
                  widget.label,
                  style: AppText.subtitle.copyWith(color: fg, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color?) _resolve(bool disabled) {
    switch (widget.variant) {
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