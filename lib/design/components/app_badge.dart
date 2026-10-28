// lib/design/components/app_badge.dart
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';
import '../typography.dart';

enum AppBadgeVariant { gold, granate, success, warning, danger, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = AppBadgeVariant.gold,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: Rad.rPill,
        border: Border.all(color: fg.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppType.labelXs.copyWith(color: fg)),
        ],
      ),
    );
  }

  (Color, Color) _resolve() {
    switch (variant) {
      case AppBadgeVariant.gold:
        return (AppColors.dorado.withOpacity(0.15), AppColors.doradoOscuro);
      case AppBadgeVariant.granate:
        return (AppColors.granate.withOpacity(0.1), AppColors.granate);
      case AppBadgeVariant.success:
        return (Colors.green.withOpacity(0.15), Colors.green.shade700);
      case AppBadgeVariant.warning:
        return (Colors.orange.withOpacity(0.15), Colors.orange.shade800);
      case AppBadgeVariant.danger:
        return (Colors.red.withOpacity(0.15), Colors.red.shade700);
      case AppBadgeVariant.neutral:
        return (Colors.grey.withOpacity(0.15), Colors.grey.shade600);
    }
  }
}