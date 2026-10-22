// lib/widgets/cancion_detalle/cancion_tab_comentarios.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/cancion.dart';
import '../cancion/comentarios_section.dart';

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
          padding: const EdgeInsets.all(Sp.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SeccionHeader(
                  title: 'Comentarios',
                  icon: Icons.comment,
                  padding: EdgeInsets.zero),
              const SizedBox(height: Sp.md),
              ComentariosSection(
                cancionId: cancion.id,
                puedeComentar: puedeComentar,
              ),
            ],
          ),
        ),
        const SizedBox(height: Sp.xl),
      ],
    );
  }
}