// lib/widgets/cancion_detalle/cancion_tab_letra.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/cancion.dart';
import '../../theme/colors.dart';

class CancionTabLetra extends StatelessWidget {
  final Cancion cancion;
  const CancionTabLetra({super.key, required this.cancion});

  @override
  Widget build(BuildContext context) {
    if (!cancion.tieneLetra) {
      return const AppEmptyState(
        icon: Icons.lyrics_outlined,
        title: 'Sin letra',
        subtitle: 'Esta canción aún no tiene letra.',
      );
    }

    final validas = cancion.letras.where((l) => !l.vacia).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(Sp.lg),
      itemCount: validas.length,
      itemBuilder: (context, i) {
        final letra = validas[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: Sp.md),
          child: AppCard(
            padding: const EdgeInsets.all(Sp.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (letra.titulo.isNotEmpty) ...[
                  Text(
                    letra.titulo.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppType.eyebrow.copyWith(color: AppColors.granate),
                  ),
                  const SizedBox(height: Sp.sm),
                ],
                Text(
                  letra.texto,
                  textAlign: TextAlign.center,
                  style: AppType.body.copyWith(
                    fontSize: 16,
                    height: 1.8,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}