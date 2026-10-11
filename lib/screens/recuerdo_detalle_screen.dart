import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/recuerdo.dart';
import '../models/usuario.dart';
import '../services/descarga_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';
import 'foto_fullscreen_screen.dart';

class RecuerdoDetalleScreen extends StatefulWidget {
  final Recuerdo recuerdo;

  const RecuerdoDetalleScreen({super.key, required this.recuerdo});

  @override
  State<RecuerdoDetalleScreen> createState() => _RecuerdoDetalleScreenState();
}

class _RecuerdoDetalleScreenState extends State<RecuerdoDetalleScreen> {
  Usuario? _usuario;
  VideoPlayerController? _videoController;
  int _videoActual = -1;
  bool _videoCargando = false;
  String? _errorVideo;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoStateChanged);
    _videoController?.dispose();
    super.dispose();
  }

  void _onVideoStateChanged() {
    if (!mounted) return;
    if (_videoController!.value.hasError) {
      setState(() {
        _errorVideo = 'Error al cargar el video';
        _videoCargando = false;
      });
    }
  }

  Future<void> _inicializarVideo(int index) async {
    if (index >= widget.recuerdo.videos.length) return;

    if (_videoActual == index && _videoController != null) {
      setState(() {
        _videoController!.value.isPlaying
            ? _videoController!.pause()
            : _videoController!.play();
      });
      return;
    }

    _videoController?.removeListener(_onVideoStateChanged);
    await _videoController?.dispose();

    setState(() {
      _videoCargando = true;
      _errorVideo = null;
      _videoActual = index;
    });

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.recuerdo.videos[index]),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _videoController!.addListener(_onVideoStateChanged);
      await _videoController!.initialize();

      if (mounted) {
        setState(() => _videoCargando = false);
        _videoController!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorVideo = 'No se pudo cargar el video';
          _videoCargando = false;
        });
      }
    }
  }

  Future<void> _editarNota() async {
    final ctrl = TextEditingController(
      text: _usuario?.notaRecuerdo(widget.recuerdo.id) ?? '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nota: ${widget.recuerdo.titulo}'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: yo estoy en la tercera foto, qué lindo día...',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      await UsuarioService()
          .guardarNotaRecuerdo(widget.recuerdo.id, ctrl.text);
      await _cargarUsuario();
    }
  }

  void _verFoto(String url, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotoFullscreenScreen(
          url: url,
          titulo:
              '${widget.recuerdo.titulo} (${index + 1}/${widget.recuerdo.fotos.length})',
          puedeDescargar: _usuario?.puedeDescargar ?? false,
        ),
      ),
    );
  }

  Future<void> _descargarFoto(String url) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.dorado,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Descargando...'),
            ],
          ),
          duration: const Duration(seconds: 30),
        ),
      );
    }

    final nombre = DescargaService.nombreConTimestamp(
        widget.recuerdo.titulo, 'jpg');
    final resultado =
        await DescargaService.descargar(url, nombre, 'image/jpeg');

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (resultado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.dorado),
                const SizedBox(width: 12),
                Expanded(child: Text('Guardado en Descargas: $resultado')),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo descargar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final r = widget.recuerdo;
    final puedeDescargar = _usuario?.puedeDescargar ?? false;
    final nota = _usuario?.notaRecuerdo(r.id) ?? '';
    final onSurface = Theme.of(context).colorScheme.onSurface;

    int itemCount = 0;
    itemCount++;
    itemCount++;
    if (r.descripcion.isNotEmpty) itemCount += 2;
    if (r.tieneVideos) itemCount += 2;
    if (r.tieneFotos) itemCount += 2;
    if (nota.isNotEmpty) itemCount += 2;
    itemCount++;

    return Scaffold(
      appBar: AppBar(
        title: Text(r.titulo),
        actions: [
          IconButton(
            icon: Icon(
              nota.isEmpty ? Icons.sticky_note_2_outlined : Icons.sticky_note_2,
              color: nota.isEmpty ? null : AppColors.dorado,
            ),
            tooltip: 'Mi nota',
            onPressed: _editarNota,
          ),
        ],
      ),
      body: WatermarkOverlay(
        opacity: 0.04,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            int currentIndex = 0;

            if (index == currentIndex++) {
              return _heroTitulo(r, onSurface);
            }

            if (index == currentIndex++) {
              return const SizedBox(height: 20);
            }

            if (r.descripcion.isNotEmpty) {
              if (index == currentIndex++) {
                return _seccionCard(
                  context,
                  icono: Icons.notes,
                  titulo: 'Descripción',
                  child: Text(
                    r.descripcion,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: onSurface,
                    ),
                  ),
                );
              }
              if (index == currentIndex++) {
                return const SizedBox(height: 16);
              }
            }

            if (r.tieneVideos) {
              if (index == currentIndex++) {
                return _seccionCard(
                  context,
                  icono: Icons.video_library,
                  titulo: 'VIDEOS (${r.videos.length})',
                  child: Column(
                    children: [
                      for (int i = 0; i < r.videos.length; i++) ...[
                        _videoCard(r.videos[i], i),
                        if (i < r.videos.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
                );
              }
              if (index == currentIndex++) {
                return const SizedBox(height: 16);
              }
            }

            if (r.tieneFotos) {
              if (index == currentIndex++) {
                return _seccionCard(
                  context,
                  icono: Icons.photo_library,
                  titulo: 'FOTOS (${r.fotos.length})',
                  child: SizedBox(
                    height: 320.0 * r.fotos.length + 12.0 * (r.fotos.length - 1),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: r.fotos.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: i < r.fotos.length - 1 ? 12 : 0),
                          child: _fotoCard(
                              r.fotos[i], i, puedeDescargar),
                        );
                      },
                    ),
                  ),
                );
              }
              if (index == currentIndex++) {
                return const SizedBox(height: 16);
              }
            }

            if (nota.isNotEmpty) {
              if (index == currentIndex++) {
                return _notaPersonalCard(context, nota, onSurface);
              }
              if (index == currentIndex++) {
                return const SizedBox(height: 16);
              }
            }

            if (index == currentIndex++) {
              return const SizedBox(height: 16);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _heroTitulo(Recuerdo r, Color onSurface) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.granate.withOpacity(0.08),
            AppColors.dorado.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.titulo,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: 14, color: onSurface.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                r.creadorNombre,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          if (r.fecha != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  '${r.fecha!.day}/${r.fecha!.month}/${r.fecha!.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  Widget _seccionCard(BuildContext context,
      {required IconData icono,
      required String titulo,
      required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: AppColors.granate, size: 14),
              ),
              const SizedBox(width: 10),
              Text(titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.granate,
                      fontSize: 13,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _videoCard(String url, int index) {
    final esActual = _videoActual == index && _videoController != null;
    final inicializado =
        esActual && _videoController!.value.isInitialized;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: inicializado
                ? _videoController!.value.aspectRatio
                : 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (inicializado)
                  VideoPlayer(_videoController!)
                else
                  Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam,
                              size: 48, color: AppColors.dorado),
                          const SizedBox(height: 8),
                          Text(
                            'Video ${index + 1}',
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

                if (_videoCargando && _videoActual == index)
                  const CircularProgressIndicator(color: AppColors.dorado),

                if (_errorVideo != null && _videoActual == index)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        _errorVideo!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                if (!inicializado &&
                    !_videoCargando &&
                    (_videoActual != index || _errorVideo != null))
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _inicializarVideo(index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.granate,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: AppColors.dorado, size: 32),
                      ),
                    ),
                  ),

                if (inicializado && !_videoCargando)
                  Positioned(
                    bottom: 12,
                    child: IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: AppColors.dorado,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _videoController!.value.isPlaying
                              ? _videoController!.pause()
                              : _videoController!.play();
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
  Widget _fotoCard(String url, int index, bool puedeDescargar) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GestureDetector(
            onTap: () => _verFoto(url, index),
            child: CachedNetworkImage(
              imageUrl: url,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              memCacheHeight: 600,
              placeholder: (_, __) => Container(
                height: 300,
                color: AppColors.granate.withOpacity(0.1),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.granate),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 300,
                color: AppColors.granate.withOpacity(0.1),
                child: const Icon(Icons.broken_image,
                    color: AppColors.granate, size: 48),
              ),
            ),
          ),
        ),
        if (puedeDescargar)
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _descargarFoto(url),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.download,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _notaPersonalCard(
      BuildContext context, String nota, Color onSurface) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.dorado.withOpacity(0.1),
            AppColors.dorado.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.dorado.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sticky_note_2,
                color: AppColors.granate, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mi nota personal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nota,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: onSurface,
                    height: 1.5,
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