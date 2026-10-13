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
    this.logoSize = 90,
    this.rotation = -30,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // En modo oscuro el logo tiene fondo blanco y resalta más,
    // así que bajamos aún más la opacidad.
    final adjustedOpacity = isDark ? opacity * 0.35 : opacity;
    final screenSize = MediaQuery.of(context).size;

    // Contenedor GIGANTE: 3x la dimensión mayor para que al rotar
    // siga cubriendo las esquinas de la pantalla.
    final maxDim = math.max(screenSize.width, screenSize.height);
    final containerSize = maxDim * 3;

    // Cuántos logos caben en el contenedor (con +1 de margen).
    final cols = (containerSize / logoSize).ceil() + 1;
    final rows = (containerSize / logoSize).ceil() + 1;

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
                  width: containerSize,
                  height: containerSize,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: cols * rows,
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