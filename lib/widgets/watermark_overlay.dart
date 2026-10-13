import 'dart:math' as math;
import 'package:flutter/material.dart';

class WatermarkOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double logoSize;
  final double spacing;

  const WatermarkOverlay({
    super.key,
    required this.child,
    this.opacity = 0.06,
    this.logoSize = 120,
    this.spacing = 80,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adjustedOpacity = isDark ? opacity * 1.5 : opacity;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: CustomPaint(
            painter: _WatermarkPainter(
              opacity: adjustedOpacity,
              logoSize: logoSize,
              spacing: spacing,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}