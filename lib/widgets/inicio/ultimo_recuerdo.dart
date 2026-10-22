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
        if (snap.connectionState == ConnectionState.waiting) {
          return const SkeletonCard(height: 200);
        }
        if (snap.hasError) return const ErrorMini();

        final lista = snap.data ?? [];
        if (lista.isEmpty) {
          return const EmptyMini(
              icon: Icons.photo_library,
              text: 'Sin recuerdos aún');
        }

        final r = lista.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
          child: AppCard(
            padding: EdgeInsets.zero,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      RecuerdoDetalleScreen(recuerdo: r)),
            ),
            child: ClipRRect(
              borderRadius: Rad.rLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.fotos.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: r.fotos.first,
                      memCacheWidth: 800,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 180,
                        color: Colors.grey.withOpacity(0.1),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.granate),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.grey.withOpacity(0.1),
                        child: const Icon(Icons.broken_image,
                            color: AppColors.granate, size: 40),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(Sp.md + 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.titulo,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Sp.sm, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                AppColors.granate.withOpacity(0.1),
                            borderRadius: Rad.rSm,
                          ),
                          child: Text(
                            '${r.fotos.length} fotos',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate,
                            ),
                          ),
                        ),
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