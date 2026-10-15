import 'package:flutter/material.dart';

/// Marca de agua simple: un solo logo circular centrado con baja opacidad.
/// Cero lag (1 solo widget por pantalla) y estéticamente más limpia.
class WatermarkOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double logoSize;

  const WatermarkOverlay({
    super.key,
    required this.child,
    this.opacity = 0.06,
    this.logoSize = 260,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // En modo oscuro el logo tiene fondo blanco y resalta más,
    // así que bajamos aún más la opacidad.
    final ajustada = isDark ? opacity * 0.35 : opacity;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: Center(
            child: Opacity(
              opacity: ajustada,
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}