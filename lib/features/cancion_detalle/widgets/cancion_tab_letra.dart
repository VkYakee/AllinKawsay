// lib/features/cancion_detalle/widgets/cancion_tab_letra.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/cancion.dart';

class CancionTabLetra extends StatelessWidget {
  final Cancion cancion;
  const CancionTabLetra({super.key, required this.cancion});

  @override
  Widget build(BuildContext context) {
    if (!cancion.tieneLetra) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lyrics_outlined, size: 64, color: AppColors.dorado.withOpacity(0.3)),
              const SizedBox(height: Sp.lg),
              Text('Sin letra', style: AppText.h3.copyWith(color: AppColors.dorado)),
              Text('Esta canción aún no tiene letra registrada.', style: AppText.body.copyWith(color: Colors.white54)),
            ],
          ),
        ),
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
            glass: true,
            padding: const EdgeInsets.all(Sp.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (letra.titulo.isNotEmpty) ...[
                  Text(
                    letra.titulo.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: AppText.label.copyWith(color: AppColors.dorado, letterSpacing: 2),
                  ),
                  const SizedBox(height: Sp.sm),
                  Divider(color: AppColors.dorado.withOpacity(0.2)),
                  const SizedBox(height: Sp.md),
                ],
                Text(
                  letra.texto,
                  textAlign: TextAlign.center,
                  style: AppText.body.copyWith(
                    fontSize: 16,
                    height: 1.8,
                    fontStyle: FontStyle.italic,
                    color: AppColors.onSurface(context),
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