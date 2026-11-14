// lib/core/components/allin_button.dart
import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/motion.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

enum AllinButtonVariant {
  primary,   // Granate ceremonial + resplandor dorado
  gold,      // Dorado solar metálico
  glass,     // Cristal translúcido con desenfoque
  outline,   // Borde fino dorado + fondo transparente
  danger,    // Rojo carmesí para acciones destructivas
}

class AllinButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final AllinButtonVariant variant;
  final bool loading;
  final bool fullWidth;
  final double height;
  final bool enableShimmer;

  const AllinButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = AllinButtonVariant.primary,
    this.loading = false,
    this.fullWidth = true,
    this.height = 54,
    this.enableShimmer = true,
  });

  @override
  State<AllinButton> createState() => _AllinButtonState();
}

class _AllinButtonState extends State<AllinButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed == null || widget.loading) return;
    AppMotion.hapticLight();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null || widget.loading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: disabled ? null : widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          height: widget.height,
          child: AnimatedContainer(
            duration: AppMotion.normal,
            curve: AppMotion.easeOut,
            decoration: _getBoxDecoration(disabled),
            child: ClipRRect(
              borderRadius: Rad.rPill,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Barrido de destello metálico (Shimmer)
                  if (widget.enableShimmer &&
                      !disabled &&
                      (widget.variant == AllinButtonVariant.primary ||
                          widget.variant == AllinButtonVariant.gold))
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _shimmerCtrl,
                        builder: (context, _) {
                          return Transform.translate(
                            offset: Offset(
                              MediaQuery.of(context).size.width *
                                  (2.5 * _shimmerCtrl.value - 1.25),
                              0,
                            ),
                            child: Transform.rotate(
                              angle: 0.35,
                              child: Container(
                                width: 70,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.gradienteShimmer,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Contenido (Texto + Iconos o Spinner)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
                    child: widget.loading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getTextColor(disabled),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  size: 19,
                                  color: _getTextColor(disabled),
                                ),
                                const SizedBox(width: Sp.sm),
                              ],
                              Text(
                                widget.text,
                                style: AppText.button.copyWith(
                                  color: _getTextColor(disabled),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              if (widget.trailingIcon != null) ...[
                                const SizedBox(width: Sp.sm),
                                Icon(
                                  widget.trailingIcon,
                                  size: 19,
                                  color: _getTextColor(disabled),
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration(bool disabled) {
    if (disabled) {
      return BoxDecoration(
        color: AppColors.grafitoCarbon.withOpacity(0.6),
        borderRadius: Rad.rPill,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      );
    }

    switch (widget.variant) {
      case AllinButtonVariant.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.granateSagrado,
              AppColors.granate,
              AppColors.granateOscuro,
            ],
          ),
          borderRadius: Rad.rPill,
          border: Border.all(
            color: AppColors.oroSolar.withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            ...AppColors.glowGranate(intens: 0.45, blur: 18),
            if (_isPressed)
              ...AppColors.glowDorado(intens: 0.3, blur: 12),
          ],
        );

      case AllinButtonVariant.gold:
        return BoxDecoration(
          gradient: AppColors.gradienteDorado,
          borderRadius: Rad.rPill,
          border: Border.all(
            color: AppColors.oroReflejo.withOpacity(0.7),
            width: 1.2,
          ),
          boxShadow: AppColors.glowDorado(intens: 0.5, blur: 22),
        );

      case AllinButtonVariant.glass:
        return BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: Rad.rPill,
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        );

      case AllinButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: Rad.rPill,
          border: Border.all(
            color: AppColors.oroSolar.withOpacity(0.7),
            width: 1.4,
          ),
        );

      case AllinButtonVariant.danger:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB31217), Color(0xFFE52D27)],
          ),
          borderRadius: Rad.rPill,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }

  Color _getTextColor(bool disabled) {
    if (disabled) return Colors.white30;
    switch (widget.variant) {
      case AllinButtonVariant.primary:
        return AppColors.oroReflejo;
      case AllinButtonVariant.gold:
        return AppColors.granateOscuro;
      case AllinButtonVariant.glass:
        return Colors.white;
      case AllinButtonVariant.outline:
        return AppColors.oroSolar;
      case AllinButtonVariant.danger:
        return Colors.white;
    }
  }
}
