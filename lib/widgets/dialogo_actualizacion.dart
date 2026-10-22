// lib/widgets/dialogo_actualizacion.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/info_version.dart';
import '../screens/actualizacion_screen.dart';
import '../theme/colors.dart';

class DialogoActualizacion extends StatelessWidget {
  final InfoVersion info;
  const DialogoActualizacion({super.key, required this.info});

  static Future<bool?> mostrar(BuildContext context, InfoVersion info) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !info.critica,
      builder: (_) => DialogoActualizacion(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !info.critica,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Rad.rXl),
        contentPadding: const EdgeInsets.all(Sp.xl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.lg),
              decoration: const BoxDecoration(
                gradient: AppColors.gradienteGranate,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.system_update_alt, color: AppColors.dorado, size: 36),
            ),
            const SizedBox(height: Sp.lg),
            Text(
              info.critica ? 'ACTUALIZACIÓN OBLIGATORIA' : 'ACTUALIZACIÓN DISPONIBLE',
              textAlign: TextAlign.center,
              style: AppType.h3.copyWith(color: AppColors.seccionTitulo(context), letterSpacing: 1.5),
            ),
            const SizedBox(height: Sp.sm),
            AppBadge(label: 'v${info.displayVersion}', variant: AppBadgeVariant.granate),
            const SizedBox(height: Sp.lg),
            Text(
              info.critica
                  ? 'Necesitas actualizar para seguir usando la app.'
                  : 'Hay una nueva versión de Allin Kawsay disponible.',
              textAlign: TextAlign.center,
              style: AppType.bodySm.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            if (info.notas.trim().isNotEmpty) ...[
              const SizedBox(height: Sp.lg),
              Container(
                padding: const EdgeInsets.all(Sp.md),
                decoration: BoxDecoration(
                  color: AppColors.dorado.withOpacity(0.1),
                  borderRadius: Rad.rMd,
                  border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NOVEDADES', style: AppType.labelXs.copyWith(color: AppColors.granate)),
                    const SizedBox(height: Sp.xs),
                    Text(info.notas, style: AppType.captionXs.copyWith(color: Colors.black87, height: 1.4)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: Sp.xl),
            AppButton(
              label: 'ACTUALIZAR',
              icon: Icons.download,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ActualizacionScreen(info: info)));
              },
            ),
            if (!info.critica) ...[
              const SizedBox(height: Sp.sm),
              AppButton(
                label: 'MÁS TARDE',
                variant: AppButtonVariant.ghost,
                fullWidth: true,
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}