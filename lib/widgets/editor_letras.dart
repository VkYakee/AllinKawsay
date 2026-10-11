import 'package:flutter/material.dart';

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
            onEliminar: widget.letras.length > 1
                ? () => setState(() {
                      widget.letras.removeAt(i);
                      _notify();
                    })
                : null,
          ),
          const SizedBox(height: 14),
        ],
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => setState(() {
              widget.letras.add(Letra());
              _notify();
            }),
            icon: const Icon(Icons.add, color: AppColors.granate, size: 18),
            label: const Text(
              'AGREGAR NUEVA LETRA',
              style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.granate.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
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

  const _CardLetra({
    required this.letra,
    required this.indice,
    required this.onCambio,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dorado.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lyrics_outlined,
                    color: AppColors.granate, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  key: ValueKey('tit-${identityHashCode(letra)}'),
                  initialValue: letra.titulo,
                  onChanged: (v) {
                    letra.titulo = v;
                    onCambio();
                  },
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'LETRA ${indice + 1} (título opcional)',
                    hintStyle: TextStyle(
                      color: onSurface.withOpacity(0.4),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (onEliminar != null)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onEliminar,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.granate.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey('txt-${identityHashCode(letra)}'),
            initialValue: letra.texto,
            onChanged: (v) {
              letra.texto = v;
              onCambio();
            },
            maxLines: 12,
            minLines: 5,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              fontStyle: FontStyle.italic,
              color: onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Escribí la letra completa con sus estrofas...',
              hintStyle: TextStyle(color: onSurface.withOpacity(0.35)),
              filled: true,
              fillColor: AppColors.granate.withOpacity(0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}