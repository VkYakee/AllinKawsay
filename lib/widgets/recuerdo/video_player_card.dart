import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/recuerdo_cache_service.dart';
import '../../theme/colors.dart';

class VideoPlayerCard extends StatefulWidget {
  final String recuerdoId;
  final String url;
  final int index;

  const VideoPlayerCard({
    super.key,
    required this.recuerdoId,
    required this.url,
    required this.index,
  });

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  VideoPlayerController? _controller;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    if (_controller != null) {
      setState(() {
        _controller!.value.isPlaying
            ? _controller!.pause()
            : _controller!.play();
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      // 1) Buscar en cache
      final rutaLocal = await RecuerdoCacheService()
          .rutaDe(widget.recuerdoId, 'video', widget.index);

      if (rutaLocal != null && await File(rutaLocal).exists()) {
        // ✅ Usar cache local
        RecuerdoCacheService()
            .marcarAcceso(widget.recuerdoId, 'video', widget.index);
        _controller = VideoPlayerController.file(
          File(rutaLocal),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        // 🌐 Streaming + descarga en paralelo
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        // Descargar en background para el próximo uso
        RecuerdoCacheService().descargarEnBackground(
            widget.recuerdoId, 'video', widget.index, widget.url);
      }

      await _controller!.initialize();
      if (mounted) {
        setState(() => _cargando = false);
        _controller!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar el video';
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inicializado = _controller?.value.isInitialized ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio:
                inicializado ? _controller!.value.aspectRatio : 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (inicializado)
                  VideoPlayer(_controller!)
                else
                  Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.videocam,
                              size: 48, color: AppColors.dorado),
                          const SizedBox(height: 8),
                          Text(
                            'Video ${widget.index + 1}',
                            style: const TextStyle(
                              color: AppColors.dorado,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_cargando)
                  const CircularProgressIndicator(
                      color: AppColors.dorado),
                if (_error != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                if (!inicializado && !_cargando && _error == null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _inicializar,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.granate,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: AppColors.dorado, size: 32),
                      ),
                    ),
                  ),
                if (inicializado && !_cargando)
                  Positioned(
                    bottom: 12,
                    child: IconButton(
                      icon: Icon(
                        _controller!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: AppColors.dorado,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller!.value.isPlaying
                              ? _controller!.pause()
                              : _controller!.play();
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}