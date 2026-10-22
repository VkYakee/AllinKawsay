// lib/widgets/inicio/ultimas_canciones.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/cancion.dart';
import '../../screens/cancion_detalle_screen.dart';
import '../../services/cancion_service.dart';
import '../../theme/colors.dart';
import 'estados.dart';

class UltimasCanciones extends StatelessWidget {
  const UltimasCanciones({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Cancion>>(
      stream: CancionService().listar(),
      builder: (context, snap) {
        if (!snap.hasData) return const SkeletonCard(height: 80);
        final lista = (snap.data ?? []).take(3).toList();
        if (lista.isEmpty) return const EmptyMini(icon: Icons.library_music, text: 'Sin canciones');

        return Column(
          children: [
            for (final c in lista)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.xs),
                child: AppCard(
                  padding: const EdgeInsets.all(Sp.md),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CancionDetalleScreen(cancion: c))),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(gradient: AppColors.gradienteGranate, borderRadius: Rad.rMd),
                        child: const Icon(Icons.music_note, color: AppColors.dorado, size: 20),
                      ),
                      const SizedBox(width: Sp.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.titulo, style: AppType.subtitle.copyWith(color: Theme.of(context).colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(c.ritmo, style: AppType.captionXs.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.dorado, size: 20),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}