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
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 6),
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDanger 
                    ? Colors.red.withOpacity(0.15) 
                    : AppColors.granate.withOpacity(0.3),
                borderRadius: Rad.rMd,
                border: Border.all(
                  color: isDanger 
                      ? Colors.red.withOpacity(0.3) 
                      : AppColors.dorado.withOpacity(0.2),
                ),
              ),
              child: Icon(
                icono,
                color: isDanger ? Colors.redAccent : AppColors.dorado,
                size: 22,
              ),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppText.title.copyWith(
                      color: isDanger ? Colors.redAccent : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: AppText.captionXs.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.dorado.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}