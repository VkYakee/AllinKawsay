// lib/design/components/app_scaffold.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/watermark_overlay.dart';
import '../tokens.dart';
import '../typography.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool watermark;
  final Future<void> Function()? onRefresh;
  final EdgeInsets bodyPadding;
  final bool safeArea;
  final bool extendBodyBehindAppBar;

  const AppScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.watermark = false,
    this.onRefresh,
    this.bodyPadding = EdgeInsets.zero,
    this.safeArea = true,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget content = Padding(padding: bodyPadding, child: body);

    if (watermark) {
      content = WatermarkOverlay(opacity: 0.04, child: content);
    }

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.dorado,
        child: content,
      );
    }

    if (safeArea) {
      content = SafeArea(
        top: extendBodyBehindAppBar ? false : (title == null),
        bottom: false,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: title == null ? null : _buildFrostedAppBar(context, isDark),
      body: Stack(
        children: [
          // ── Luces ambientales de fondo para que el efecto Cristal resalte ──
          Positioned(
            top: -90,
            right: -70,
            child: IgnorePointer(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.granate.withOpacity(isDark ? 0.28 : 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -90,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.dorado.withOpacity(isDark ? 0.14 : 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Contenido real ──
          Positioned.fill(child: content),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  PreferredSizeWidget _buildFrostedAppBar(BuildContext context, bool isDark) {
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return AppBar(
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassBlur.medium,
            sigmaY: GlassBlur.medium,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1A090D).withOpacity(0.82),
                        const Color(0xFF120609).withOpacity(0.68),
                      ]
                    : [
                        AppColors.granateOscuro.withOpacity(0.92),
                        AppColors.granate.withOpacity(0.85),
                      ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.dorado.withOpacity(0.18),
                  width: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title!,
            style: AppType.h3.copyWith(
              color: AppColors.dorado,
              letterSpacing: -0.3,
            ),
          ),
          if (hasSubtitle)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: AppType.captionXs.copyWith(
                  color: AppColors.dorado.withOpacity(0.72),
                ),
              ),
            ),
        ],
      ),
      actions: [
        ...?actions,
        if (actions != null && actions!.isNotEmpty)
          const SizedBox(width: Sp.sm),
      ],
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
}
