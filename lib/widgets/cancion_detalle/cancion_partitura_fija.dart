// lib/widgets/cancion_detalle/cancion_partitura_fija.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/cancion.dart';
import '../../screens/numerofonia_fullscreen_screen.dart';
import '../../theme/colors.dart';
import '../visor_numerofonia.dart';

class CancionPartituraFija extends StatelessWidget {
  final Cancion cancion;
  const CancionPartituraFija({super.key, required this.cancion});

  @override
  Widget build(BuildContext context) {
    if (!cancion.tieneNumerofonia) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.lg),
        border: Border.all(color: AppColors.dorado.withOpacity(0.4), width: 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.grid_on, color: AppColors.granate, size: 18),
                const SizedBox(width: Sp.sm),
                Text(
                  'PARTITURA',
                  style: AppType.label.copyWith(color: AppColors.granate, letterSpacing: 1.5),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NumerofoniaFullscreenScreen(estrofas: cancion.estrofas),
                      ),
                    );
                  },
                  borderRadius: Rad.rPill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.granate.withOpacity(0.1),
                      borderRadius: Rad.rPill,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.zoom_out_map, color: AppColors.granate, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'AMPLIAR',
                          style: AppType.labelXs.copyWith(color: AppColors.granate),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sp.lg),
            // Llamamos a la tabla, SIN SingleChildScrollView para que se auto-escale.
            VisorNumerofonia(
              estrofas: cancion.estrofas,
              escala: 1.0,
            ),
          ],
        ),
      ),
    );
  }
}