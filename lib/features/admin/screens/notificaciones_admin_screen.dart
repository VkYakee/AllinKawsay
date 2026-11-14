// lib/features/admin/screens/notificaciones_admin_screen.dart
import 'package:flutter/material.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/components/allin_loading_siku.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../services/cancion_service.dart';
import '../../../services/onesignal_service.dart';
import '../widgets/notificacion_modal.dart';

class NotificacionesAdminScreen extends StatefulWidget {
  const NotificacionesAdminScreen({super.key});

  @override
  State<NotificacionesAdminScreen> createState() =>
      _NotificacionesAdminScreenState();
}

class _NotificacionesAdminScreenState
    extends State<NotificacionesAdminScreen> {
  int _pendientes = 0;
  bool _cargando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final n = await CancionService().contarCancionesPendientes();
    if (mounted) {
      setState(() {
        _pendientes = n;
        _cargando = false;
      });
    }
  }

  Future<void> _notificarCanciones() async {
    if (_pendientes <= 0 || _enviando) return;
    setState(() => _enviando = true);
    try {
      final ok = await OneSignalService.enviarATodos(
        titulo: _pendientes == 1
            ? '🎵 Nueva canción agregada'
            : '🎵 $_pendientes canciones nuevas',
        mensaje: 'Toca para abrir el cancionero y ver la partitura actualizada.',
      );
      if (ok && mounted) {
        await CancionService().resetearContadorCanciones();
        await _cargar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notificación de repertorio enviada',
              style: AppText.body.copyWith(color: AppColors.dorado),
            ),
            backgroundColor: AppColors.granateProfundo,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        title: Text(
          'Centro de Avisos Push',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        backgroundColor: AppColors.fondoOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.dorado,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _cargando
          ? const Center(
              child: AllinLoadingSiku(mensaje: 'Consultando estado OneSignal...'),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
              children: [
                // ─── CARD CANCIONES PENDIENTES ───
                AppCard(
                  glass: true,
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.library_music_rounded,
                            color: AppColors.dorado,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Alertas de Repertorio',
                            style: AppText.h3.copyWith(
                              color: AppColors.dorado,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sp.sm),
                      if (_pendientes == 0)
                        Text(
                          'No hay canciones pendientes de avisar a la hermandad.',
                          style: AppText.caption.copyWith(
                            color: AppColors.onSurfaceVariant(context),
                          ),
                        )
                      else ...[
                        Text(
                          'Hay $_pendientes canción(es) subida(s) recientemente sin notificar.',
                          style: AppText.body.copyWith(
                            color: AppColors.onSurface(context),
                          ),
                        ),
                        const SizedBox(height: Sp.lg),
                        AllinButton(
                          label: 'NOTIFICAR REPERTORIO',
                          variant: AllinButtonVariant.gold,
                          expand: true,
                          icono: Icons.notification_add_rounded,
                          loading: _enviando,
                          onPressed: _notificarCanciones,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: Sp.lg),

                // ─── CARD MENSAJE LIBRE / ENSAYOS ───
                AppCard(
                  glass: true,
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.campaign_rounded,
                            color: AppColors.dorado,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Comunicado General',
                            style: AppText.h3.copyWith(
                              color: AppColors.dorado,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sp.sm),
                      Text(
                        'Redacta un aviso personalizado sobre ensayos, uniformes o fechas de viaje.',
                        style: AppText.caption.copyWith(
                          color: AppColors.onSurfaceVariant(context),
                        ),
                      ),
                      const SizedBox(height: Sp.lg),
                      AllinButton(
                        label: 'REDACTAR AVISO',
                        variant: AllinButtonVariant.glass,
                        expand: true,
                        icono: Icons.edit_note_rounded,
                        onPressed: () => NotificacionModal.mostrar(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
    );
  }
}
