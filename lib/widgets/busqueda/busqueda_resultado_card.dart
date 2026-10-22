// lib/widgets/busqueda/busqueda_resultado_card.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class BusquedaResultadoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const BusquedaResultadoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.md),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.gradienteGranate,
                borderRadius: Rad.rMd,
              ),
              child: Icon(icon, color: AppColors.dorado, size: 20),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppType.subtitle.copyWith(color: onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle, style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.dorado.withOpacity(0.6), size: 20),
          ],
        ),
      ),
    );
  }
}