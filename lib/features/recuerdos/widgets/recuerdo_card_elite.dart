// lib/features/recuerdos/widgets/recuerdo_card_elite.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/recuerdo.dart';

class RecuerdoCardElite extends StatefulWidget {
  final Recuerdo recuerdo;
  final bool esAdmin;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const RecuerdoCardElite({
    super.key,
    required this.recuerdo,
    required this.esAdmin,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  State<RecuerdoCardElite> createState() => _RecuerdoCardEliteState();
}

class _RecuerdoCardEliteState extends State<RecuerdoCardElite> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.recuerdo;
    final onSurface = AppColors.onSurface(context);
    final tieneFoto = r.fotos.isNotEmpty;
    final tieneVideo = r.videos.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.lg),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          AppMotion.hapticLight();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.spring,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context).withOpacity(0.92),
              borderRadius: Rad.rLg,
              border: Border.all(
                color: AppColors.dorado.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── IMAGEN ───
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 11,
                      child: Hero(
                        tag: 'recuerdo_img_${r.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: tieneFoto
                              ? CachedNetworkImage(
                                  imageUrl: r.fotos.first,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 900,
                                  placeholder: (_, __) => Container(
                                    color: AppColors.granate.withOpacity(0.15),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.dorado,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      _emptyImage(onSurface),
                                )
                              : _emptyImage(onSurface),
                        ),
                      ),
                    ),
                    // Gradiente inferior para legibilidad
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.55),
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),
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
                              _BadgeBlur(
                                icon: Icons.photo,
                                label: '${r.fotos.length}',
                              ),
                            if (tieneFoto && tieneVideo)
                              const SizedBox(width: 4),
                            if (tieneVideo)
                              _BadgeBlur(
                                icon: Icons.videocam,
                                label: '${r.videos.length}',
                              ),
                          ],
                        ),
                      ),
                    // Menú admin
                    if (widget.esAdmin)
                      Positioned(
                        top: Sp.sm,
                        left: Sp.sm,
                        child: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 20,
                          ),
                          color: AppColors.surface(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: Rad.rLg,
                          ),
                          offset: const Offset(0, 40),
                          onSelected: (v) {
                            if (v == 'editar') widget.onEditar();
                            if (v == 'eliminar') widget.onEliminar();
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'editar',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: onSurface,
                                    size: 18,
                                  ),
                                  const SizedBox(width: Sp.sm),
                                  Text(
                                    'Editar',
                                    style: AppText.subtitle
                                        .copyWith(color: onSurface),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: Colors.red, size: 18),
                                  SizedBox(width: Sp.sm),
                                  Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    // Fecha en la esquina inferior izquierda (sobre imagen)
                    Positioned(
                      bottom: Sp.md,
                      left: Sp.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sp.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: Rad.rPill,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 10,
                              color: AppColors.dorado,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              r.fecha != null
                                  ? '${r.fecha!.day}/${r.fecha!.month}/${r.fecha!.year}'
                                  : 'Sin fecha',
                              style: AppText.captionXs.copyWith(
                                color: AppColors.dorado,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ─── INFO ───
                Padding(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.titulo,
                        style: AppText.h3.copyWith(
                          color: onSurface,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (r.descripcion.isNotEmpty) ...[
                        const SizedBox(height: Sp.xs),
                        Text(
                          r.descripcion,
                          style: AppText.bodySm.copyWith(
                            color: onSurface.withOpacity(0.6),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: Sp.md),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: onSurface.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              r.creadorNombre.isEmpty
                                  ? 'Anónimo'
                                  : r.creadorNombre,
                              style: AppText.captionXs.copyWith(
                                color: onSurface.withOpacity(0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: AppColors.dorado.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyImage(Color onSurface) {
    return Container(
      color: AppColors.granate.withOpacity(0.15),
      child: Center(
        child: Icon(
          widget.recuerdo.videos.isNotEmpty
              ? Icons.videocam
              : Icons.photo_library,
          color: AppColors.dorado.withOpacity(0.5),
          size: 48,
        ),
      ),
    );
  }
}

class _BadgeBlur extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BadgeBlur({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sp.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: Rad.rPill,
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.dorado),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppText.captionXs.copyWith(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}