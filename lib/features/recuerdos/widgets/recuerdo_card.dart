// lib/features/recuerdos/widgets/recuerdo_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/recuerdo.dart';

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
    final onSurface = AppColors.onSurface(context);
    final tieneFoto = recuerdo.fotos.isNotEmpty;
    final tieneVideo = recuerdo.videos.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.lg),
      child: AppCard(
        glass: true,
        padding: EdgeInsets.zero,
        onTap: () {
          AppMotion.hapticLight();
          onTap();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: tieneFoto
                      ? CachedNetworkImage(
                          imageUrl: recuerdo.fotos.first,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(height: 220, color: Colors.white.withOpacity(0.05)),
                          errorWidget: (_, __, ___) => Container(
                            height: 220,
                            color: Colors.white.withOpacity(0.05),
                            child: const Icon(Icons.broken_image, color: AppColors.dorado, size: 40),
                          ),
                        )
                      : Container(
                          height: 220,
                          width: double.infinity,
                          color: AppColors.granate.withOpacity(0.2),
                          child: const Icon(Icons.videocam, color: AppColors.dorado, size: 48),
                        ),
                ),
                
                // Badges de fotos/videos
                if (tieneFoto || tieneVideo)
                  Positioned(
                    top: Sp.md,
                    right: Sp.md,
                    child: Row(
                      children: [
                        if (tieneFoto)
                          _badge(Icons.photo, '${recuerdo.fotos.length}'),
                        if (tieneFoto && tieneVideo) const SizedBox(width: 4),
                        if (tieneVideo)
                          _badge(Icons.videocam, '${recuerdo.videos.length}'),
                      ],
                    ),
                  ),
                  
                // Menú de Admin
                if (esAdmin)
                  Positioned(
                    top: Sp.sm,
                    left: Sp.sm,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppColors.dorado, size: 20),
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
                    style: AppText.h3.copyWith(color: onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (recuerdo.descripcion.isNotEmpty) ...[
                    const SizedBox(height: Sp.xs),
                    Text(
                      recuerdo.descripcion,
                      style: AppText.bodySm.copyWith(color: onSurface.withOpacity(0.6)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: Sp.sm),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: AppColors.dorado),
                      const SizedBox(width: 4),
                      Text(
                        recuerdo.fecha != null
                            ? '${recuerdo.fecha!.day}/${recuerdo.fecha!.month}/${recuerdo.fecha!.year}'
                            : 'Sin fecha',
                        style: AppText.captionXs.copyWith(color: onSurface.withOpacity(0.5)),
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

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: Rad.rPill,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.dorado),
          const SizedBox(width: 4),
          Text(label, style: AppText.captionXs.copyWith(color: AppColors.dorado, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}