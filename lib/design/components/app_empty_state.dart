// lib/design/components/app_empty_state.dart
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';
import '../typography.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sp.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.granate.withOpacity(0.12),
                    AppColors.granate.withOpacity(0.02),
                  ],
                ),
              ),
              child: Icon(
                icon,
                size: 44,
                color: AppColors.granate.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: Sp.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppType.h3.copyWith(
                color: AppColors.seccionTitulo(context),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: Sp.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppType.bodySm.copyWith(
                  color: onSurface.withOpacity(0.55),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Sp.xl),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 16),
                label: Text(actionLabel!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.granate,
                  side: BorderSide(
                    color: AppColors.granate.withOpacity(0.6),
                    width: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sp.lg,
                    vertical: Sp.md,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}