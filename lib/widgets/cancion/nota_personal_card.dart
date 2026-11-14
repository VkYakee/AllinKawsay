// lib/widgets/cancion/nota_personal_card.dart
import 'package:flutter/material.dart';

import '../../core/components/allin_button.dart';
import '../../core/components/allin_dialog.dart';
import '../../core/components/app_card.dart';
import '../../core/design/colors.dart';
import '../../core/design/tokens.dart';
import '../../core/design/typography.dart';
import '../../models/usuario.dart';
import '../../services/usuario_service.dart';

class NotaPersonalCard extends StatefulWidget {
  final String cancionId;
  final Usuario? usuario;

  const NotaPersonalCard({
    super.key,
    required this.cancionId,
    required this.usuario,
  });

  @override
  State<NotaPersonalCard> createState() => _NotaPersonalCardState();
}

class _NotaPersonalCardState extends State<NotaPersonalCard> {
  Future<void> _editar() async {
    final ctrl = TextEditingController(
      text: widget.usuario?.notaDe(widget.cancionId) ?? '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AllinDialog(
        titulo: 'Mi nota personal',
        mensaje: 'Esta nota es privada para esta canción y solo tú puedes verla.',
        icono: Icons.sticky_note_2_rounded,
        contenido: TextField(
          controller: ctrl,
          maxLines: 4,
          style: AppText.body.copyWith(color: AppColors.onSurface(context)),
          decoration: InputDecoration(
            hintText: 'Ej: Esta la toco con la 6 tapada o en tercia...',
            hintStyle: AppText.caption.copyWith(
              color: AppColors.onSurfaceVariant(context),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant(context).withOpacity(0.4),
            border: OutlineInputBorder(
              borderRadius: Rad.rMd,
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: Rad.rMd,
              borderSide: const BorderSide(color: AppColors.dorado, width: 1.5),
            ),
          ),
        ),
        acciones: [
          AllinButton(
            label: 'Cancelar',
            variant: AllinButtonVariant.glass,
            expand: true,
            onPressed: () => Navigator.pop(context, false),
          ),
          const SizedBox(height: 8),
          AllinButton(
            label: 'Guardar',
            variant: AllinButtonVariant.gold,
            expand: true,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (ok == true) {
      await UsuarioService().guardarNota(widget.cancionId, ctrl.text);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);
    final textoActual = widget.usuario?.notaDe(widget.cancionId) ?? '';

    return AppCard(
      padding: const EdgeInsets.all(Sp.lg),
      onTap: _editar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sticky_note_2_rounded,
                color: AppColors.dorado,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Mi Nota Personal',
                style: AppText.h3.copyWith(
                  color: AppColors.dorado,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.edit_rounded,
                color: AppColors.dorado.withOpacity(0.7),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: Sp.sm),
          Text(
            textoActual.isEmpty
                ? 'Toca aquí para escribir una nota privada (solo la ves tú).'
                : textoActual,
            style: AppText.body.copyWith(
              color: textoActual.isEmpty
                  ? onSurface.withOpacity(0.4)
                  : onSurface.withOpacity(0.9),
              fontStyle:
                  textoActual.isEmpty ? FontStyle.italic : FontStyle.normal,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
