// lib/features/admin/widgets/stat_card.dart
import 'package:flutter/material.dart';

import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      glass: true,
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.granateProfundo, AppColors.granateOscuro],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.dorado.withOpacity(0.35),
              ),
            ),
            child: Icon(icon, color: AppColors.dorado, size: 22),
          ),
          const SizedBox(height: Sp.sm),
          Text(
            value,
            style: AppText.h2.copyWith(
              color: AppColors.dorado,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(
              color: AppColors.onSurfaceVariant(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
