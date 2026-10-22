// lib/design/components/app_scaffold.dart
//
// Scaffold unificado de la nueva UI.
//
// Uso simple:
//   AppScaffold(
//     title: 'Cancionero',
//     subtitle: '32 canciones',
//     body: ListView(...),
//   )
//
// Uso con acciones:
//   AppScaffold(
//     title: 'Eventos',
//     actions: [IconButton(icon: Icon(Icons.add), onPressed: ...)],
//     body: StreamBuilder(...),
//   )
//
// Uso con watermark (fondo con logo circular sutil):
//   AppScaffold(title: '...', watermark: true, body: ...)
//
// Uso con pull-to-refresh:
//   AppScaffold(title: '...', onRefresh: _cargar, body: ...)

import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/watermark_overlay.dart';
import '../tokens.dart';

class AppScaffold extends StatelessWidget {
  /// Título grande. Si es null, no se muestra la appbar (útil para
  /// pantallas full-screen tipo login o presentación).
  final String? title;

  /// Texto secundario debajo del título (conteo, descripción corta).
  final String? subtitle;

  /// Widgets a la derecha de la appbar (íconos, menú).
  final List<Widget>? actions;

  /// Contenido principal.
  final Widget body;

  /// FAB opcional.
  final Widget? floatingActionButton;

  /// Bottom nav opcional.
  final Widget? bottomNavigationBar;

  /// Marca de agua (logo circular sutil al centro).
  final bool watermark;

  /// Si no es null, envuelve el body en RefreshIndicator.
  final Future<void> Function()? onRefresh;

  /// Padding interno del body. Por defecto 0 (las listas manejan su
  /// propio padding con sus items).
  final EdgeInsets bodyPadding;

  /// Respeta el safe area (notch, barra de gestos). Por defecto true.
  final bool safeArea;

  /// Si true, el body arranca detrás de la appbar (para headers
  /// con imagen de fondo). Por defecto false.
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
      content = SafeArea(top: title == null, bottom: false, child: content);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: title == null ? null : _buildAppBar(context),
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title!,
            style: const TextStyle(
              color: AppColors.dorado,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
              height: 1.1,
            ),
          ),
          if (hasSubtitle)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(
                  color: AppColors.dorado.withOpacity(0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
      actions: [
        ...?actions,
        if (actions != null && actions!.isNotEmpty) const SizedBox(width: Sp.sm),
      ],
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
}