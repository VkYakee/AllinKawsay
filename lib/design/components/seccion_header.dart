// lib/design/components/seccion_header.dart
//
// Header de sección: ícono + título + acción opcional + badge de conteo.
//
// Uso:
//   SeccionHeader(title: 'Canciones recientes', icon: Icons.music_note)
//   SeccionHeader(title: 'Eventos', icon: Icons.event, badgeCount: 3)
//   SeccionHeader(
//     title: 'Categorías',
//     icon: Icons.category,
//     actionLabel: 'Editar',
//     onAction: _editarCategorias,
//   )

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';

class SeccionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final int? badgeCount;
  final EdgeInsets padding;

  const SeccionHeader({
    super.key,
    required this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.badgeCount,
    this.padding = const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.seccionTitulo(context);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.1),
                borderRadius: Rad.rSm,
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: Sp.sm),
          ],
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          if (badgeCount != null && badgeCount! > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Sp.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.12),
                borderRadius: Rad.rPill,
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: Sp.sm),
          ],
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sp.sm,
                  vertical: Sp.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}