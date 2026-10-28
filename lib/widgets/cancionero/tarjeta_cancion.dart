// lib/widgets/cancionero/tarjeta_cancion.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/cancion.dart';
import '../../services/player_service.dart';
import '../../theme/colors.dart';
import 'tarjeta_cancion_play.dart';

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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final sonando = estado.cancionId == cancion.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.xs),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.md),
        onTap: onTap,
        border: sonando 
            ? Border.all(color: AppColors.dorado.withOpacity(0.6), width: 1.5) 
            : Border.all(color: AppColors.dorado.withOpacity(0.1), width: 1),
        child: Row(
          children: [
            TarjetaCancionPlay(
              reproduciendo: sonando && estado.playing,
              cargando: sonando && estado.cargando,
              onTap: onTogglePlay,
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cancion.titulo,
                    style: AppType.title.copyWith(color: onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cancion.ritmo}${cancion.autor.isNotEmpty ? ' · ${cancion.autor}' : ''}',
                    style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.55)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Sp.sm),
                  Row(
                    children: [
                      if (cancion.tieneNumerofonia) ...[
                        const AppBadge(label: 'Partitura', icon: Icons.grid_on, variant: AppBadgeVariant.gold),
                        const SizedBox(width: 4),
                      ],
                      AppBadge(label: '${cancion.reproducciones}', icon: Icons.play_arrow_rounded, variant: AppBadgeVariant.neutral),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                esFavorito ? Icons.favorite : Icons.favorite_border,
                color: esFavorito ? AppColors.granate : onSurface.withOpacity(0.2),
                size: 22,
              ),
              onPressed: onToggleFavorito,
            ),
          ],
        ),
      ),
    );
  }
}