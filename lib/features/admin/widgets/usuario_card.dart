// lib/features/admin/widgets/usuario_card.dart
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../models/usuario.dart';
import '../../../theme/colors.dart';

class UsuarioCard extends StatelessWidget {
  final Usuario usuario;
  final bool soyDev;
  final void Function(String rol) onCambiarRol;
  final VoidCallback onBanear;

  const UsuarioCard({
    super.key,
    required this.usuario,
    required this.soyDev,
    required this.onCambiarRol,
    required this.onBanear,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    Color colorRol = onSurface.withOpacity(0.5);
    if (usuario.rol == 'dev') colorRol = Colors.cyanAccent.shade700;
    if (usuario.rol == 'admin') colorRol = AppColors.granate;
    if (usuario.rol == 'miembro') colorRol = Colors.green.shade700;

    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.granate.withOpacity(0.1),
              backgroundImage: usuario.fotoUrl.isNotEmpty
                  ? NetworkImage(usuario.fotoUrl)
                  : null,
              child: usuario.fotoUrl.isEmpty
                  ? Text(
                      usuario.nombre.isNotEmpty
                          ? usuario.nombre[0].toUpperCase()
                          : '?',
                      style: AppType.subtitle
                          .copyWith(color: AppColors.granate),
                    )
                  : null,
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombre,
                    style: AppType.subtitle.copyWith(color: onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    usuario.email,
                    style: AppType.captionXs.copyWith(
                      color: onSurface.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.rolNombre,
                    style: AppType.labelXs.copyWith(
                      color: colorRol,
                      letterSpacing: 1,
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
              shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
              onSelected: (v) {
                if (v == 'banear') {
                  onBanear();
                } else {
                  onCambiarRol(v);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'publico',
                  child: Text('Hacer Público'),
                ),
                const PopupMenuItem(
                  value: 'miembro',
                  child: Text('Hacer Miembro'),
                ),
                const PopupMenuItem(
                  value: 'admin',
                  child: Text('Hacer Admin'),
                ),
                if (soyDev)
                  const PopupMenuItem(
                    value: 'dev',
                    child: Text(
                      'Hacer Dev',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'banear',
                  child: Text(
                    'Suspender',
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