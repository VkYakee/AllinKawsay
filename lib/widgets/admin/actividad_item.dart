// lib/widgets/admin/actividad_item.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../services/actividad_service.dart';
import '../../theme/colors.dart';

class ActividadItem extends StatelessWidget {
  final Actividad actividad;
  const ActividadItem({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = _color(actividad.accion);
    final icono = _icono(actividad.accion);

    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: Rad.rMd,
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icono, color: color, size: 18),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(actividad.detalle, style: AppType.body.copyWith(color: onSurface, height: 1.4)),
                  const SizedBox(height: Sp.xs),
                  Row(
                    children: [
                      Text(actividad.autorNombre, style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.6))),
                      const SizedBox(width: Sp.sm),
                      Container(width: 3, height: 3, decoration: BoxDecoration(color: onSurface.withOpacity(0.3), shape: BoxShape.circle)),
                      const SizedBox(width: Sp.sm),
                      Text(_formatoFecha(actividad.fecha), style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.4))),
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

  IconData _icono(String accion) {
    if (accion.contains('cancion')) return Icons.library_music;
    if (accion.contains('evento')) return Icons.event;
    if (accion.contains('recuerdo')) return Icons.photo_library;
    if (accion.contains('usuario') || accion.contains('rol') || accion.contains('banear')) return Icons.people;
    if (accion.contains('categoria')) return Icons.category;
    return Icons.info;
  }

  Color _color(String accion) {
    if (accion.contains('crear') || accion.contains('desbanear')) return Colors.green;
    if (accion.contains('editar')) return AppColors.doradoOscuro;
    if (accion.contains('eliminar') || accion.contains('banear')) return Colors.red;
    return AppColors.granate;
  }

  String _formatoFecha(DateTime? d) {
    if (d == null) return '...';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return '${d.day}/${d.month}/${d.year}';
  }
}