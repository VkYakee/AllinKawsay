// lib/widgets/cancion_detalle/cancion_tab_info.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/cancion.dart';
import '../../models/usuario.dart';
import '../../theme/colors.dart';
import '../cancion/nota_personal_card.dart';

class CancionTabInfo extends StatelessWidget {
  final Cancion cancion;
  final Usuario? usuario;

  const CancionTabInfo({
    super.key,
    required this.cancion,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ListView(
      padding: const EdgeInsets.all(Sp.lg),
      children: [
        AppCard(
          padding: const EdgeInsets.all(Sp.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SeccionHeader(
                  title: 'Información',
                  icon: Icons.info_outline,
                  padding: EdgeInsets.zero),
              const SizedBox(height: Sp.md),
              _fila(Icons.person, 'Autor',
                  cancion.autor.isEmpty ? '—' : cancion.autor, onSurface),
              _fila(Icons.category, 'Tipo',
                  cancion.tipo == 'original' ? 'Original' : 'Adaptación',
                  onSurface),
              _fila(Icons.graphic_eq, 'Ritmo',
                  cancion.ritmo.isEmpty ? '—' : cancion.ritmo, onSurface),
              _fila(Icons.play_arrow, 'Reproducciones',
                  '${cancion.reproducciones}', onSurface),
            ],
          ),
        ),
        if (cancion.descripcion.isNotEmpty) ...[
          const SizedBox(height: Sp.md),
          AppCard(
            padding: const EdgeInsets.all(Sp.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SeccionHeader(
                    title: 'Descripción',
                    icon: Icons.notes,
                    padding: EdgeInsets.zero),
                const SizedBox(height: Sp.md),
                Text(cancion.descripcion,
                    style: AppType.body
                        .copyWith(color: onSurface.withOpacity(0.85))),
              ],
            ),
          ),
        ],
        const SizedBox(height: Sp.md),
        NotaPersonalCard(cancionId: cancion.id, usuario: usuario),
        const SizedBox(height: Sp.xl),
      ],
    );
  }

  Widget _fila(
      IconData icono, String label, String valor, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.sm),
      child: Row(
        children: [
          Icon(icono, size: 18, color: AppColors.granate),
          const SizedBox(width: Sp.md),
          Text('$label: ',
              style: AppType.subtitle
                  .copyWith(color: onSurface.withOpacity(0.7))),
          Expanded(
            child: Text(valor,
                style: AppType.body.copyWith(color: onSurface)),
          ),
        ],
      ),
    );
  }
}