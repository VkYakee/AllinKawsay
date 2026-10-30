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
  final bool glass; // Efecto cristal esmerilado

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
        color: widget.color ?? (widget.glass ? AppColors.glassFill(context) : AppColors.surface(context)),
        borderRadius: Rad.rLg,
        border: widget.border ?? Border.all(
          color: widget.glass ? AppColors.glassBorder(context) : AppColors.dorado.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.glass) {
      content = ClipRRect(
        borderRadius: Rad.rLg,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: content,
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