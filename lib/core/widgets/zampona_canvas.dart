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
