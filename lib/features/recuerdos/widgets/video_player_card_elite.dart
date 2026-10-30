// lib/features/recuerdos/widgets/video_player_card_elite.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../services/recuerdo_cache_service.dart';

/// Card élite del video: overlay de play grande, barra de progreso,
/// botón de mute, cache local + streaming paralelo.
class VideoPlayerCardElite extends StatefulWidget {
  final String recuerdoId;
  final String url;
  final int index;

  const VideoPlayerCardElite({
    super.key,
    required this.recuerdoId,
    required this.url,
    required this.index,
  });

  @override
  State<VideoPlayerCardElite> createState() => _VideoPlayerCardEliteState();
}

class _VideoPlayerCardEliteState extends State<VideoPlayerCardElite> {
  VideoPlayerController? _controller;
  bool _cargando = false;
  bool _iniciado = false;
  String? _error;
  bool _muted = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    if (_controller != null && _iniciado) {
      if (_controller!.value.isPlaying) {
        await _controller!.pause();
      } else {
        await _controller!.play();
      }
      setState(() {});
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final rutaLocal = await RecuerdoCacheService().rutaDe(
        widget.recuerdoId,
        'video',
        widget.index,
      );

      if (rutaLocal != null && await File(rutaLocal).exists()) {
        RecuerdoCacheService().marcarAcceso(
          widget.recuerdoId,
          'video',
          widget.index,
        );
        _controller = VideoPlayerController.file(
          File(rutaLocal),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.url),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        RecuerdoCacheService().descargarEnBackground(
          widget.recuerdoId,
          'video',
          widget.index,
          widget.url,
        );
      }

      await _controller!.initialize();
      _controller!.addListener(_onTick);
      if (mounted) {
        setState(() {
          _cargando = false;
          _iniciado = true;
        });
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

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _toggleMute() {
    if (_controller == null) return;
    AppMotion.hapticSelection();
    setState(() {
      _muted = !_muted;
      _controller!.setVolume(_muted ? 0 : 1);
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final inicializado = _controller?.value.isInitialized ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: Rad.rLg,
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: inicializado
                ? _controller!.value.aspectRatio
                : 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Video o placeholder
                if (inicializado)
                  VideoPlayer(_controller!)
                else
                  _buildPlaceholder(),

                // Overlay de play central
                if (!inicializado && !_cargando && _error == null)
                  GestureDetector(
                    onTap: _inicializar,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.granate.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.granate.withOpacity(0.6),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.dorado,
                        size: 40,
                      ),
                    ),
                  ),

                // Loading
                if (_cargando)
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: AppColors.dorado,
                      strokeWidth: 3,
                    ),
                  ),

                // Error
                if (_error != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: AppText.bodySm.copyWith(color: Colors.red),
                      ),
                    ],
                  ),

                // Tap para pausar/play cuando ya está inicializado
                if (inicializado)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _inicializar,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedOpacity(
                        opacity: _controller!.value.isPlaying ? 0.0 : 0.6,
                        duration: AppMotion.fast,
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.dorado,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Botón mute
                if (inicializado)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleMute,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.55),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Icon(
                          _muted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: AppColors.dorado,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                // Badge "Video N"
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sp.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: Rad.rPill,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: Text(
                      'Video ${widget.index + 1}',
                      style: AppText.captionXs.copyWith(
                        color: AppColors.dorado,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra de progreso
          if (inicializado)
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.md, 6, Sp.md, Sp.sm),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      activeTrackColor: AppColors.dorado,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: AppColors.dorado,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: _controller!.value.position.inMilliseconds
                          .toDouble()
                          .clamp(
                            0,
                            _controller!.value.duration.inMilliseconds
                                .toDouble(),
                          ),
                      max: _controller!.value.duration.inMilliseconds
                          .toDouble()
                          .clamp(1, 999999999),
                      onChanged: (v) {
                        _controller!
                            .seekTo(Duration(milliseconds: v.toInt()));
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fmt(_controller!.value.position),
                        style: AppText.captionXs.copyWith(
                          color: AppColors.dorado.withOpacity(0.8),
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        _fmt(_controller!.value.duration),
                        style: AppText.captionXs.copyWith(
                          color: AppColors.dorado.withOpacity(0.5),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Icon(
          Icons.videocam_rounded,
          size: 48,
          color: AppColors.dorado,
        ),
      ),
    );
  }
}