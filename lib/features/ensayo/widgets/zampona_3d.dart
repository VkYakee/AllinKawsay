// lib/features/ensayo/widgets/zampona_3d.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../data/zampona_catalogo.dart';
import '../../../models/zampona_nota.dart';

class Zampona3D extends StatelessWidget {
  final Set<String> brillando;

  const Zampona3D({super.key, this.brillando = const {}});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) {
        const separacion = 4.0;
        final disponible = cons.maxWidth - (separacion * 6) - 24;
        final maxPorAltura = (cons.maxHeight - 20) / 2.2;
        final diametro = (disponible / 7) < maxPorAltura ? (disponible / 7) : maxPorAltura;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _fila(notasFila7, diametro, separacion),
              const SizedBox(height: 8),
              _liston(diametro, separacion),
              const SizedBox(height: 8),
              _fila(notasFila6, diametro, separacion),
            ],
          ),
        );
      },
    );
  }

  Widget _fila(List<ZamponaNota> notas, double diametro, double sep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final nota in notas)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sep / 2),
            child: _Tubo3D(
              nota: nota,
              diametro: diametro,
              brillando: brillando.contains(nota.id),
            ),
          ),
      ],
    );
  }

  Widget _liston(double diametro, double sep) {
    return Container(
      height: 14,
      width: diametro * 7 + sep * 6,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A0D), Color(0xFF2A0308), Color(0xFF1A0A0D)],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.dorado.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
    );
  }
}

class _Tubo3D extends StatelessWidget {
  final ZamponaNota nota;
  final double diametro;
  final bool brillando;

  const _Tubo3D({
    required this.nota,
    required this.diametro,
    required this.brillando,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: brillando ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: diametro,
        height: diametro,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3), // Simula la luz desde arriba a la izquierda
            colors: brillando
                ? [
                    const Color(0xFFFFF3B0), // Centro brillante
                    AppColors.dorado,
                    AppColors.doradoOscuro,
                    const Color(0xFF3A0810),
                  ]
                : [
                    const Color(0xFF4A151E),
                    AppColors.granateOscuro,
                    const Color(0xFF1A0205),
                    const Color(0xFF0A0103),
                  ],
            stops: const [0.0, 0.4, 0.8, 1.0],
          ),
          border: Border.all(
            color: brillando ? AppColors.doradoClaro : AppColors.granateClaro.withOpacity(0.5),
            width: brillando ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
            if (brillando)
              BoxShadow(
                color: AppColors.dorado.withOpacity(0.8),
                blurRadius: 24,
                spreadRadius: 4,
              ),
          ],
        ),
        child: Center(
          child: Text(
            '${nota.posicion}',
            style: TextStyle(
              color: brillando ? AppColors.granateOscuro : AppColors.dorado.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: diametro * 0.35,
              height: 1.0,
              shadows: [
                if (!brillando) Shadow(color: Colors.black87, blurRadius: 4, offset: const Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}