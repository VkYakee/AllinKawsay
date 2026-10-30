// lib/features/eventos/widgets/evento_card_elite.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/evento.dart';

class EventoCardElite extends StatefulWidget {
  final Evento evento;
  final bool esPasado;
  final String nota;
  final bool esAdmin;
  final VoidCallback onTap;
  final VoidCallback onEditarNota;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const EventoCardElite({
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
  State<EventoCardElite> createState() => _EventoCardEliteState();
}

class _EventoCardEliteState extends State<EventoCardElite> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);
    final e = widget.evento;

    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.md),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          AppMotion.hapticLight();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.spring,
          child: AnimatedContainer(
            duration: AppMotion.normal,
            decoration: BoxDecoration(
              color: AppColors.surface(context).withOpacity(
                widget.esPasado ? 0.7 : 0.92,
              ),
              borderRadius: Rad.rLg,
              border: Border.all(
                color: widget.esPasado
                    ? onSurface.withOpacity(0.08)
                    : AppColors.dorado.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                if (!widget.esPasado)
                  BoxShadow(
                    color: AppColors.granate.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BloqueFecha(
                        fecha: e.fecha,
                        esPasado: widget.esPasado,
                      ),
                      const SizedBox(width: Sp.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.titulo,
                                    style: AppText.title.copyWith(
                                      color: widget.esPasado
                                          ? onSurface.withOpacity(0.5)
                                          : onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.esAdmin) _buildMenu(context),
                              ],
                            ),
                            const SizedBox(height: Sp.xs),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: AppColors.dorado
                                      .withOpacity(widget.esPasado ? 0.3 : 0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${e.fecha.hour.toString().padLeft(2, '0')}:${e.fecha.minute.toString().padLeft(2, '0')}',
                                  style: AppText.captionXs.copyWith(
                                    color: widget.esPasado
                                        ? onSurface.withOpacity(0.4)
                                        : AppColors.dorado.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(width: Sp.md),
                                Icon(
                                  Icons.place,
                                  size: 12,
                                  color: onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    e.lugar.isEmpty
                                        ? 'Lugar a confirmar'
                                        : e.lugar,
                                    style: AppText.captionXs.copyWith(
                                      color: onSurface.withOpacity(0.6),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (e.descripcion.isNotEmpty) ...[
                              const SizedBox(height: Sp.sm),
                              Text(
                                e.descripcion,
                                style: AppText.bodySm.copyWith(
                                  color: onSurface.withOpacity(
                                    widget.esPasado ? 0.3 : 0.7,
                                  ),
                                ),
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
                if (widget.nota.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sp.lg,
                      vertical: Sp.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dorado.withOpacity(0.08),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.dorado.withOpacity(0.15),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sticky_note_2,
                          size: 14,
                          color: AppColors.dorado,
                        ),
                        const SizedBox(width: Sp.sm),
                        Expanded(
                          child: Text(
                            widget.nota,
                            style: AppText.captionXs.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.dorado,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Footer
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: onSurface.withOpacity(0.06),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: widget.onEditarNota,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Sp.md,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.nota.isEmpty
                                      ? Icons.add_comment_outlined
                                      : Icons.edit_note,
                                  size: 16,
                                  color: AppColors.dorado,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.nota.isEmpty
                                      ? 'Añadir nota'
                                      : 'Editar nota',
                                  style: AppText.captionXs.copyWith(
                                    color: AppColors.dorado,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: onSurface.withOpacity(0.06),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            AppMotion.hapticLight();
                            widget.onTap();
                          },
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: Sp.md,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Ver detalles',
                                  style: AppText.captionXs.copyWith(
                                    color: onSurface.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 10,
                                  color: onSurface.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.onSurfaceVariant(context),
        size: 20,
      ),
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: Rad.rLg),
      offset: const Offset(0, 30),
      onSelected: (v) {
        if (v == 'editar') widget.onEditar();
        if (v == 'eliminar') widget.onEliminar();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'editar',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: AppColors.onSurface(context),
                size: 18,
              ),
              const SizedBox(width: Sp.sm),
              Text(
                'Editar',
                style: AppText.subtitle.copyWith(
                  color: AppColors.onSurface(context),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'eliminar',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 18),
              SizedBox(width: Sp.sm),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BloqueFecha extends StatelessWidget {
  final DateTime fecha;
  final bool esPasado;

  const _BloqueFecha({required this.fecha, required this.esPasado});

  static const _meses = [
    '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 70,
      decoration: BoxDecoration(
        gradient: esPasado
            ? LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.2),
                  Colors.grey.withOpacity(0.1),
                ],
              )
            : AppColors.gradienteGranate,
        borderRadius: Rad.rMd,
        boxShadow: esPasado
            ? null
            : [
                BoxShadow(
                  color: AppColors.granate.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${fecha.day}',
            style: AppText.h2.copyWith(
              color: esPasado
                  ? Colors.grey.shade400
                  : AppColors.dorado,
              height: 1,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _meses[fecha.month],
            style: AppText.labelXs.copyWith(
              color: esPasado
                  ? Colors.grey.shade500
                  : AppColors.dorado.withOpacity(0.8),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}