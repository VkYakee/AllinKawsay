// lib/features/zampona/widgets/zampona_canvas.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../data/zampona_catalogo.dart';
import '../../../models/zampona_nota.dart';

/// Zampoña dibujada con CustomPainter real:
/// - Tubos con sombra y gradiente radial (efecto 3D).
/// - Partículas que salen al tocar (puff de aire).
/// - Glow + escala al brillar la nota.
/// - hitTest manual sin widgets encima (120 fps).
class ZamponaCanvas extends StatefulWidget {
  final Set<String> brillando;
  final void Function(ZamponaNota)? onTapNota;
  final void Function(ZamponaNota)? onReleaseNota;

  const ZamponaCanvas({
    super.key,
    this.brillando = const {},
    this.onTapNota,
    this.onReleaseNota,
  });

  @override
  State<ZamponaCanvas> createState() => _ZamponaCanvasState();
}

class _ZamponaCanvasState extends State<ZamponaCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particlesCtrl;
  final List<_Particula> _particulas = [];
  final _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _particlesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _particlesCtrl.addListener(_tickParticulas);
  }

  void _tickParticulas() {
    if (!mounted) return;
    setState(() {
      for (int i = _particulas.length - 1; i >= 0; i--) {
        final p = _particulas[i];
        p.x += p.vx * 0.016;
        p.y += p.vy * 0.016;
        p.vida -= 0.016;
        if (p.vida <= 0) _particulas.removeAt(i);
      }
    });
    if (_particulas.isEmpty && _particlesCtrl.isAnimating) {
      _particlesCtrl.stop();
    }
  }

  void _dispararParticula(Offset centro) {
    for (int i = 0; i < 6; i++) {
      _particulas.add(_Particula(
        x: centro.dx,
        y: centro.dy,
        vx: (_rnd.nextDouble() - 0.5) * 80,
        vy: -30 - _rnd.nextDouble() * 60,
        radio: 1.5 + _rnd.nextDouble() * 2.5,
        vida: 0.5 + _rnd.nextDouble() * 0.4,
        color: AppColors.dorado.withOpacity(0.6),
      ));
    }
    if (!_particlesCtrl.isAnimating) {
      _particlesCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _particlesCtrl.removeListener(_tickParticulas);
    _particlesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final layout = _calcularLayout(size);

        return GestureDetector(
          onTapDown: (details) {
            final nota = layout.hitTest(details.localPosition);
            if (nota != null) {
              widget.onTapNota?.call(nota);
              final tubo = layout.tuboDe(nota.id);
              if (tubo != null) _dispararParticula(tubo.centro);
            }
          },
          onTapUp: widget.onReleaseNota == null
              ? null
              : (_) {
                  // Suelta la última tocada
                },
          onTapCancel: widget.onReleaseNota == null
              ? null
              : () {},
          behavior: HitTestBehavior.opaque,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particlesCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ZamponaPainter(
                    layout: layout,
                    brillando: widget.brillando,
                    particulas: List.unmodifiable(_particulas),
                  ),
                  size: size,
                );
              },
            ),
          ),
        );
      },
    );
  }

  _ZamponaLayout _calcularLayout(Size size) {
    const sep = 6.0;
    final disponible = size.width - (sep * 6) - 32;
    final maxPorAltura = (size.height - 40) / 2.4;
    final diametro = math.min(disponible / 7, maxPorAltura);
    final anchoFila7 = 7 * diametro + 6 * sep;
    final anchoFila6 = 6 * diametro + 5 * sep;
    final centroY = size.height / 2;
    final listonAlto = 12.0;
    final gapVertical = 10.0;

    final altoTotal = 2 * diametro + 2 * gapVertical + listonAlto;
    final top = (size.height - altoTotal) / 2;

    final fila7 = <_TuboLayout>[];
    final xInicio7 = (size.width - anchoFila7) / 2 + diametro / 2;
    final y7 = top + diametro / 2;
    final notas7 = notasFila7;
    for (int i = 0; i < notas7.length; i++) {
      fila7.add(_TuboLayout(
        nota: notas7[i],
        centro: Offset(xInicio7 + i * (diametro + sep), y7),
        radio: diametro / 2,
      ));
    }

    final y6 = top + diametro + gapVertical * 2 + listonAlto + diametro / 2;
    final fila6 = <_TuboLayout>[];
    final xInicio6 = (size.width - anchoFila6) / 2 + diametro / 2;
    final notas6 = notasFila6;
    for (int i = 0; i < notas6.length; i++) {
      fila6.add(_TuboLayout(
        nota: notas6[i],
        centro: Offset(xInicio6 + i * (diametro + sep), y6),
        radio: diametro / 2,
      ));
    }

    final listonRect = Rect.fromLTWH(
      (size.width - anchoFila7) / 2,
      top + diametro + gapVertical,
      anchoFila7,
      listonAlto,
    );

    return _ZamponaLayout(
      fila7: fila7,
      fila6: fila6,
      liston: listonRect,
      centroY: centroY,
    );
  }
}

class _ZamponaLayout {
  final List<_TuboLayout> fila7;
  final List<_TuboLayout> fila6;
  final Rect liston;
  final double centroY;

  const _ZamponaLayout({
    required this.fila7,
    required this.fila6,
    required this.liston,
    required this.centroY,
  });

  ZamponaNota? hitTest(Offset p) {
    for (final t in fila7) {
      if ((p - t.centro).distance <= t.radio) return t.nota;
    }
    for (final t in fila6) {
      if ((p - t.centro).distance <= t.radio) return t.nota;
    }
    return null;
  }

  _TuboLayout? tuboDe(String id) {
    for (final t in fila7) {
      if (t.nota.id == id) return t;
    }
    for (final t in fila6) {
      if (t.nota.id == id) return t;
    }
    return null;
  }
}

class _TuboLayout {
  final ZamponaNota nota;
  final Offset centro;
  final double radio;

  const _TuboLayout({
    required this.nota,
    required this.centro,
    required this.radio,
  });
}

class _Particula {
  double x;
  double y;
  double vx;
  double vy;
  double radio;
  double vida;
  Color color;

  _Particula({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radio,
    required this.vida,
    required this.color,
  });
}

class _ZamponaPainter extends CustomPainter {
  final _ZamponaLayout layout;
  final Set<String> brillando;
  final List<_Particula> particulas;

  _ZamponaPainter({
    required this.layout,
    required this.brillando,
    required this.particulas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Listón conector
    _dibujarListon(canvas);

    // Fila 7
    for (final t in layout.fila7) {
      _dibujarTubo(canvas, t);
    }
    // Fila 6
    for (final t in layout.fila6) {
      _dibujarTubo(canvas, t);
    }
    // Partículas
    for (final p in particulas) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.vida.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(p.x, p.y), p.radio, paint);
    }
  }

  void _dibujarListon(Canvas canvas) {
    final r = layout.liston;
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(6));
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2A0308), Color(0xFF0A0103), Color(0xFF2A0308)],
      ).createShader(r);
    canvas.drawRRect(rr, paint);

    final border = Paint()
      ..color = AppColors.dorado.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rr, border);
  }

  void _dibujarTubo(Canvas canvas, _TuboLayout tubo) {
    final brillo = brillando.contains(tubo.nota.id);
    final escala = brillo ? 1.12 : 1.0;
    final radio = tubo.radio * escala;
    final centro = tubo.centro;

    // Sombra externa
    final sombraPaint = Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(centro + const Offset(0, 5), radio, sombraPaint);

    // Glow cuando brilla
    if (brillo) {
      final glowPaint = Paint()
        ..color = AppColors.dorado.withOpacity(0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(centro, radio * 1.35, glowPaint);
    }

    // Cuerpo del tubo — gradiente radial para 3D
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 1.0,
        colors: brillo
            ? const [
                Color(0xFFFFF3B0),
                Color(0xFFE8C86A),
                AppColors.doradoOscuro,
                Color(0xFF2A0308),
              ]
            : const [
                Color(0xFF4A151E),
                Color(0xFF1A0205),
                Color(0xFF0A0103),
                Color(0xFF000000),
              ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: centro, radius: radio));
    canvas.drawCircle(centro, radio, bodyPaint);

    // Borde
    final bordePaint = Paint()
      ..color = brillo
          ? AppColors.doradoClaro
          : AppColors.granateClaro.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = brillo ? 2.5 : 1.5;
    canvas.drawCircle(centro, radio, bordePaint);

    // Aro interior (boca del tubo)
    final aroPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(centro, radio * 0.7, aroPaint);

    // Número de posición
    final tp = TextPainter(
      text: TextSpan(
        text: '${tubo.nota.posicion}',
        style: TextStyle(
          color: brillo
              ? AppColors.granateOscuro
              : AppColors.dorado.withOpacity(0.75),
          fontWeight: FontWeight.bold,
          fontSize: radio * 0.8,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      centro - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ZamponaPainter old) =>
      old.brillando != brillando ||
      old.particulas.length != particulas.length ||
      old.layout != layout;
}