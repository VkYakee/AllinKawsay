// lib/design/components/app_chip.dart
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';
import '../typography.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: AppColors.cardColor(context),
      selectedColor: AppColors.granate,
      checkmarkColor: AppColors.dorado,
      labelStyle: AppType.label.copyWith(
        color: selected ? AppColors.dorado : onSurface,
        letterSpacing: 0.3,
      ),
      side: BorderSide(
        color: selected
            ? Colors.transparent
            : AppColors.granate.withOpacity(0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: Rad.rPill),
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm),
    );
  }
}