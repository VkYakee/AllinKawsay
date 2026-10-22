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
              const SizedBox(height: 4),
              _liston(diametro, separacion),
              const SizedBox(height: 4),
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
          colors: [Color(0xFF2A0308), AppColors.granateOscuro, Color(0xFF2A0308)],
        ),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.dorado.withOpacity(0.35), width: 0.7),
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
      scale: brillando ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        width: diametro, height: diametro,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: brillando
                ? [const Color(0xFF0A0103), const Color(0xFF1A0205), AppColors.granate, AppColors.dorado]
                : [const Color(0xFF0A0103), const Color(0xFF1A0205), const Color(0xFF3A0810), AppColors.granateClaro],
            stops: const [0.0, 0.35, 0.78, 1.0],
          ),
          border: Border.all(color: brillando ? AppColors.dorado : AppColors.dorado.withOpacity(0.35), width: brillando ? 2 : 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.85), blurRadius: 5, offset: const Offset(0, 2)),
            if (brillando) BoxShadow(color: AppColors.dorado.withOpacity(0.7), blurRadius: 16, spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Text(
            '${nota.posicion}',
            style: TextStyle(
              color: brillando ? AppColors.dorado : AppColors.dorado.withOpacity(0.6),
              fontWeight: FontWeight.bold,
              fontSize: diametro * 0.32,
              height: 1.0,
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