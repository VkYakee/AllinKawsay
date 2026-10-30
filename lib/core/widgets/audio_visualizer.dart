// lib/core/widgets/audio_visualizer.dart
//
// Visualizador de audio élite con CustomPainter.
// Dos modos:
//   - AudioVisualizer: tira de ondas animadas (para mini-player o fondo).
//   - MiniEqualizer: barras pequeñas para el icono del mini-player.
//
// Cumple con 120 FPS porque:
//   - Usa RepaintBoundary para aislar el repintado.
//   - Un solo AnimationController por instancia.
//   - CustomPainter con shouldRepaint estricto.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design/colors.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color? color;
  final double height;
  final int barCount;
  final double barWidth;
  final double gap;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.color,
    this.height = 40,
    this.barCount = 32,
    this.barWidth = 3,
    this.gap = 2,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isPlaying) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.isPlaying && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.dorado;
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return CustomPaint(
              painter: _BarsPainter(
                progress: _ctrl.value,
                playing: widget.isPlaying,
                color: color,
                barCount: widget.barCount,
                barWidth: widget.barWidth,
                gap: widget.gap,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  final double progress;
  final bool playing;
  final Color color;
  final int barCount;
  final double barWidth;
  final double gap;

  _BarsPainter({
    required this.progress,
    required this.playing,
    required this.color,
    required this.barCount,
    required this.barWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final totalWidth = barCount * barWidth + (barCount - 1) * gap;
    final startX = (size.width - totalWidth) / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final centerY = size.height / 2;
    final t = progress * math.pi * 2;

    for (int i = 0; i < barCount; i++) {
      final phase = (i / barCount) * math.pi * 2;
      double amp;
      if (playing) {
        final a = 0.5 + 0.5 * math.sin(t * 1.2 + phase * 2.1);
        final b = 0.6 + 0.4 * math.sin(t * 0.7 + phase);
        amp = 0.35 + 0.65 * a * b;
        amp = amp.clamp(0.15, 1.0);
      } else {
        amp = 0.1 + 0.05 * math.sin(phase);
      }

      final h = (size.height * amp).clamp(2.0, size.height);
      final x = startX + i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, centerY - h / 2, barWidth, h),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.progress != progress ||
      old.playing != playing ||
      old.color != color ||
      old.barCount != barCount ||
      old.barWidth != barWidth ||
      old.gap != gap;
}

// ═══════════════════════════════════════════════════════════
// MINI EQUALIZER — para el icono del MiniPlayer
// ═══════════════════════════════════════════════════════════

class MiniEqualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double size;
  final int barCount;

  const MiniEqualizer({
    super.key,
    required this.isPlaying,
    this.color = AppColors.dorado,
    this.size = 20,
    this.barCount = 3,
  });

  @override
  State<MiniEqualizer> createState() => _MiniEqualizerState();
}

class _MiniEqualizerState extends State<MiniEqualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isPlaying) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant MiniEqualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isPlaying && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return CustomPaint(
              painter: _MiniEqPainter(
                progress: _ctrl.value,
                playing: widget.isPlaying,
                color: widget.color,
                barCount: widget.barCount,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiniEqPainter extends CustomPainter {
  final double progress;
  final bool playing;
  final Color color;
  final int barCount;

  _MiniEqPainter({
    required this.progress,
    required this.playing,
    required this.color,
    required this.barCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final barWidth = size.width / (barCount * 2 - 1);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      double amp;
      if (playing) {
        final phase = i * 0.8;
        amp = 0.25 +
            0.75 *
                (0.5 +
                    0.5 *
                        math.sin(progress * math.pi * 2 + phase));
        amp = amp.clamp(0.2, 1.0);
      } else {
        amp = 0.25 + 0.05 * i;
      }

      final h = (size.height * amp).clamp(2.0, size.height);
      final x = i * barWidth * 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, centerY - h / 2, barWidth, h),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniEqPainter old) =>
      old.progress != progress ||
      old.playing != playing ||
      old.color != color;
}