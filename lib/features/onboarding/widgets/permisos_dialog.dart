// lib/features/onboarding/widgets/permisos_dialog.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_button.dart';

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
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(Sp.lg),
      child: AppCard(
        glass: true,
        padding: const EdgeInsets.all(Sp.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.lg),
              decoration: const BoxDecoration(
                gradient: AppColors.gradienteGranate,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security, color: AppColors.dorado, size: 40),
            ),
            const SizedBox(height: Sp.lg),
            Text('Bienvenido a Allin Kawsay', style: AppText.h3.copyWith(color: AppColors.dorado), textAlign: TextAlign.center),
            const SizedBox(height: Sp.sm),
            Text(
              'Para brindarte la mejor experiencia, necesitamos que aceptes los siguientes permisos:',
              style: AppText.bodySm.copyWith(color: Colors.white70),
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
              desc: 'Para que puedas subir recuerdos y personalizar tu perfil.',
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
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.dorado, size: 20),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.subtitle.copyWith(color: AppColors.dorado)),
                Text(desc, style: AppText.captionXs.copyWith(color: Colors.white70, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}