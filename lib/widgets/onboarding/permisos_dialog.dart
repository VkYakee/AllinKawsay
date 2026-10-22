// lib/widgets/onboarding/permisos_dialog.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class PermisosDialog extends StatelessWidget {
  const PermisosDialog({super.key});

  static Future<void> mostrar(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PermisosDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: Rad.rXl),
      insetPadding: const EdgeInsets.all(Sp.lg),
      child: Padding(
        padding: const EdgeInsets.all(Sp.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.lg),
              decoration: const BoxDecoration(gradient: AppColors.gradienteGranate, shape: BoxShape.circle),
              child: const Icon(Icons.security, color: AppColors.dorado, size: 40),
            ),
            const SizedBox(height: Sp.lg),
            Text('Bienvenido a Allin Kawsay', style: AppType.h3.copyWith(color: AppColors.granate), textAlign: TextAlign.center),
            const SizedBox(height: Sp.sm),
            Text(
              'Para brindarte la mejor experiencia, necesitamos que aceptes los siguientes permisos:',
              style: AppType.bodySm.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Sp.xl),
            _ItemPermiso(
              icon: Icons.notifications_active,
              title: 'Notificaciones',
              desc: 'Para avisarte de nuevos eventos y canciones.',
            ),
            _ItemPermiso(
              icon: Icons.photo_library,
              title: 'Fotos y Videos',
              desc: 'Para que puedas subir recuerdos del grupo y personalizar tu perfil.',
            ),
            _ItemPermiso(
              icon: Icons.audiotrack,
              title: 'Audio',
              desc: 'Para que puedas escuchar las canciones de la zampoña.',
            ),
            const SizedBox(height: Sp.xl),
            AppButton(
              label: 'ACEPTAR Y CONTINUAR',
              fullWidth: true,
              onPressed: () async {
                // Pedimos los permisos reales al sistema operativo
                await [
                  Permission.notification,
                  Permission.photos,
                  Permission.audio,
                ].request();
                
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPermiso extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _ItemPermiso({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(Sp.sm),
            decoration: BoxDecoration(color: AppColors.granate.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.granate, size: 20),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppType.subtitle.copyWith(color: AppColors.negro)),
                Text(desc, style: AppType.captionXs.copyWith(color: Colors.black54, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}