// lib/screens/notificaciones_admin_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../services/cancion_service.dart';
import '../services/onesignal_service.dart';
import '../theme/colors.dart';
import '../widgets/admin/notificacion_modal.dart';

class NotificacionesAdminScreen extends StatefulWidget {
  const NotificacionesAdminScreen({super.key});

  @override
  State<NotificacionesAdminScreen> createState() => _NotificacionesAdminScreenState();
}

class _NotificacionesAdminScreenState extends State<NotificacionesAdminScreen> {
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
    if (mounted) setState(() { _pendientes = n; _cargando = false; });
  }

  Future<void> _notificarCanciones() async {
    if (_pendientes <= 0 || _enviando) return;
    setState(() => _enviando = true);
    try {
      final ok = await OneSignalService.enviarATodos(
        titulo: _pendientes == 1 ? '🎵 Nueva canción' : '🎵 $_pendientes canciones nuevas',
        mensaje: 'Toca para ver el cancionero actualizado',
      );
      if (ok && mounted) {
        await CancionService().resetearContadorCanciones();
        await _cargar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notificación enviada')));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return AppScaffold(
      title: 'Notificaciones',
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: AppColors.granate))
          : ListView(
              padding: const EdgeInsets.all(Sp.lg),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SeccionHeader(title: 'Canciones Nuevas', icon: Icons.library_music, padding: EdgeInsets.zero),
                      const SizedBox(height: Sp.md),
                      if (_pendientes == 0)
                        Text('No hay canciones pendientes.', style: AppType.bodySm.copyWith(color: onSurface.withOpacity(0.6)))
                      else ...[
                        Text('Hay $_pendientes canción(es) sin notificar.', style: AppType.subtitle),
                        const SizedBox(height: Sp.md),
                        AppButton(
                          label: 'NOTIFICAR CANCIONES',
                          fullWidth: true,
                          loading: _enviando,
                          onPressed: _notificarCanciones,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Sp.md),
                AppCard(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SeccionHeader(title: 'Mensaje Libre', icon: Icons.campaign, padding: EdgeInsets.zero),
                      const SizedBox(height: Sp.md),
                      Text('Envía un aviso a todos los usuarios.', style: AppType.bodySm.copyWith(color: onSurface.withOpacity(0.6))),
                      const SizedBox(height: Sp.md),
                      AppButton(
                        label: 'ESCRIBIR MENSAJE',
                        variant: AppButtonVariant.secondary,
                        fullWidth: true,
                        onPressed: () => NotificacionModal.mostrar(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}