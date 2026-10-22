// lib/design/components/app_choice_chip.dart
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';
import '../typography.dart';

class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: icon != null ? Icon(icon, size: 16, color: selected ? AppColors.dorado : AppColors.granate) : null,
      backgroundColor: AppColors.cardColor(context),
      selectedColor: AppColors.granate,
      labelStyle: AppType.label.copyWith(
        color: selected ? AppColors.dorado : onSurface,
        letterSpacing: 0.3,
      ),
      side: BorderSide(
        color: selected ? Colors.transparent : AppColors.granate.withOpacity(0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: Rad.rPill),
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm),
    );
  }
}