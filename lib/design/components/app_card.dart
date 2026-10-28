// lib/design/components/app_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  final bool elevated;
  final bool glass;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.elevated = true,
    this.glass = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.color ??
        (isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.white.withOpacity(0.75));

    final effectiveColor = widget.color != null
        ? (widget.glass ? widget.color!.withOpacity(0.88) : widget.color!)
        : baseColor;

    final defaultBorder = Border.all(
      color: isDark
          ? Colors.white.withOpacity(0.12)
          : Colors.white.withOpacity(0.85),
      width: 1.1,
    );

    Widget cardContent = Container(
      padding: widget.padding ?? const EdgeInsets.all(Sp.lg),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: Rad.rLg,
        border: widget.border ?? defaultBorder,
        boxShadow: widget.elevated ? Elev.sm : null,
        gradient: widget.color == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.10),
                        Colors.white.withOpacity(0.04),
                      ]
                    : [
                        Colors.white.withOpacity(0.88),
                        Colors.white.withOpacity(0.65),
                      ],
              )
            : null,
      ),
      child: widget.child,
    );

    if (widget.glass) {
      cardContent = ClipRRect(
        borderRadius: Rad.rLg,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassBlur.subtle,
            sigmaY: GlassBlur.subtle,
          ),
          child: cardContent,
        ),
      );
    }

    if (widget.onTap == null) return cardContent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: Dur.fast,
        curve: Curves.easeOutCubic,
        child: cardContent,
      ),
    );
  }
}
