import 'package:flutter/material.dart';
import '../services/cancion_service.dart';
import '../services/onesignal_service.dart';
import '../theme/colors.dart';
import '../widgets/comunes/seccion_card.dart';

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
    _cargarPendientes();
  }

  Future<void> _cargarPendientes() async {
    setState(() => _cargando = true);
    final n = await CancionService().contarCancionesPendientes();
    if (!mounted) return;
    setState(() {
      _pendientes = n;
      _cargando = false;
    });
  }

  Future<void> _notificarCanciones() async {
    if (_pendientes <= 0) return;
    if (_enviando) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Notificar canciones nuevas',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold)),
        content: Text(
            'Se enviará una notificación a todos los usuarios avisando '
            'que hay $_pendientes canción${_pendientes == 1 ? '' : 'es'} '
            'nueva${_pendientes == 1 ? '' : 's'} en el cancionero.\n\n'
            '¿Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _enviando = true);
    try {
      final titulo = _pendientes == 1
          ? '🎵 Nueva canción en el cancionero'
          : '🎵 Se subieron $_pendientes canciones nuevas';
      final mensaje = _pendientes == 1
          ? 'Tocá para verla'
          : 'Tocá para ver el cancionero actualizado';

      final ok = await OneSignalService.enviarATodos(
        titulo: titulo,
        mensaje: mensaje,
        datos: {
          'tipo': 'canciones',
          'cantidad': _pendientes,
        },
      );

      if (!mounted) return;

      if (ok) {
        await CancionService().resetearContadorCanciones();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Notificación enviada!'),
            backgroundColor: Colors.green,
          ),
        );
        await _cargarPendientes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo enviar la notificación'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _notificacionPersonalizada() async {
    final tituloCtrl = TextEditingController();
    final mensajeCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Notificación personalizada',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Ensayo el sábado',
              ),
              maxLength: 60,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: mensajeCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                hintText: 'Ej: Nos vemos a las 7pm en el local',
              ),
              maxLength: 200,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final titulo = tituloCtrl.text.trim();
    final mensaje = mensajeCtrl.text.trim();
    if (titulo.isEmpty || mensaje.isEmpty) return;

    setState(() => _enviando = true);
    try {
      final enviado = await OneSignalService.enviarATodos(
        titulo: titulo,
        mensaje: mensaje,
        datos: {'tipo': 'personalizada'},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(enviado
              ? '¡Notificación enviada!'
              : 'No se pudo enviar la notificación'),
          backgroundColor: enviado ? Colors.green : Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICACIONES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _cargando ? null : _cargarPendientes,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.granate))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dorado.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: AppColors.dorado.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 16,
                          color: AppColors.seccionTitulo(context)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Las notificaciones de eventos, recuerdos y '
                          'actualizaciones se envían automáticamente. '
                          'Acá podés controlar las de canciones nuevas '
                          'y enviar mensajes personalizados.',
                          style: TextStyle(
                            fontSize: 12,
                            color: onSurface.withOpacity(0.75),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Canciones pendientes
                SeccionCard(
                  icono: Icons.library_music,
                  titulo: 'CANCIONES NUEVAS',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_pendientes == 0) ...[
                        Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 16,
                                color: Colors.green.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No hay canciones pendientes de notificar.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: AppColors.gradienteGranate,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$_pendientes',
                                style: const TextStyle(
                                  color: AppColors.dorado,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'canción${_pendientes == 1 ? '' : 'es'} '
                                'nueva${_pendientes == 1 ? '' : 's'} '
                                'sin notificar',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: onSurface.withOpacity(0.85),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: FilledButton.icon(
                            onPressed:
                                _enviando ? null : _notificarCanciones,
                            icon: _enviando
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: AppColors.dorado,
                                        strokeWidth: 2.5),
                                  )
                                : const Icon(Icons.send, size: 16),
                            label: const Text(
                              'NOTIFICAR CANCIONES NUEVAS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Notificación personalizada
                SeccionCard(
                  icono: Icons.campaign,
                  titulo: 'MENSAJE PERSONALIZADO',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enviá un aviso libre a todos los usuarios '
                        '(ensayos, reuniones, coordinación, etc.).',
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: _enviando
                              ? null
                              : _notificacionPersonalizada,
                          icon: const Icon(Icons.edit,
                              size: 16, color: AppColors.granate),
                          label: const Text(
                            'ESCRIBIR MENSAJE',
                            style: TextStyle(
                              color: AppColors.granate,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color:
                                    AppColors.granate.withOpacity(0.6)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Lista de notificaciones automáticas
                SeccionCard(
                  icono: Icons.auto_awesome,
                  titulo: 'NOTIFICACIONES AUTOMÁTICAS',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _filaAuto(
                        Icons.event,
                        'Eventos',
                        'Se envían al crear un evento nuevo',
                        onSurface,
                      ),
                      const SizedBox(height: 10),
                      _filaAuto(
                        Icons.photo_library,
                        'Recuerdos',
                        'Se envían al subir un recuerdo nuevo',
                        onSurface,
                      ),
                      const SizedBox(height: 10),
                      _filaAuto(
                        Icons.system_update,
                        'Actualizaciones',
                        'Se envían al aprobar una versión nueva',
                        onSurface,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _filaAuto(
      IconData icono, String titulo, String subtitulo, Color onSurface) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: AppColors.granate, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: TextStyle(
                  fontSize: 11,
                  color: onSurface.withOpacity(0.55),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.4)),
          ),
          child: const Text(
            'AUTO',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 9,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}