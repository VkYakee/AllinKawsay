// lib/features/cancion_detalle/widgets/cancion_tab_info.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/cancion.dart';
import '../../../models/usuario.dart';
import '../../../widgets/cancion/nota_personal_card.dart'; // Se mantiene el viejo por ahora

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
    final onSurface = AppColors.onSurface(context);
    
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
                  const Icon(Icons.info_outline, color: AppColors.dorado, size: 18),
                  const SizedBox(width: Sp.sm),
                  Text('INFORMACIÓN', style: AppText.label.copyWith(color: AppColors.dorado, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: Sp.md),
              _fila(Icons.person, 'Autor', cancion.autor.isEmpty ? '—' : cancion.autor, onSurface),
              _fila(Icons.category, 'Tipo', cancion.tipo == 'original' ? 'Original' : 'Adaptación', onSurface),
              _fila(Icons.graphic_eq, 'Ritmo', cancion.ritmo.isEmpty ? '—' : cancion.ritmo, onSurface),
              _fila(Icons.play_arrow, 'Reproducciones', '${cancion.reproducciones}', onSurface),
            ],
          ),
        ),
        if (cancion.descripcion.isNotEmpty) ...[
          const SizedBox(height: Sp.md),
          AppCard(
            glass: true,
            padding: const EdgeInsets.all(Sp.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notes, color: AppColors.dorado, size: 18),
                    const SizedBox(width: Sp.sm),
                    Text('DESCRIPCIÓN', style: AppText.label.copyWith(color: AppColors.dorado, letterSpacing: 1.5)),
                  ],
                ),
                const SizedBox(height: Sp.md),
                Text(
                  cancion.descripcion,
                  style: AppText.body.copyWith(color: onSurface.withOpacity(0.85), height: 1.5),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: Sp.md),
        NotaPersonalCard(cancionId: cancion.id, usuario: usuario),
        const SizedBox(height: Sp.xxxl),
      ],
    );
  }

  Widget _fila(IconData icono, String label, String valor, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.sm),
      child: Row(
        children: [
          Icon(icono, size: 18, color: AppColors.dorado),
          const SizedBox(width: Sp.md),
          Text('$label: ', style: AppText.subtitle.copyWith(color: onSurface.withOpacity(0.6))),
          Expanded(
            child: Text(valor, style: AppText.body.copyWith(color: onSurface)),
          ),
        ],
      ),
    );
  }
}