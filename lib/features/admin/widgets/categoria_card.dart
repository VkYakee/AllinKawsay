// lib/features/admin/widgets/categoria_card.dart
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../models/categoria.dart';
import '../../../theme/colors.dart';

class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.md),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColors.gradienteGranate,
                borderRadius: Rad.rMd,
              ),
              child: Text(
                categoria.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoria.nombre,
                    style: AppType.subtitle.copyWith(color: onSurface),
                  ),
                  Text(
                    'Orden: ${categoria.orden}',
                    style: AppType.captionXs.copyWith(
                      color: onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: onSurface.withOpacity(0.5),
                size: 20,
              ),
              onSelected: (v) {
                if (v == 'editar') onEditar();
                if (v == 'eliminar') onEliminar();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}