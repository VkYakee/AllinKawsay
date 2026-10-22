// lib/widgets/inicio/ultimo_recuerdo.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/recuerdo.dart';
import '../../screens/recuerdo_detalle_screen.dart';
import '../../services/recuerdo_service.dart';
import '../../theme/colors.dart';
import 'estados.dart';

class UltimoRecuerdo extends StatelessWidget {
  const UltimoRecuerdo({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Recuerdo>>(
      stream: RecuerdoService().listar(),
      builder: (context, snap) {
        if (!snap.hasData) return const SkeletonCard(height: 200);
        final lista = snap.data ?? [];
        if (lista.isEmpty) return const EmptyMini(icon: Icons.photo_library, text: 'Sin recuerdos');

        final r = lista.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
          child: AppCard(
            padding: EdgeInsets.zero,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecuerdoDetalleScreen(recuerdo: r))),
            child: ClipRRect(
              borderRadius: Rad.rLg,
              child: Column(
                children: [
                  if (r.fotos.isNotEmpty)
                    CachedNetworkImage(imageUrl: r.fotos.first, width: double.infinity, height: 180, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.all(Sp.md),
                    child: Row(
                      children: [
                        Expanded(child: Text(r.titulo, style: AppType.subtitle.copyWith(color: Theme.of(context).colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        AppBadge(label: '${r.fotos.length} fotos', variant: AppBadgeVariant.granate),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}