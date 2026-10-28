// lib/design/components/app_scaffold.dart
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../tokens.dart';
import '../typography.dart'; // <-- IMPORT AGREGADO

class AppScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Future<void> Function()? onRefresh;

  const AppScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.fondoOscuro : const Color(0xFFF2F2F7);

    Widget content = Stack(
      children: [
        // Mesh Glow de fondo
        Positioned(
          top: -100, left: -100,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.granate.withOpacity(isDark ? 0.3 : 0.15), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50, right: -100,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.dorado.withOpacity(isDark ? 0.2 : 0.1), Colors.transparent],
              ),
            ),
          ),
        ),
        // Contenido
        SafeArea(
          bottom: false,
          child: onRefresh != null
              ? RefreshIndicator(onRefresh: onRefresh!, color: AppColors.dorado, child: body)
              : body,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: title == null ? null : _buildAppBar(context),
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title!, style: AppType.h2.copyWith(color: AppColors.dorado)),
          if (subtitle != null)
            Text(subtitle!, style: AppType.caption.copyWith(color: AppColors.dorado.withOpacity(0.6))),
        ],
      ),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}