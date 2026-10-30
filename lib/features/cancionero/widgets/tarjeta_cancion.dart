// lib/features/cancionero/widgets/tarjeta_cancion.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/cancion.dart';
import '../../../services/player_service.dart';

class TarjetaCancion extends StatelessWidget {
  final Cancion cancion;
  final bool esFavorito;
  final EstadoPlayer estado;
  final VoidCallback onTap;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleFavorito;

  const TarjetaCancion({
    super.key,
    required this.cancion,
    required this.esFavorito,
    required this.estado,
    required this.onTap,
    required this.onTogglePlay,
    required this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);
    final sonando = estado.cancionId == cancion.id;
    final reproduciendo = sonando && estado.playing;
    final cargando = sonando && estado.cargando;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.xs),
      child: AppCard(
        glass: true,
        padding: const EdgeInsets.all(Sp.md),
        onTap: onTap,
        border: sonando 
            ? Border.all(color: AppColors.dorado.withOpacity(0.6), width: 1.5) 
            : Border.all(color: AppColors.dorado.withOpacity(0.15), width: 1),
        child: Row(
          children: [
            // Botón de Play (con física de resorte)
            GestureDetector(
              onTap: () {
                AppMotion.hapticLight();
                onTogglePlay();
              },
              child: AnimatedContainer(
                duration: AppMotion.fast,
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
            ),
            const SizedBox(width: Sp.md),
            
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cancion.titulo,
                    style: AppText.title.copyWith(color: onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cancion.ritmo}${cancion.autor.isNotEmpty ? ' · ${cancion.autor}' : ''}',
                    style: AppText.captionXs.copyWith(color: onSurface.withOpacity(0.55)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Sp.sm),
                  Row(
                    children: [
                      if (cancion.tieneNumerofonia) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.dorado.withOpacity(0.15),
                            borderRadius: Rad.rPill,
                          ),
                          child: Text('Partitura', style: AppText.captionXs.copyWith(color: AppColors.doradoOscuro, fontSize: 9)),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.1),
                          borderRadius: Rad.rPill,
                        ),
                        child: Text('${cancion.reproducciones}', style: AppText.captionXs.copyWith(color: AppColors.granate, fontSize: 9)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botón de Favorito
            IconButton(
              icon: Icon(
                esFavorito ? Icons.favorite : Icons.favorite_border,
                color: esFavorito ? AppColors.granate : onSurface.withOpacity(0.2),
                size: 22,
              ),
              onPressed: () {
                AppMotion.hapticLight();
                onToggleFavorito();
              },
            ),
          ],
        ),
      ),
    );
  }
}