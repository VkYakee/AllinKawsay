// lib/design/components/app_skeleton.dart
//
// Skeleton con shimmer. Reemplaza los skeletons ad-hoc de cada pantalla.
//
// Uso:
//   AppSkeleton(height: 68)                    // 1 bloque
//   AppSkeletonCard()                          // card de lista
//   AppSkeletonList(items: 5)                  // lista de cards
//   AppSkeletonFeaturedCard()                  // card destacada

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';

class AppSkeleton extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const AppSkeleton({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppColors.granate.withOpacity(0.06);
    final highlight = AppColors.granate.withOpacity(0.14);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? Rad.rMd,
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _ctrl.value, 0),
              end: Alignment(1 + 2 * _ctrl.value, 0),
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Card de lista con skeleton (icono + 2 líneas de texto).
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sp.lg,
        vertical: Sp.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(Sp.md),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: Rad.rLg,
        ),
        child: Row(
          children: [
            const AppSkeleton(width: 44, height: 44),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppSkeleton(height: 14, width: 160),
                  SizedBox(height: Sp.sm),
                  AppSkeleton(height: 11, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card destacada (imagen grande + texto).
class AppSkeletonFeaturedCard extends StatelessWidget {
  const AppSkeletonFeaturedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: Rad.rLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSkeleton(
              height: 180,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Sp.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppSkeleton(height: 16, width: 200),
                  SizedBox(height: Sp.sm),
                  AppSkeleton(height: 12, width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista completa de skeletons.
class AppSkeletonList extends StatelessWidget {
  final int items;
  final bool featured;

  const AppSkeletonList({
    super.key,
    this.items = 5,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: Sp.md),
      itemCount: items,
      itemBuilder: (context, i) {
        if (featured && i == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: Sp.md),
            child: AppSkeletonFeaturedCard(),
          );
        }
        return const Padding(
          padding: EdgeInsets.only(bottom: Sp.sm),
          child: AppSkeletonCard(),
        );
      },
    );
  }
}