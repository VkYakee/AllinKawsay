// lib/widgets/editor_letras.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/cancion.dart';
import '../theme/colors.dart';

class EditorLetras extends StatefulWidget {
  final List<Letra> letras;
  final VoidCallback? onChanged;

  const EditorLetras({super.key, required this.letras, this.onChanged});

  @override
  State<EditorLetras> createState() => _EditorLetrasState();
}

class _EditorLetrasState extends State<EditorLetras> {
  @override
  void initState() {
    super.initState();
    if (widget.letras.isEmpty) widget.letras.add(Letra());
  }

  void _notify() => widget.onChanged?.call();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < widget.letras.length; i++) ...[
          _CardLetra(
            letra: widget.letras[i],
            indice: i,
            onCambio: _notify,
            onEliminar: widget.letras.length > 1 ? () => setState(() { widget.letras.removeAt(i); _notify(); }) : null,
          ),
          const SizedBox(height: Sp.md),
        ],
        AppButton(
          label: 'AGREGAR NUEVA LETRA',
          icon: Icons.add,
          variant: AppButtonVariant.secondary,
          onPressed: () => setState(() { widget.letras.add(Letra()); _notify(); }),
        ),
      ],
    );
  }
}

class _CardLetra extends StatelessWidget {
  final Letra letra;
  final int indice;
  final VoidCallback onCambio;
  final VoidCallback? onEliminar;

  const _CardLetra({required this.letra, required this.indice, required this.onCambio, this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.lg),
      decoration: BoxDecoration(color: AppColors.cardColor(context), borderRadius: Rad.rLg, border: Border.all(color: AppColors.dorado.withOpacity(0.25))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.lyrics_outlined, color: AppColors.granate, size: 20),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: TextFormField(
                  initialValue: letra.titulo,
                  onChanged: (v) { letra.titulo = v; onCambio(); },
                  style: AppType.subtitle.copyWith(color: AppColors.granate),
                  decoration: InputDecoration(hintText: 'LETRA ${indice + 1} (título)', border: InputBorder.none, isDense: true),
                ),
              ),
              if (onEliminar != null) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onEliminar),
            ],
          ),
          const SizedBox(height: Sp.sm),
          TextFormField(
            initialValue: letra.texto,
            onChanged: (v) { letra.texto = v; onCambio(); },
            maxLines: 10, minLines: 5,
            style: AppType.body.copyWith(height: 1.6, fontStyle: FontStyle.italic),
            decoration: InputDecoration(
              hintText: 'Escribe la letra completa...',
              filled: true,
              fillColor: AppColors.granate.withOpacity(0.03),
              border: OutlineInputBorder(borderRadius: Rad.rMd, borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}