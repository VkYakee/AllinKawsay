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
  int _videoActual = 0;

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
    _videoController?.dispose();
    super.dispose();
  }

  void _inicializarVideo(int index) {
    _videoController?.dispose();
    if (index < widget.recuerdo.videos.length) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.recuerdo.videos[index]),
      )..initialize().then((_) {
          setState(() {
            _videoActual = index;
          });
          _videoController!.play();
        });
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
          titulo: '${widget.recuerdo.titulo} (${index + 1}/${widget.recuerdo.fotos.length})',
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
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.dorado,
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 12),
              Text('Descargando...'),
            ],
          ),
          duration: Duration(seconds: 30),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _heroTitulo(r, onSurface),
            const SizedBox(height: 20),

            // Descripción
            if (r.descripcion.isNotEmpty) ...[
              _seccionCard(
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
              ),
              const SizedBox(height: 16),
            ],

            // Videos
            if (r.tieneVideos) ...[
              _seccionCard(
                context,
                icono: Icons.video_library,
                titulo: 'VIDEOS (${r.videos.length})',
                child: Column(
                  children: [
                    for (int i = 0; i < r.videos.length; i++) ...[
                      _videoCard(r.videos[i], i),
                      if (i < r.videos.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Fotos (galería grande)
            if (r.tieneFotos) ...[
              _seccionCard(
                context,
                icono: Icons.photo_library,
                titulo: 'FOTOS (${r.fotos.length})',
                child: Column(
                  children: [
                    for (int i = 0; i < r.fotos.length; i++) ...[
                      _fotoCard(r.fotos[i], i, puedeDescargar),
                      if (i < r.fotos.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Nota personal
            if (nota.isNotEmpty) ...[
              _notaPersonalCard(context, nota, onSurface),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),
          ],
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
      {required IconData icono, required String titulo, required Widget child}) {
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          esActual && _videoController!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
              : AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
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
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _inicializarVideo(index),
                            child: Center(
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
                        ),
                      ),
                    ],
                  ),
                ),
          if (esActual)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
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
                decoration: BoxDecoration(
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
            child:
                const Icon(Icons.sticky_note_2, color: AppColors.granate, size: 14),
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