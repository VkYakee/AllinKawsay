// lib/widgets/recuerdos/recuerdo_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/recuerdo.dart';
import '../../theme/colors.dart';

class RecuerdoCard extends StatelessWidget {
  final Recuerdo recuerdo;
  final bool esAdmin;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const RecuerdoCard({
    super.key,
    required this.recuerdo,
    required this.esAdmin,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final tieneFoto = recuerdo.fotos.isNotEmpty;
    final tieneVideo = recuerdo.videos.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.lg),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: tieneFoto
                      ? CachedNetworkImage(
                          imageUrl: recuerdo.fotos.first,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(height: 200, color: Colors.grey.withOpacity(0.1)),
                          errorWidget: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey.withOpacity(0.1),
                            child: const Icon(Icons.broken_image, color: AppColors.granate, size: 40),
                          ),
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          color: AppColors.granate.withOpacity(0.1),
                          child: const Icon(Icons.videocam, color: AppColors.granate, size: 48),
                        ),
                ),
                if (tieneFoto || tieneVideo)
                  Positioned(
                    top: Sp.sm,
                    right: Sp.sm,
                    child: Row(
                      children: [
                        if (tieneFoto)
                          AppBadge(
                            label: '${recuerdo.fotos.length}',
                            icon: Icons.photo,
                            variant: AppBadgeVariant.neutral,
                          ),
                        if (tieneFoto && tieneVideo) const SizedBox(width: 4),
                        if (tieneVideo)
                          AppBadge(
                            label: '${recuerdo.videos.length}',
                            icon: Icons.videocam,
                            variant: AppBadgeVariant.neutral,
                          ),
                      ],
                    ),
                  ),
                if (esAdmin)
                  Positioned(
                    top: Sp.xs,
                    left: Sp.xs,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                        onSelected: (v) {
                          if (v == 'editar') onEditar();
                          if (v == 'eliminar') onEliminar();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(value: 'eliminar', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recuerdo.titulo,
                    style: AppType.h3.copyWith(color: onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (recuerdo.descripcion.isNotEmpty) ...[
                    const SizedBox(height: Sp.xs),
                    Text(
                      recuerdo.descripcion,
                      style: AppType.bodySm.copyWith(color: onSurface.withOpacity(0.6)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: Sp.sm),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: onSurface.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(
                        recuerdo.fecha != null
                            ? '${recuerdo.fecha!.day}/${recuerdo.fecha!.month}/${recuerdo.fecha!.year}'
                            : 'Sin fecha',
                        style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}