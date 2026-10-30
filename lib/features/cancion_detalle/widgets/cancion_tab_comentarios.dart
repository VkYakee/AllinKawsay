// lib/features/cancion_detalle/widgets/cancion_tab_comentarios.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/cancion.dart';
import '../../../widgets/cancion/comentarios_section.dart'; // Se mantiene el viejo por ahora

class CancionTabComentarios extends StatelessWidget {
  final Cancion cancion;
  final bool puedeComentar;

  const CancionTabComentarios({
    super.key,
    required this.cancion,
    required this.puedeComentar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Sp.lg),
      children: [
        AppCard(
          glass: true,
          padding: const EdgeInsets.all(Sp.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.comment, color: AppColors.dorado, size: 18),
                  const SizedBox(width: Sp.sm),
                  Text('COMENTARIOS', style: AppText.label.copyWith(color: AppColors.dorado, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: Sp.md),
              ComentariosSection(
                cancionId: cancion.id,
                puedeComentar: puedeComentar,
              ),
            ],
          ),
        ),
        const SizedBox(height: Sp.xxxl),
      ],
    );
  }
}