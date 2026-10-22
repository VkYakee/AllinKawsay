// lib/widgets/eventos/evento_card.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/evento.dart';
import '../../theme/colors.dart';

class EventoCard extends StatelessWidget {
  final Evento evento;
  final bool esPasado;
  final String nota;
  final bool esAdmin;
  final VoidCallback onEditarNota;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const EventoCard({
    super.key,
    required this.evento,
    required this.esPasado,
    required this.nota,
    required this.esAdmin,
    required this.onEditarNota,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.md),
      child: AppCard(
        padding: EdgeInsets.zero,
        border: esPasado ? Border.all(color: onSurface.withOpacity(0.1)) : null,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Sp.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BloqueFecha(fecha: evento.fecha, esPasado: esPasado),
                  const SizedBox(width: Sp.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.titulo,
                          style: AppType.h3.copyWith(
                            color: esPasado ? onSurface.withOpacity(0.5) : onSurface,
                          ),
                        ),
                        const SizedBox(height: Sp.xs),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: onSurface.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(_hora(evento.fecha), style: AppType.captionXs),
                            if (evento.lugar.isNotEmpty) ...[
                              const SizedBox(width: Sp.sm),
                              Icon(Icons.place, size: 12, color: onSurface.withOpacity(0.5)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  evento.lugar,
                                  style: AppType.captionXs,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (evento.descripcion.isNotEmpty) ...[
                          const SizedBox(height: Sp.sm),
                          Text(
                            evento.descripcion,
                            style: AppType.bodySm.copyWith(
                                color: onSurface.withOpacity(esPasado ? 0.3 : 0.7)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (nota.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.sm),
                color: AppColors.dorado.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.sticky_note_2, size: 14, color: AppColors.granate),
                    const SizedBox(width: Sp.sm),
                    Expanded(
                      child: Text(
                        nota,
                        style: AppType.captionXs.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.granate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.sm),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: onEditarNota,
                    icon: Icon(nota.isEmpty ? Icons.add_comment_outlined : Icons.edit_note, size: 16),
                    label: Text(nota.isEmpty ? 'Añadir nota' : 'Editar nota', style: AppType.labelXs),
                    style: TextButton.styleFrom(foregroundColor: AppColors.granate),
                  ),
                  const Spacer(),
                  if (esAdmin)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: onSurface.withOpacity(0.5), size: 20),
                      onSelected: (v) {
                        if (v == 'editar') onEditar();
                        if (v == 'eliminar') onEliminar();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'editar', child: Text('Editar')),
                        PopupMenuItem(value: 'eliminar', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
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

  String _hora(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _BloqueFecha extends StatelessWidget {
  final DateTime fecha;
  final bool esPasado;
  const _BloqueFecha({required this.fecha, required this.esPasado});

  static const _meses = ['', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: esPasado ? Colors.grey.withOpacity(0.1) : AppColors.granate,
        borderRadius: Rad.rMd,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${fecha.day}',
            style: AppType.h2.copyWith(
              color: esPasado ? Colors.grey : AppColors.dorado,
              height: 1,
            ),
          ),
          Text(
            _meses[fecha.month],
            style: AppType.labelXs.copyWith(
              color: esPasado ? Colors.grey : AppColors.dorado.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}