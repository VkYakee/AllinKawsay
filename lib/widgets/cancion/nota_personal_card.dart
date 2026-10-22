// lib/widgets/cancion/nota_personal_card.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/usuario.dart';
import '../../services/usuario_service.dart';
import '../../theme/colors.dart';

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
    final ctrl = TextEditingController(text: widget.usuario?.notaDe(widget.cancionId) ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Rad.rXl),
        title: Text('Mi nota personal', style: AppType.h3.copyWith(color: AppColors.granate)),
        content: AppInput(
          controller: ctrl,
          hint: 'Ej: esta la toco con la 6 tapada...',
          maxLines: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      await UsuarioService().guardarNota(widget.cancionId, ctrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final textoActual = widget.usuario?.notaDe(widget.cancionId) ?? '';

    return AppCard(
      padding: const EdgeInsets.all(Sp.lg),
      onTap: _editar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SeccionHeader(title: 'Mi Nota Personal', icon: Icons.sticky_note_2, padding: EdgeInsets.zero),
              const Spacer(),
              Icon(Icons.edit, color: AppColors.granate.withOpacity(0.5), size: 18),
            ],
          ),
          const SizedBox(height: Sp.sm),
          Text(
            textoActual.isEmpty
                ? 'Toca aquí para escribir una nota privada (solo la ves tú).'
                : textoActual,
            style: AppType.body.copyWith(
              color: textoActual.isEmpty ? onSurface.withOpacity(0.4) : onSurface.withOpacity(0.9),
              fontStyle: textoActual.isEmpty ? FontStyle.italic : FontStyle.normal,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}