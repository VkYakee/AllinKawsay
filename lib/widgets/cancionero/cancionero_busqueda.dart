// lib/widgets/cancionero/cancionero_busqueda.dart
import 'dart:ui';
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
      child: ClipRRect(
        borderRadius: Rad.rLg,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor(context).withOpacity(0.7),
              borderRadius: Rad.rLg,
              border: Border.all(color: AppColors.dorado.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppType.body.copyWith(color: onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar canciones, autores, ritmos...',
                hintStyle: AppType.body.copyWith(color: onSurface.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: AppColors.granate.withOpacity(0.8), size: 24),
                suffixIcon: hasText
                    ? IconButton(
                        icon: Icon(Icons.close, size: 20, color: onSurface.withOpacity(0.5)),
                        onPressed: onClear,
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.lg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}