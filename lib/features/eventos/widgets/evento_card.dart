// lib/features/eventos/widgets/evento_card.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/evento.dart';

class EventoCard extends StatelessWidget {
  final Evento evento;
  final bool esPasado;
  final String nota;
  final bool esAdmin;
  final VoidCallback onTap;
  final VoidCallback onEditarNota;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const EventoCard({
    super.key,
    required this.evento,
    required this.esPasado,
    required this.nota,
    required this.esAdmin,
    required this.onTap,
    required this.onEditarNota,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.md),
      child: AppCard(
        glass: true,
        padding: EdgeInsets.zero,
        onTap: () {
          AppMotion.hapticLight();
          onTap();
        },
        border: esPasado ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Sp.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bloque de fecha
                  _BloqueFecha(fecha: evento.fecha, esPasado: esPasado),
                  const SizedBox(width: Sp.md),
                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.titulo,
                          style: AppText.h3.copyWith(
                            color: esPasado ? onSurface.withOpacity(0.5) : onSurface,
                          ),
                        ),
                        const SizedBox(height: Sp.xs),
                        Row(
                          children: [
                            Icon(Icons.place, size: 14, color: AppColors.dorado.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                evento.lugar.isEmpty ? 'Lugar a confirmar' : evento.lugar,
                                style: AppText.caption.copyWith(color: onSurface.withOpacity(0.6)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.dorado.withOpacity(0.5), size: 18),
                          ],
                        ),
                        if (evento.descripcion.isNotEmpty) ...[
                          const SizedBox(height: Sp.sm),
                          Text(
                            evento.descripcion,
                            style: AppText.bodySm.copyWith(color: onSurface.withOpacity(esPasado ? 0.3 : 0.7)),
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
            
            // Nota personal
            if (nota.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.sm),
                color: AppColors.dorado.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.sticky_note_2, size: 14, color: AppColors.dorado),
                    const SizedBox(width: Sp.sm),
                    Expanded(
                      child: Text(
                        nota,
                        style: AppText.captionXs.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.dorado,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
            const Divider(height: 1),
            
            // Acciones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.sm),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: onEditarNota,
                    icon: Icon(nota.isEmpty ? Icons.add_comment_outlined : Icons.edit_note, size: 16, color: AppColors.dorado),
                    label: Text(
                      nota.isEmpty ? 'Añadir nota' : 'Editar nota',
                      style: AppText.label.copyWith(color: AppColors.dorado),
                    ),
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
}

class _BloqueFecha extends StatelessWidget {
  final DateTime fecha;
  final bool esPasado;
  
  const _BloqueFecha({required this.fecha, required this.esPasado});

  static const _meses = ['', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: esPasado ? null : AppColors.gradienteGranate,
        color: esPasado ? Colors.grey.withOpacity(0.2) : null,
        borderRadius: Rad.rMd,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${fecha.day}',
            style: AppText.h2.copyWith(
              color: esPasado ? Colors.grey : AppColors.dorado,
              height: 1,
            ),
          ),
          Text(
            _meses[fecha.month],
            style: AppText.captionXs.copyWith(
              color: esPasado ? Colors.grey : AppColors.dorado.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}