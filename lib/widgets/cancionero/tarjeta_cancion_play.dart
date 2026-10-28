// lib/widgets/cancionero/tarjeta_cancion_play.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/design.dart';
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
      onTap: () {
        HapticFeedback.lightImpact(); // Feedback háptico estilo Apple
        onTap();
      },
      child: AnimatedContainer(
        duration: Dur.normal,
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: reproduciendo ? AppColors.gradienteDorado : AppColors.gradienteGranate,
          borderRadius: Rad.rMd,
          boxShadow: [
            BoxShadow(
              color: (reproduciendo ? AppColors.dorado : AppColors.granate).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: cargando
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: AppColors.dorado, strokeWidth: 2.5),
              )
            : Icon(
                reproduciendo ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: reproduciendo ? AppColors.granate : AppColors.dorado,
                size: 28,
              ),
      ),
    );
  }
}