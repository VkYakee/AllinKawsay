import 'package:flutter/material.dart';
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
  Future<void> _editarNota() async {
    final ctrl = TextEditingController(
      text: widget.usuario?.notaDe(widget.cancionId) ?? '',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mi nota personal'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: esta la toco con la 6 tapada, entrada en la 3ra...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.dorado.withOpacity(0.1),
            AppColors.dorado.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.dorado.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sticky_note_2, color: AppColors.granate, size: 14),
              ),
              const SizedBox(width: 10),
              const Text(
                'Mi nota personal',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.granate, fontSize: 13, letterSpacing: 1),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.granate, size: 18),
                onPressed: _editarNota,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (textoActual.isEmpty)
            Text(
              'Toca el lápiz para escribir una nota privada (solo la ves vos)',
              style: TextStyle(color: onSurface.withOpacity(0.5), fontStyle: FontStyle.italic, fontSize: 12),
            )
          else
            Text(
              textoActual,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: onSurface, height: 1.5),
            ),
        ],
      ),
    );
  }
}