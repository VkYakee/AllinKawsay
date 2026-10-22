// lib/screens/foto_fullscreen_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/design.dart';
import '../services/descarga_service.dart';
import '../theme/colors.dart';
import '../widgets/dialogo_descarga.dart';

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
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
      _transformController.value = Matrix4.identity()..translate(-pos.dx * (escala - 1), -pos.dy * (escala - 1))..scale(escala);
    }
  }

  Future<void> _descargar() async {
    final nombre = DescargaService.nombreConTimestamp(widget.titulo.isEmpty ? 'foto_allin_kawsay' : widget.titulo, 'jpg');
    final resultado = await DialogoDescarga.mostrar(context, url: widget.url, nombre: nombre, mime: 'image/jpeg');
    if (!mounted) return;
    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Guardado en Descargas: $resultado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: _toggleZoom,
              onDoubleTap: () {},
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0, maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: widget.heroTag ?? 'foto_fullscreen_${widget.url}',
                    child: CachedNetworkImage(
                      imageUrl: widget.url,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: AppColors.dorado)),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: AppColors.dorado, size: 60),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: Sp.xs),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent])),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.close, color: AppColors.dorado), onPressed: () => Navigator.pop(context)),
                    if (widget.titulo.isNotEmpty)
                      Expanded(child: Text(widget.titulo, style: AppType.subtitle.copyWith(color: AppColors.dorado), maxLines: 1, overflow: TextOverflow.ellipsis))
                    else
                      const Spacer(),
                    if (widget.puedeDescargar)
                      IconButton(icon: const Icon(Icons.download, color: AppColors.dorado), onPressed: _descargar),
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