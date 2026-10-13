import 'package:flutter/material.dart';
import '../../models/cancion.dart';
import '../../theme/colors.dart';

class InformacionExpandible extends StatelessWidget {
  final Cancion cancion;

  const InformacionExpandible({
    super.key,
    required this.cancion,
  });

  @override
  Widget build(BuildContext context) {
    final c = cancion;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.info_outline, color: AppColors.granate, size: 18),
        ),
        title: const Text(
          'Información',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.granate, letterSpacing: 0.5),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _filaInfo(context, Icons.person, 'Autor', c.autor.isEmpty ? '—' : c.autor),
                _filaInfo(context, Icons.category, 'Tipo', c.tipo == 'original' ? 'Original' : 'Adaptación'),
                _filaInfo(context, Icons.graphic_eq, 'Ritmo', c.ritmo.isEmpty ? '—' : c.ritmo),
                _filaInfo(context, Icons.play_arrow, 'Reproducciones', '${c.reproducciones}'),
                if (c.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: c.tags
                          .map((t) => Chip(
                                label: Text(t, style: const TextStyle(fontSize: 11)),
                                backgroundColor: AppColors.dorado.withOpacity(0.15),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ),
                if (c.creadorNombre.isNotEmpty)
                  _filaInfo(context, Icons.upload, 'Subido por', c.creadorNombre),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaInfo(BuildContext context, IconData icono, String label, String valor) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icono, size: 18, color: AppColors.granate),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: onSurface.withOpacity(0.7), fontSize: 13)),
          Expanded(child: Text(valor, style: TextStyle(color: onSurface, fontSize: 13))),
        ],
      ),
    );
  }
}