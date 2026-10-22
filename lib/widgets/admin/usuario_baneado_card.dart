// lib/widgets/admin/usuario_baneado_card.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/usuario.dart';
import '../../theme/colors.dart';

class UsuarioBaneadoCard extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onDesbanear;

  const UsuarioBaneadoCard({
    super.key,
    required this.usuario,
    required this.onDesbanear,
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
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.withOpacity(0.2),
              child: const Icon(Icons.block, color: Colors.grey),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(usuario.nombre, style: AppType.subtitle.copyWith(color: onSurface.withOpacity(0.5), decoration: TextDecoration.lineThrough), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(usuario.email, style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.4)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.green),
              tooltip: 'Reactivar',
              onPressed: onDesbanear,
            ),
          ],
        ),
      ),
    );
  }
}