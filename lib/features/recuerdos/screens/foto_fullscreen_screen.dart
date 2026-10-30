// lib/features/recuerdos/screens/foto_fullscreen_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../services/descarga_service.dart';
import '../../../widgets/dialogo_descarga.dart';

/// Visor fullscreen de foto con zoom (doble tap), immersive mode,
/// botón de descarga (si el usuario tiene permiso), Hero para transición.
class FotoFullscreenScreen extends StatefulWidget {
  final String url;
  final String titulo;
  final bool puedeDescargar;
  final String? heroTag;

  const FotoFullscreenScreen({
    super.key,
    required this.url,
    this.titulo = '',
    this.puedeDescargar = false,
    this.heroTag,
  });

  @override
  State<FotoFullscreenScreen> createState() => _FotoFullscreenScreenState();
}

class _FotoFullscreenScreenState extends State<FotoFullscreenScreen> {
  final _transformController = TransformationController();
  bool _zoomActivo = false;
  bool _pressedCerrar = false;
  bool _pressedDescargar = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _transformController.addListener(() {
      final z = _transformController.value.getMaxScaleOnAxis();
      if ((z > 1.05) != _zoomActivo) setState(() => _zoomActivo = z > 1.05);
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _toggleZoom(TapDownDetails details) {
    if (_zoomActivo) {
      _transformController.value = Matrix4.identity();
    } else {
      final pos = details.localPosition;
      const escala = 2.5;
      _transformController.value = Matrix4.identity()
        ..translate(-pos.dx * (escala - 1), -pos.dy * (escala - 1))
        ..scale(escala);
    }
  }

  Future<void> _descargar() async {
    final nombre = DescargaService.nombreConTimestamp(
      widget.titulo.isEmpty ? 'foto_allin_kawsay' : widget.titulo,
      'jpg',
    );
    final resultado = await DialogoDescarga.mostrar(
      context,
      url: widget.url,
      nombre: nombre,
      mime: 'image/jpeg',
      titulo: 'Descargando foto',
    );
    if (!mounted) return;
    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Guardado en Descargas',
            style: AppText.body.copyWith(color: AppColors.dorado),
          ),
          backgroundColor: AppColors.granateOscuro,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Imagen con zoom
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: _toggleZoom,
              onDoubleTap: () {},
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: widget.heroTag ?? 'foto_fullscreen_${widget.url}',
                    child: CachedNetworkImage(
                      imageUrl: widget.url,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.dorado,
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: AppColors.dorado,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sp.sm,
                  vertical: Sp.xs,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Botón cerrar con spring
                    GestureDetector(
                      onTapDown: (_) => setState(() => _pressedCerrar = true),
                      onTapUp: (_) => setState(() => _pressedCerrar = false),
                      onTapCancel: () => setState(() => _pressedCerrar = false),
                      onTap: () {
                        AppMotion.hapticSelection();
                        Navigator.pop(context);
                      },
                      child: AnimatedScale(
                        scale: _pressedCerrar ? 0.85 : 1.0,
                        duration: AppMotion.fast,
                        curve: AppMotion.bouncy,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                            border: Border.all(
                              color: AppColors.dorado.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.dorado,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: Sp.md),

                    // Título
                    Expanded(
                      child: widget.titulo.isEmpty
                          ? const SizedBox.shrink()
                          : Text(
                              widget.titulo,
                              style: AppText.subtitle.copyWith(
                                color: AppColors.dorado,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),

                    // Botón descarga
                    if (widget.puedeDescargar)
                      GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _pressedDescargar = true),
                        onTapUp: (_) =>
                            setState(() => _pressedDescargar = false),
                        onTapCancel: () =>
                            setState(() => _pressedDescargar = false),
                        onTap: () {
                          AppMotion.hapticSelection();
                          _descargar();
                        },
                        child: AnimatedScale(
                          scale: _pressedDescargar ? 0.85 : 1.0,
                          duration: AppMotion.fast,
                          curve: AppMotion.bouncy,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                              border: Border.all(
                                color: AppColors.dorado.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.download_rounded,
                              color: AppColors.dorado,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Indicador de zoom
          if (_zoomActivo)
            Positioned(
              bottom: Sp.xxl,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sp.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: Rad.rPill,
                    border: Border.all(
                      color: AppColors.dorado.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.zoom_in,
                        color: AppColors.dorado,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Doble tap para ajustar',
                        style: AppText.captionXs.copyWith(
                          color: AppColors.dorado,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}