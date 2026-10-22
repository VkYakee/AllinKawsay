// lib/widgets/perfil/perfil_admin_banner.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class PerfilAdminBanner extends StatelessWidget {
  final VoidCallback onTap;

  const PerfilAdminBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Sp.lg, vertical: Sp.md),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.xl),
        color: AppColors.granate,
        border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.sm),
              decoration: BoxDecoration(
                color: AppColors.dorado.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings,
                  color: AppColors.dorado, size: 28),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panel de Administración',
                    style: AppType.subtitle.copyWith(
                      color: AppColors.dorado,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Métricas y gestión del grupo',
                    style: AppType.captionXs.copyWith(
                      color: AppColors.dorado.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: AppColors.dorado, size: 16),
          ],
        ),
      ),
    );
  }
}