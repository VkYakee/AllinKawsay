// lib/core/components/app_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/motion.dart';
import '../design/tokens.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  final bool glass;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.glass = false,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Container(
      padding: widget.padding ?? const EdgeInsets.all(Sp.lg),
      decoration: BoxDecoration(
        // Si es glass, usamos el tinte vino. Si no, el color de superficie.
        color: widget.color ?? (widget.glass ? AppColors.glassFill(context) : AppColors.surface(context)),
        borderRadius: Rad.rLg,
        // Borde brillante para el cristal, o sutil para las tarjetas normales
        border: widget.border ?? Border.all(
          color: widget.glass ? AppColors.glassBorder(context) : (isDark ? Colors.white10 : Colors.black12),
          width: 1.5, // Borde un poco más grueso para que se note el cristal
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.glass) {
      // Para que el cristal se vea real, el blur debe ser alto y tener un gradiente interno
      content = ClipRRect(
        borderRadius: Rad.rLg,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: Rad.rLg,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(isDark ? 0.05 : 0.4),
                  Colors.transparent,
                ],
              ),
            ),
            child: content,
          ),
        ),
      );
    }

    if (widget.onTap == null) return content;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        AppMotion.hapticLight();
        widget.onTap!();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: content,
      ),
    );
  }
}