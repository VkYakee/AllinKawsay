import 'dart:math' as math;
import 'package:flutter/material.dart';

class WatermarkOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double logoSize;
  final double rotation;

  const WatermarkOverlay({
    super.key,
    required this.child,
    this.opacity = 0.05,
    this.logoSize = 150,
    this.rotation = -30,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // En modo oscuro el logo tiene fondo blanco y resalta más,
    // así que bajamos aún más la opacidad.
    final adjustedOpacity = isDark ? opacity * 0.35 : opacity;
    final screenSize = MediaQuery.of(context).size;

    final diagonal = math.sqrt(
      screenSize.width * screenSize.width +
          screenSize.height * screenSize.height,
    );
    final logosPerRow = (diagonal / logoSize).ceil() + 2;
    final logosPerColumn = (diagonal / logoSize).ceil() + 2;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: ClipRect(
            child: Center(
              child: Transform.rotate(
                angle: rotation * math.pi / 180,
                child: SizedBox(
                  width: diagonal * 1.5,
                  height: diagonal * 1.5,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: logosPerRow,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: logosPerRow * logosPerColumn,
                    itemBuilder: (context, index) {
                      return Opacity(
                        opacity: adjustedOpacity,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}