// lib/widgets/setlist/setlist_lista_bloques.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/bloque_audio.dart';
import '../../theme/colors.dart';

class SetlistListaBloques extends StatelessWidget {
  final List<BloqueAudio> bloques;
  final ScrollController scrollCtrl;
  final void Function(int index) onEditar;
  final void Function(int index) onRegrabarTiming;
  final void Function(int index) onGrabarKaraoke; // <-- NUEVO
  final void Function(int index) onEliminar;

  const SetlistListaBloques({
    super.key,
    required this.bloques,
    required this.scrollCtrl,
    required this.onEditar,
    required this.onRegrabarTiming,
    required this.onGrabarKaraoke, // <-- NUEVO
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (bloques.isEmpty) {
      return const AppEmptyState(
        icon: Icons.queue_music,
        title: 'Sin bloques aún',
        subtitle: 'Reproduce el audio y toca MARCAR BLOQUE en cada sección nueva.',
      );
    }

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, Sp.xxxl),
      itemCount: bloques.length,
      itemBuilder: (context, i) {
        final b = bloques[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: Sp.sm),
          child: AppCard(
            padding: const EdgeInsets.all(Sp.md),
            onTap: () => onEditar(i),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36, alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: AppColors.gradienteGranate, borderRadius: Rad.rMd),
                  child: Text('${i + 1}', style: AppType.subtitle.copyWith(color: AppColors.dorado)),
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.label, style: AppType.subtitle),
                      Text(b.inicioFormateado, style: AppType.mono.copyWith(color: AppColors.granate, fontSize: 11)),
                    ],
                  ),
                ),
                if (b.tieneVisual)
                  IconButton(
                    icon: Icon(Icons.timer, color: b.tieneTimingA ? Colors.green : Colors.grey, size: 20),
                    onPressed: () => onRegrabarTiming(i),
                    tooltip: 'Timing Notas',
                  ),
                if (b.conLetra)
                  IconButton(
                    icon: Icon(Icons.text_fields, color: b.karaokeFragments.isNotEmpty ? Colors.green : Colors.grey, size: 20),
                    onPressed: () => onGrabarKaraoke(i),
                    tooltip: 'Timing Letra (Karaoke)',
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => onEliminar(i),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}