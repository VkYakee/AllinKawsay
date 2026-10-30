// lib/features/admin/widgets/notificacion_modal.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../services/onesignal_service.dart';
import '../../../theme/colors.dart';

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
                  color: AppColors.cardColor(ctx).withOpacity(0.9),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.dorado.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.granate.withOpacity(0.3),
                        borderRadius: Rad.rPill,
                      ),
                    ),
                    const SizedBox(height: Sp.lg),
                    Text(
                      'Mensaje Personalizado',
                      style: AppType.h3,
                    ),
                    const SizedBox(height: Sp.xl),
                    AppInput(
                      controller: tituloCtrl,
                      label: 'Título',
                      hint: 'Ej: Ensayo el sábado',
                    ),
                    const SizedBox(height: Sp.md),
                    AppInput(
                      controller: mensajeCtrl,
                      label: 'Mensaje',
                      hint: 'Ej: Nos vemos a las 7pm',
                      maxLines: 3,
                    ),
                    const SizedBox(height: Sp.xl),
                    AppButton(
                      label: 'ENVIAR NOTIFICACIÓN',
                      fullWidth: true,
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
                                    ? 'Notificación enviada'
                                    : 'Error al enviar',
                              ),
                            ),
                          );
                        }
                      },
                    ),
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