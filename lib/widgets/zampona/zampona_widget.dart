// lib/widgets/zampona/zampona_widget.dart
import 'package:flutter/material.dart';
import '../../data/zampona_catalogo.dart';
import '../../models/zampona_nota.dart';
import '../../theme/colors.dart';

class ZamponaWidget extends StatelessWidget {
  final Set<String> brillando;
  final void Function(ZamponaNota)? onTapNota;
  final void Function(ZamponaNota)? onReleaseNota;

  const ZamponaWidget({
    super.key,
    this.brillando = const {},
    this.onTapNota,
    this.onReleaseNota,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) {
        const separacion = 3.0;
        final disponible = cons.maxWidth - (separacion * 6) - 24;
        final maxPorAltura = (cons.maxHeight - 20) / 2.2;
        final diametro = (disponible / 7) < maxPorAltura ? (disponible / 7) : maxPorAltura;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _fila(notasFila7, diametro, separacion),
              const SizedBox(height: 6),
              _liston(diametro, separacion),
              const SizedBox(height: 6),
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
            child: _Tubo(
              nota: nota,
              diametro: diametro,
              brillando: brillando.contains(nota.id),
              onTap: onTapNota == null ? null : () => onTapNota!(nota),
              onRelease: onReleaseNota == null ? null : () => onReleaseNota!(nota),
            ),
          ),
      ],
    );
  }

  Widget _liston(double diametro, double sep) {
    return Container(
      height: 8,
      width: diametro * 7 + sep * 6,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.dorado.withOpacity(0.2), width: 0.5),
      ),
    );
  }
}

class _Tubo extends StatelessWidget {
  final ZamponaNota nota;
  final double diametro;
  final bool brillando;
  final VoidCallback? onTap;
  final VoidCallback? onRelease;

  const _Tubo({
    required this.nota,
    required this.diametro,
    required this.brillando,
    this.onTap,
    this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    final contenido = AnimatedScale(
      scale: brillando ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: diametro, height: diametro,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: brillando
                ? [const Color(0xFFFFE066), AppColors.dorado, AppColors.doradoOscuro]
                : [const Color(0xFF2A0308), AppColors.granateOscuro, const Color(0xFF0A0103)],
            stops: const [0.0, 0.6, 1.0],
            center: const Alignment(-0.3, -0.3), // Simula la luz superior
          ),
          border: Border.all(
            color: brillando ? AppColors.doradoClaro : AppColors.granateClaro,
            width: brillando ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 8,
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
              color: brillando ? AppColors.granateOscuro : AppColors.dorado.withOpacity(0.8),
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

    if (onTap == null) return contenido;
    return GestureDetector(
      onTapDown: (_) => onTap!(),
      onTapUp: onRelease == null ? null : (_) => onRelease!(),
      onTapCancel: onRelease,
      behavior: HitTestBehavior.opaque,
      child: contenido,
    );
  }
}