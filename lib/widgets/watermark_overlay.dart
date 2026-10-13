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
class _WatermarkPainter extends CustomPainter {
  final double opacity;
  final double logoSize;
  final double spacing;

  _WatermarkPainter({
    required this.opacity,
    required this.logoSize,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..filterQuality = FilterQuality.medium;

    final rotationAngle = -30 * math.pi / 180; // -30 grados

    // Calcular cuántos logos caben en la pantalla
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);
    final stepX = logoSize + spacing;
    final stepY = logoSize + spacing;

    // Extender el área de dibujo para cubrir toda la pantalla después de rotar
    final extendedWidth = diagonal + logoSize * 2;
    final extendedHeight = diagonal + logoSize * 2;

    canvas.save();
    
    // Mover al centro y rotar
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotationAngle);
    canvas.translate(-extendedWidth / 2, -extendedHeight / 2);

    // Dibujar patrón de logos
    for (double y = -logoSize; y < extendedHeight; y += stepY) {
      for (double x = -logoSize; x < extendedWidth; x += stepX) {
        _drawLogo(canvas, x, y, paint);
      }
    }

    canvas.restore();
  }

  void _drawLogo(Canvas canvas, double x, double y, Paint paint) {
    final rect = Rect.fromLTWH(x, y, logoSize, logoSize);
    
    // Dibujar círculo de fondo sutil
    canvas.drawCircle(
      Offset(x + logoSize / 2, y + logoSize / 2),
      logoSize / 2,
      paint,
    );

    // Dibujar borde del círculo
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(
      Offset(x + logoSize / 2, y + logoSize / 2),
      logoSize / 2,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}