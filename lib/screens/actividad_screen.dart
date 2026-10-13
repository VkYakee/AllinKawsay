import 'package:flutter/material.dart';
import '../services/actividad_service.dart';
import '../theme/colors.dart';
import '../widgets/comunes/empty_state.dart';
import '../widgets/comunes/error_state.dart';
import '../widgets/watermark_overlay.dart';

class ActividadScreen extends StatelessWidget {
  const ActividadScreen({super.key});

  IconData _icono(String accion) {
    if (accion.contains('crear_cancion') ||
        accion.contains('editar_cancion') ||
        accion.contains('eliminar_cancion')) {
      return Icons.library_music;
    }
    if (accion.contains('evento')) return Icons.event;
    if (accion.contains('recuerdo')) return Icons.photo_library;
    if (accion.contains('historia')) return Icons.history_edu;
    if (accion.contains('rol') || accion.contains('usuario')) {
      return Icons.people;
    }
    if (accion.contains('nombre')) return Icons.person;
    if (accion.contains('banear') || accion.contains('desbanear')) {
      return Icons.block;
    }
    if (accion.contains('categoria')) return Icons.category;
    return Icons.info;
  }

  Color _color(String accion) {
    if (accion.contains('crear')) return Colors.green;
    if (accion.contains('editar')) return AppColors.dorado;
    if (accion.contains('eliminar') || accion.contains('banear')) {
      return Colors.red;
    }
    if (accion.contains('desbanear')) return Colors.green;
    return AppColors.granate;
  }

  String _formatoFecha(DateTime? d) {
    if (d == null) return '...';
    final hoy = DateTime.now();
    final diff = hoy.difference(d);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';

    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HISTORIAL DE ACTIVIDAD')),
      body: WatermarkOverlay(
        opacity: 0.04,
        child: StreamBuilder<List<Actividad>>(
          stream: ActividadService().listar(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.granate));
            }
            if (snap.hasError) {
              return ErrorState(
                titulo: 'Error al cargar actividad',
                detalle: '${snap.error}\n\n'
                    'Verificá que hayas publicado las reglas de Firestore.',
              );
            }
            final lista = snap.data ?? [];
            if (lista.isEmpty) {
              return const EmptyState(
                icono: Icons.history,
                titulo: 'Sin actividad registrada',
                subtitulo: 'Las acciones del grupo aparecerán acá.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: lista.length,
              itemBuilder: (context, i) {
                return _filaActividad(context, lista[i]);
              },
            );
          },
        ),
      ),
    );
  }
  Widget _filaActividad(BuildContext context, Actividad a) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = _color(a.accion);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dorado.withOpacity(0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(_icono(a.accion), color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.detalle,
                    style: TextStyle(
                      fontSize: 13,
                      color: onSurface,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 11,
                          color: AppColors.seccionTitulo(context)
                              .withOpacity(0.6)),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          a.autorNombre,
                          style: TextStyle(
                            fontSize: 11,
                            color: onSurface.withOpacity(0.55),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: onSurface.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatoFecha(a.fecha),
                        style: TextStyle(
                            fontSize: 11,
                            color: onSurface.withOpacity(0.45)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}