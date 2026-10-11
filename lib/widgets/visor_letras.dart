import 'package:flutter/material.dart';

import '../models/cancion.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';

class VisorLetras extends StatelessWidget {
  final List<Letra> letras;

  const VisorLetras({super.key, required this.letras});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final validas = letras.where((l) => !l.vacia).toList();
    if (validas.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
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
                const Text(
                  'LETRAS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < validas.length; i++) ...[
            Divider(height: 1, color: AppColors.dorado.withOpacity(0.15)),
            ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              initiallyExpanded: validas.length == 1,
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.music_note, color: AppColors.granate, size: 18),
              ),
              title: Text(
                validas[i].titulo.isNotEmpty
                    ? validas[i].titulo
                    : 'LETRA ${romanoNumerofonia(i + 1)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate,
                  letterSpacing: 0.5,
                  fontSize: 14,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    validas[i].texto,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.9,
                      fontStyle: FontStyle.italic,
                      color: onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}