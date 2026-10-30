// lib/features/perfil/widgets/perfil_menu_item.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

class PerfilMenuItem extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  final bool isDanger;

  const PerfilMenuItem({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.xs),
      child: AppCard(
        glass: true,
        padding: const EdgeInsets.all(Sp.md),
        onTap: () {
          AppMotion.hapticLight();
          onTap();
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDanger ? Colors.red.withOpacity(0.1) : AppColors.granate.withOpacity(0.2),
                borderRadius: Rad.rMd,
              ),
              child: Icon(
                icono,
                color: isDanger ? Colors.red : AppColors.dorado,
                size: 20,
              ),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppText.subtitle.copyWith(
                      color: isDanger ? Colors.red : onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: AppText.captionXs.copyWith(
                      color: onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.dorado.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}