// lib/features/admin/widgets/notificacion_modal.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../services/onesignal_service.dart';

class NotificacionModal {
  static void mostrar(BuildContext context) {
    final tituloCtrl = TextEditingController();
    final mensajeCtrl = TextEditingController();
    bool enviando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(Sp.xl),
                decoration: BoxDecoration(
                  color: AppColors.fondoOscuro.withOpacity(0.95),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.dorado.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.dorado.withOpacity(0.35),
                        borderRadius: Rad.rPill,
                      ),
                    ),
                    const SizedBox(height: Sp.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.campaign_rounded,
                          color: AppColors.dorado,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mensaje a la Hermandad',
                          style: AppText.h3.copyWith(color: AppColors.dorado),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.xl),
                    TextField(
                      controller: tituloCtrl,
                      style: AppText.body.copyWith(
                        color: AppColors.onSurface(context),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Título del aviso',
                        labelStyle: TextStyle(
                          color: AppColors.dorado.withOpacity(0.8),
                        ),
                        hintText: 'Ej: Ensayo General este Sábado',
                        hintStyle: AppText.caption.copyWith(
                          color: AppColors.onSurfaceVariant(context),
                        ),
                        filled: true,
                        fillColor:
                            AppColors.surfaceVariant(context).withOpacity(0.35),
                        border: OutlineInputBorder(
                          borderRadius: Rad.rMd,
                          borderSide: BorderSide(color: AppColors.border(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Rad.rMd,
                          borderSide: const BorderSide(
                            color: AppColors.dorado,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.md),
                    TextField(
                      controller: mensajeCtrl,
                      maxLines: 3,
                      style: AppText.body.copyWith(
                        color: AppColors.onSurface(context),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Mensaje detallado',
                        labelStyle: TextStyle(
                          color: AppColors.dorado.withOpacity(0.8),
                        ),
                        hintText: 'Ej: Traer zampoñas afinadas y uniforme completo a las 7:00 PM.',
                        hintStyle: AppText.caption.copyWith(
                          color: AppColors.onSurfaceVariant(context),
                        ),
                        filled: true,
                        fillColor:
                            AppColors.surfaceVariant(context).withOpacity(0.35),
                        border: OutlineInputBorder(
                          borderRadius: Rad.rMd,
                          borderSide: BorderSide(color: AppColors.border(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Rad.rMd,
                          borderSide: const BorderSide(
                            color: AppColors.dorado,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.xl),
                    AllinButton(
                      label: enviando ? 'ENVIANDO...' : 'TRANSMITIR PUSH A TODOS',
                      variant: AllinButtonVariant.gold,
                      expand: true,
                      icono: Icons.send_rounded,
                      loading: enviando,
                      onPressed: () async {
                        final t = tituloCtrl.text.trim();
                        final m = mensajeCtrl.text.trim();
                        if (t.isEmpty || m.isEmpty) return;
                        setSheetState(() => enviando = true);
                        final ok = await OneSignalService.enviarATodos(
                          titulo: t,
                          mensaje: m,
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Aviso transmitido con éxito a todos los dispositivos'
                                    : 'Error al enviar notificación',
                                style: AppText.body.copyWith(
                                  color: AppColors.dorado,
                                ),
                              ),
                              backgroundColor: AppColors.granateProfundo,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: Sp.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
