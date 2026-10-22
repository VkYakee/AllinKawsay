// lib/design/components/app_card.dart
//
// Card unificado con soporte para tap. Reemplaza Container+BoxDecoration
// repetido en todos los screens.

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;
  final bool elevated;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.border,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: color ?? AppColors.cardColor(context),
      borderRadius: Rad.rLg,
      border: border ??
          Border.all(color: AppColors.dorado.withOpacity(0.18), width: 1),
      boxShadow: elevated ? Elev.sm : null,
    );

    final container = Container(
      padding: padding ?? const EdgeInsets.all(Sp.lg),
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      borderRadius: Rad.rLg,
      child: InkWell(
        borderRadius: Rad.rLg,
        onTap: onTap,
        child: container,
      ),
    );
  }
}