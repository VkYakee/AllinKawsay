// lib/design/components/seccion_header.dart
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';

class SeccionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final int? badgeCount;
  final EdgeInsets padding;

  const SeccionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.badgeCount,
    this.padding = const EdgeInsets.fromLTRB(Sp.xl, Sp.lg, Sp.xl, Sp.md),
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.seccionTitulo(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(Sp.sm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: Sp.md),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppType.h3.copyWith(
                    color: color,
                    fontSize: 18,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (badgeCount != null && badgeCount! > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.granate.withOpacity(0.12),
                    borderRadius: Rad.rPill,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: Sp.sm),
              ],
              if (actionLabel != null && onAction != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel!,
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: Sp.xs),
            Padding(
              padding: EdgeInsets.only(left: icon != null ? 36 : 0),
              child: Text(
                subtitle!,
                style: AppType.caption.copyWith(color: onSurface.withOpacity(0.55)),
              ),
            ),
          ],
          const SizedBox(height: Sp.sm),
          // Línea de acento
          Container(
            height: 2,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.1)]),
              borderRadius: Rad.rPill,
            ),
          ),
        ],
      ),
    );
  }
}