// lib/widgets/cancionero/tarjeta_cancion_play.dart
import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../../theme/colors.dart';

class TarjetaCancionPlay extends StatelessWidget {
  final bool reproduciendo;
  final bool cargando;
  final VoidCallback onTap;

  const TarjetaCancionPlay({
    super.key,
    required this.reproduciendo,
    required this.cargando,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: reproduciendo
              ? AppColors.gradienteDorado
              : AppColors.gradienteGranate,
          borderRadius: Rad.rMd,
        ),
        child: cargando
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: AppColors.dorado,
                  strokeWidth: 2.5,
                ),
              )
            : Icon(
                reproduciendo
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: reproduciendo
                    ? AppColors.granate
                    : AppColors.dorado,
                size: 26,
              ),
      ),
    );
  }
}