import 'package:flutter/material.dart';
import '../../models/cancion.dart';
import '../../screens/numerofonia_fullscreen_screen.dart';
import '../../theme/colors.dart';

class HeaderNumerofonia extends StatelessWidget {
  final Cancion cancion;

  const HeaderNumerofonia({
    super.key,
    required this.cancion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.grid_on, color: AppColors.granate, size: 14),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Numerofonía',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.granate, fontSize: 13, letterSpacing: 1),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NumerofoniaFullscreenScreen(estrofas: cancion.estrofas),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.granate.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.zoom_out_map, size: 13, color: AppColors.granate),
                  const SizedBox(width: 5),
                  Text(
                    'Pantalla completa',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate.withOpacity(0.9),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}