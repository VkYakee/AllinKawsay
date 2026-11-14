// lib/widgets/dialogo_actualizacion.dart
import 'package:flutter/material.dart';

import '../core/components/allin_button.dart';
import '../core/components/allin_dialog.dart';
import '../core/design/colors.dart';
import '../core/design/tokens.dart';
import '../core/design/typography.dart';
import '../features/update/screens/actualizacion_screen.dart';
import '../models/info_version.dart';

class DialogoActualizacion extends StatelessWidget {
  final InfoVersion info;
  const DialogoActualizacion({super.key, required this.info});

  static Future<bool?> mostrar(BuildContext context, InfoVersion info) {
    return AllinDialog.show<bool>(
      context,
      child: DialogoActualizacion(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !info.critica,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Sp.xl),
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: AppColors.fondoOLED.withOpacity(0.95),
            borderRadius: Rad.rXl,
            border: Border.all(
              color: AppColors.oroSolar.withOpacity(0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 35,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: AppColors.granateSagrado.withOpacity(0.35),
                blurRadius: 25,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(Sp.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.granateSagrado,
                          AppColors.granateOscuro,
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.oroSolar.withOpacity(0.5),
                        width: 1.2,
                      ),
                      boxShadow: AppColors.glowDorado(intens: 0.3, blur: 14),
                    ),
                    child: const Icon(
                      Icons.system_update_alt,
                      color: AppColors.oroSolar,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: Sp.md),
                  Text(
                    info.critica
                        ? 'ACTUALIZACIÓN OBLIGATORIA'
                        : 'ACTUALIZACIÓN DISPONIBLE',
                    textAlign: TextAlign.center,
                    style: AppText.h3.copyWith(
                      color: AppColors.oroSolar,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: Sp.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.granateSagrado.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.oroSolar.withOpacity(0.4)),
                    ),
                    child: Text(
                      'Versión ${info.displayVersion}',
                      style: const TextStyle(
                        color: AppColors.oroReflejo,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: Sp.md),
                  Text(
                    info.critica
                        ? 'Necesitas actualizar para seguir disfrutando de Allin Kawsay.'
                        : 'Hay una nueva versión disponible con mejoras y nuevas partituras.',
                    textAlign: TextAlign.center,
                    style: AppText.bodySm.copyWith(
                      color: Colors.white70,
                      height: 1.35,
                    ),
                  ),
                  if (info.notas.trim().isNotEmpty) ...[
                    const SizedBox(height: Sp.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Sp.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: Rad.rMd,
                        border: Border.all(
                          color: AppColors.oroSolar.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOVEDADES',
                            style: AppText.captionXs.copyWith(
                              color: AppColors.oroSolar,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            info.notas,
                            style: AppText.caption.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: Sp.xl),
                  AllinButton(
                    text: 'ACTUALIZAR AHORA',
                    icon: Icons.download_rounded,
                    variant: AllinButtonVariant.primary,
                    height: 48,
                    onPressed: () {
                      Navigator.pop(context, true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActualizacionScreen(info: info),
                        ),
                      );
                    },
                  ),
                  if (!info.critica) ...[
                    const SizedBox(height: Sp.sm),
                    AllinButton(
                      text: 'MÁS TARDE',
                      variant: AllinButtonVariant.glass,
                      height: 44,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
