// lib/widgets/inicio/tarjeta_historia.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../screens/historia_screen.dart';
import '../../theme/colors.dart';

class TarjetaHistoria extends StatelessWidget {
  const TarjetaHistoria({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.lg),
        border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoriaScreen())),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(gradient: AppColors.gradienteDorado, borderRadius: Rad.rMd),
              child: const Icon(Icons.auto_stories, color: AppColors.granate, size: 24),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Conoce nuestra historia', style: AppType.subtitle.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                  Text('Cómo empezó el grupo y sus logros', style: AppType.captionXs.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.dorado, size: 16),
          ],
        ),
      ),
    );
  }
}