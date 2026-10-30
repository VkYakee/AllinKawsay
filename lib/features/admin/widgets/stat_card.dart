// lib/features/admin/widgets/stat_card.dart
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../theme/colors.dart';

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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return AppCard(
      padding: const EdgeInsets.all(Sp.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Sp.sm),
            decoration: BoxDecoration(
              color: AppColors.granate.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.granate, size: 24),
          ),
          const SizedBox(height: Sp.sm),
          Text(
            value,
            style: AppType.h2.copyWith(color: AppColors.granate),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppType.captionXs.copyWith(
              color: onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}