// lib/core/widgets/zampona_canvas.dart
//
// Zampoña dibujada con CustomPainter real.
//
// Ventajas frente al widget anterior (13 AnimatedContainer):
//   - 1 solo CustomPaint en el árbol (antes 13 widgets + 13 controllers).
//   - HitTest manual sobre las coordenadas del canvas (antes: 13 GestureDetectors).
//   - Partículas al tocar (feedback visual de "soplo").
//   - Repaint aislado con RepaintBoundary.
//   - Sin jank: el painter corre a 60/120 fps sin rebuild del árbol.
//
// API:
//   brillando        → Set<String> con ids de notas que deben brillar.
//   onTapNota        → callback al tocar un tubo.
//   onReleaseNota    → callback al soltar (modo pulsado).
//   mostrarNumeros   → default true. En ensayo se puede apagar.
//   compacto         → default false. Reduce padding vertical.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../data/zampona_catalogo.dart';
import '../../models/zampona_nota.dart';
import '../design/colors.dart';

class ZamponaCanvas extends StatefulWidget {
  final Set<String> brillando;
  final void Function(ZamponaNota)? onTapNota;
  final void Function(ZamponaNota)? onReleaseNota;
  final bool mostrarNumeros;
  final bool compacto;

  const ZamponaCanvas({
    super.key,
    this.brillando = const {},
    this.onTapNota,
    this.onReleaseNota,
    this.mostrarNumeros = true,
    this.compacto = false,
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
      duration: const Duration(milliseconds: 900),
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
        p.vy += 20 * 0.016; // gravedad suave
        p.vida -= 0.016;
        if (p.vida <= 0) _particulas.removeAt(i);
      }
    });
    if (_particulas.isEmpty && _particlesCtrl.isAnimating) {
      _particlesCtrl.stop();
    }
  }

  void _dispararParticulas(Offset centro, double radio) {
    final cantidad = 5 + _rnd.nextInt(4);
    for (int i = 0; i < cantidad; i++) {
      final angulo = -math.pi / 2 + (_rnd.nextDouble() - 0.5) * 1.2;
      final velocidad = 60 + _rnd.nextDouble() * 60;
      _particulas.add(_Particula(
        x: centro.dx + (_rnd.nextDouble() - 0.5) * radio,
        y: centro.dy,
        vx: math.cos(angulo) * velocidad,
        vy: math.sin(angulo) * velocidad,
        radio: 1.5 + _rnd.nextDouble() * 2.0,
        vida: 0.6 + _rnd.nextDouble() * 0.3,
        vidaMax: 0.9,
        color: AppColors.dorado,
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
        final layout = _calcularLayout(
          Size(constraints.maxWidth, constraints.maxHeight),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            final nota = layout.hitTest(details.localPosition);
            if (nota != null) {
              final tubo = layout.tuboDe(nota.id);
              if (tubo != null) _dispararParticulas(tubo.centro, tubo.radio);
              widget.onTapNota?.call(nota);
            }
          },
          onTapUp: widget.onReleaseNota == null
              ? null
              : (details) {
                  final nota = layout.hitTest(details.localPosition);
                  if (nota != null) widget.onReleaseNota?.call(nota);
                },
          onTapCancel: widget.onReleaseNota == null
              ? null
              : () {
                  // No hay nota tocada actual: no hacemos nada.
                  // El release real se maneja en onTapUp.
                },
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particlesCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ZamponaPainter(
                    layout: layout,
                    brillando: widget.brillando,
                    particulas: List.unmodifiable(_particulas),
                    mostrarNumeros: widget.mostrarNumeros,
                  ),
                  size: Size.infinite,
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
    const paddingH = 20.0;
    final paddingV = widget.compacto ? 6.0 : 16.0;

    final disponible = size.width - paddingH * 2;
    final alturaUtil = size.height - paddingV * 2;

    // Cada tubo de la fila 7 más un pequeño gap vertical + listón.
    // relación alta/ancho = 2.4 (2 filas + listón)
    final maxPorAltura = alturaUtil / 2.4;
    final maxPorAncho = (disponible - sep * 6) / 7;
    final diametro = math.min(maxPorAncho, maxPorAltura);

    final anchoFila7 = 7 * diametro + 6 * sep;
    final anchoFila6 = 6 * diametro + 5 * sep;
    final altoTubo = diametro;
    final listonAlto = 10.0;
    final gapVertical = 8.0;

    final altoTotal = 2 * altoTubo + 2 * gapVertical + listonAlto;
    final top = (size.height - altoTotal) / 2;

    final fila7 = <_TuboLayout>[];
    final notas7 = notasFila7;
    final xInicio7 = (size.width - anchoFila7) / 2 + diametro / 2;
    final y7 = top + diametro / 2;
    for (int i = 0; i < notas7.length; i++) {
      fila7.add(_TuboLayout(
        nota: notas7[i],
        centro: Offset(xInicio7 + i * (diametro + sep), y7),
        radio: diametro / 2,
      ));
    }

    final fila6 = <_TuboLayout>[];
    final notas6 = notasFila6;
    final xInicio6 = (size.width - anchoFila6) / 2 + diametro / 2;
    final y6 = top + diametro + 2 * gapVertical + listonAlto + diametro / 2;
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

    return _ZamponaLayout(fila7: fila7, fila6: fila6, liston: listonRect);
  }
}
// ═══════════════════════════════════════════════════════════
// LAYOUT INTERNO
// ═══════════════════════════════════════════════════════════

class _ZamponaLayout {
  final List<_TuboLayout> fila7;
  final List<_TuboLayout> fila6;
  final Rect liston;

  const _ZamponaLayout({
    required this.fila7,
    required this.fila6,
    required this.liston,
  });

  ZamponaNota? hitTest(Offset p) {
    for (final t in fila7) {
      if ((p - t.centro).distance <= t.radio * 1.15) return t.nota;
    }
    for (final t in fila6) {
      if ((p - t.centro).distance <= t.radio * 1.15) return t.nota;
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
  final double radio;
  double vida;
  final double vidaMax;
  final Color color;

  _Particula({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radio,
    required this.vida,
    required this.vidaMax,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════════
// PAINTER
// ═══════════════════════════════════════════════════════════

class _ZamponaPainter extends CustomPainter {
  final _ZamponaLayout layout;
  final Set<String> brillando;
  final List<_Particula> particulas;
  final bool mostrarNumeros;

  _ZamponaPainter({
    required this.layout,
    required this.brillando,
    required this.particulas,
    required this.mostrarNumeros,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _dibujarListon(canvas);

    for (final t in layout.fila7) {
      _dibujarTubo(canvas, t);
    }
    for (final t in layout.fila6) {
      _dibujarTubo(canvas, t);
    }

    for (final p in particulas) {
      final vidaNorm = (p.vida / p.vidaMax).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withOpacity(vidaNorm * 0.75)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(p.x, p.y), p.radio, paint);
    }
  }

  void _dibujarListon(Canvas canvas) {
    final r = layout.liston;
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(5));

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF1A0205),
          Color(0xFF2A0308),
          Color(0xFF1A0205),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(r);
    canvas.drawRRect(rr, paint);

    final borde = Paint()
      ..color = AppColors.dorado.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(rr, borde);
  }

  void _dibujarTubo(Canvas canvas, _TuboLayout tubo) {
    final brillo = brillando.contains(tubo.nota.id);
    final escala = brillo ? 1.12 : 1.0;
    final radio = tubo.radio * escala;
    final centro = tubo.centro;

    // 1. Sombra externa
    final sombraPaint = Paint()
      ..color = Colors.black.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(centro + const Offset(0, 4), radio, sombraPaint);

    // 2. Glow si brilla
    if (brillo) {
      final glowPaint = Paint()
        ..color = AppColors.dorado.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(centro, radio * 1.4, glowPaint);
    }

    // 3. Cuerpo del tubo — gradiente radial para 3D
    final rect = Rect.fromCircle(center: centro, radius: radio);
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 1.0,
        colors: brillo
            ? const [
                Color(0xFFFFF3B0),
                Color(0xFFE8C86A),
                AppColors.doradoOscuro,
                Color(0xFF3A0810),
              ]
            : const [
                Color(0xFF4A151E),
                Color(0xFF2A0308),
                Color(0xFF1A0205),
                Color(0xFF0A0103),
              ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(rect);
    canvas.drawCircle(centro, radio, bodyPaint);

    // 4. Borde exterior
    final bordePaint = Paint()
      ..color = brillo
          ? AppColors.doradoClaro
          : AppColors.granateClaro.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = brillo ? 2.2 : 1.2;
    canvas.drawCircle(centro, radio, bordePaint);

    // 5. Aro interior (boca del tubo)
    final aroPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(centro, radio * 0.68, aroPaint);

    // 6. Brillo especular superior
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(brillo ? 0.5 : 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(
      centro + Offset(-radio * 0.25, -radio * 0.3),
      radio * 0.25,
      highlightPaint,
    );

    // 7. Número
    if (mostrarNumeros) {
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
            shadows: brillo
                ? null
                : [
                    const Shadow(
                      color: Colors.black87,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, centro - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _ZamponaPainter old) =>
      old.brillando != brillando ||
      old.particulas.length != particulas.length ||
      old.mostrarNumeros != mostrarNumeros;
}