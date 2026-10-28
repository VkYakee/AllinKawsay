// lib/design/components/app_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../tokens.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bg, fg, borderColor, hasGradient) = _resolve(disabled, isDark);

    final height = switch (widget.size) {
      AppButtonSize.sm => 40.0,
      AppButtonSize.md => 50.0,
      AppButtonSize.lg => 56.0,
    };
    final fontSize = switch (widget.size) {
      AppButtonSize.sm => 12.0,
      AppButtonSize.md => 13.5,
      AppButtonSize.lg => 15.0,
    };

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTap: disabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: Dur.fast,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          duration: Dur.fast,
          opacity: disabled ? 0.5 : 1.0,
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: Sp.xl),
            decoration: BoxDecoration(
              color: hasGradient ? null : bg,
              gradient: hasGradient
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.granate, AppColors.granateOscuro],
                    )
                  : null,
              borderRadius: Rad.rMd,
              border: borderColor == null
                  ? Border.all(
                      color: Colors.white.withOpacity(0.14),
                      width: 0.8,
                    )
                  : Border.all(color: borderColor, width: 1.2),
              boxShadow: (!disabled &&
                      widget.variant == AppButtonVariant.primary)
                  ? [
                      BoxShadow(
                        color: AppColors.granate.withOpacity(0.32),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize:
                  widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading)
                  SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      color: fg,
                      strokeWidth: 2.2,
                    ),
                  )
                else if (widget.icon != null)
                  Icon(widget.icon, color: fg, size: 18),
                if (widget.loading || widget.icon != null)
                  const SizedBox(width: Sp.sm),
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color?, bool) _resolve(bool disabled, bool isDark) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return (
          AppColors.granate,
          AppColors.dorado,
          null,
          true,
        );
      case AppButtonVariant.secondary:
        return (
          isDark
              ? Colors.white.withOpacity(0.08)
              : AppColors.granate.withOpacity(0.07),
          isDark ? AppColors.dorado : AppColors.granate,
          isDark
              ? AppColors.dorado.withOpacity(0.35)
              : AppColors.granate.withOpacity(0.28),
          false,
        );
      case AppButtonVariant.ghost:
        return (
          Colors.transparent,
          isDark ? AppColors.dorado : AppColors.granate,
          Colors.transparent,
          false,
        );
      case AppButtonVariant.danger:
        return (
          Colors.red.shade700,
          Colors.white,
          null,
          false,
        );
    }
  }
}
