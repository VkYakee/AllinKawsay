// lib/features/onboarding/widgets/permisos_dialog.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/components/allin_dialog.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

class PermisosDialog {
  static Future<void> mostrar(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AllinDialog(
        titulo: 'Bienvenido a Allin Kawsay',
        mensaje:
            'Para brindarte la mejor experiencia con el repertorio y los ensayos, requerimos los siguientes permisos:',
        icono: Icons.security_rounded,
        contenido: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ItemPermiso(
              icon: Icons.notifications_active_rounded,
              title: 'Notificaciones',
              desc: 'Avisos de nuevos eventos, ensayos y canciones.',
            ),
            SizedBox(height: Sp.sm),
            _ItemPermiso(
              icon: Icons.photo_library_rounded,
              title: 'Fotos y Videos',
              desc: 'Subir recuerdos y personalizar tu perfil de músico.',
            ),
            SizedBox(height: Sp.sm),
            _ItemPermiso(
              icon: Icons.audiotrack_rounded,
              title: 'Audio',
              desc: 'Escuchar el cancionero y afinar en la zampoña virtual.',
            ),
          ],
        ),
        acciones: [
          AllinButton(
            label: 'ACEPTAR Y CONTINUAR',
            variant: AllinButtonVariant.gold,
            expand: true,
            icono: Icons.check_circle_rounded,
            onPressed: () async {
              await [
                Permission.notification,
                Permission.photos,
                Permission.audio,
              ].request();
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _ItemPermiso extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _ItemPermiso({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context).withOpacity(0.3),
        borderRadius: Rad.rMd,
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Sp.xs),
            decoration: BoxDecoration(
              color: AppColors.dorado.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.dorado, size: 20),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.subtitle.copyWith(
                    color: AppColors.dorado,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppText.caption.copyWith(
                    color: AppColors.onSurfaceVariant(context),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
