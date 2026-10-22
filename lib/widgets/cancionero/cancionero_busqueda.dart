// lib/widgets/cancionero/cancionero_busqueda.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class CancioneroBusqueda extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final bool hasText;

  const CancioneroBusqueda({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    required this.hasText,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: Rad.rLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppType.body.copyWith(color: onSurface),
          decoration: InputDecoration(
            hintText: 'Buscar por título, autor o ritmo...',
            hintStyle: AppType.body.copyWith(
              color: onSurface.withOpacity(0.4),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.granate.withOpacity(0.7),
              size: 22,
            ),
            suffixIcon: hasText
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: onSurface.withOpacity(0.5),
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Sp.md,
              vertical: Sp.lg,
            ),
          ),
        ),
      ),
    );
  }
}