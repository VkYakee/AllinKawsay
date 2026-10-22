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
    final reproduciendo = sonando && estado.playing;
    final cargando = sonando && estado.cargando;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.xs),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.md),
        onTap: onTap,
        border: sonando ? Border.all(color: AppColors.dorado.withOpacity(0.5), width: 1.5) : null,
        child: Row(
          children: [
            TarjetaCancionPlay(
              reproduciendo: reproduciendo,
              cargando: cargando,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      AppBadge(label: '${cancion.reproducciones}', icon: Icons.play_arrow_rounded, variant: AppBadgeVariant.granate),
                      if (cancion.tieneNumerofonia) ...[
                        const SizedBox(width: 4),
                        const AppBadge(label: 'Partitura', icon: Icons.grid_on, variant: AppBadgeVariant.gold),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                esFavorito ? Icons.favorite : Icons.favorite_border,
                color: esFavorito ? AppColors.granate : onSurface.withOpacity(0.3),
                size: 20,
              ),
              onPressed: onToggleFavorito,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}