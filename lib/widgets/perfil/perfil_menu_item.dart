// lib/widgets/perfil/perfil_menu_item.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Sp.lg, vertical: Sp.xs),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.md),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDanger
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.granate.withOpacity(0.08),
                borderRadius: Rad.rMd,
              ),
              child: Icon(
                icono,
                color: isDanger ? Colors.red : AppColors.granate,
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
                    style: AppType.subtitle.copyWith(
                      color: isDanger ? Colors.red : onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: AppType.captionXs.copyWith(
                      color: onSurface.withOpacity(0.55),
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