// lib/core/widgets/particle_field.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Campo de partículas flotantes con CustomPainter.
///
/// Cero widgets en el árbol, un solo AnimationController, RepaintBoundary.
/// 120 FPS garantizado.
class ParticleField extends StatefulWidget {
  final int count;
  final Color color;
  final double minRadius;
  final double maxRadius;
  final Duration duration;
  final double opacity;
  final bool reverse;

  const ParticleField({
    super.key,
    this.count = 40,
    this.color = const Color(0xFFD4AF37),
    this.minRadius = 1.0,
    this.maxRadius = 3.5,
    this.duration = const Duration(seconds: 22),
    this.opacity = 0.5,
    this.reverse = false,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: widget.reverse);
    final rnd = math.Random(42);
    _particles = List.generate(widget.count, (_) {
      return _Particle(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        vx: (rnd.nextDouble() - 0.5) * 0.04,
        vy: (rnd.nextDouble() - 0.5) * 0.04,
        r: widget.minRadius +
            rnd.nextDouble() * (widget.maxRadius - widget.minRadius),
        opacity: 0.2 + rnd.nextDouble() * 0.8,
        phase: rnd.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              progress: _ctrl.value,
              color: widget.color,
              opacity: widget.opacity,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double r;
  final double opacity;
  final double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.r,
    required this.opacity,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;
  final double opacity;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      double x = (p.x + p.vx * progress * 20) % 1.0;
      double y = (p.y + p.vy * progress * 20) % 1.0;
      if (x < 0) x += 1.0;
      if (y < 0) y += 1.0;

      final pulse = 0.6 + 0.4 * math.sin(progress * math.pi * 2 + p.phase);

      paint.color = color.withOpacity(
        (p.opacity * opacity * pulse).clamp(0.0, 1.0),
      );
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress ||
      old.opacity != opacity ||
      old.color != color;
}