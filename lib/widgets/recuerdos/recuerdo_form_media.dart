// lib/widgets/recuerdos/recuerdo_form_media.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class RecuerdoFormMedia extends StatelessWidget {
  final List<String> urlsFotos;
  final List<String> urlsVideos;
  final List<File> fotosNuevas;
  final List<File> videosNuevos;
  final VoidCallback onAgregarFoto;
  final VoidCallback onAgregarVideo;
  final VoidCallback onImportarNube; // <-- NUEVO
  final Function(int, bool) onEliminarFoto;
  final Function(int, bool) onEliminarVideo;

  const RecuerdoFormMedia({
    super.key,
    required this.urlsFotos,
    required this.urlsVideos,
    required this.fotosNuevas,
    required this.videosNuevos,
    required this.onAgregarFoto,
    required this.onAgregarVideo,
    required this.onImportarNube, // <-- NUEVO
    required this.onEliminarFoto,
    required this.onEliminarVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón de importación desde la nube
        AppButton(
          label: 'IMPORTAR DESDE LA NUBE (DRIVE / FOTOS)',
          icon: Icons.cloud_download,
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          onPressed: onImportarNube,
        ),
        const SizedBox(height: Sp.md),

        AppCard(
          padding: const EdgeInsets.all(Sp.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SeccionHeader(title: 'Fotos', icon: Icons.photo_library, padding: EdgeInsets.zero),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.add_circle, color: AppColors.granate), onPressed: onAgregarFoto),
                ],
              ),
              const SizedBox(height: Sp.sm),
              if (urlsFotos.isEmpty && fotosNuevas.isEmpty)
                _emptyMini('Sin fotos aún')
              else
                _wrapMedia(
                  items: [
                    ...fotosNuevas.map((f) => _PreviewItem(file: f, onEliminar: () => onEliminarFoto(fotosNuevas.indexOf(f), true))),
                    ...urlsFotos.map((u) => _PreviewItem(url: u, onEliminar: () => onEliminarFoto(urlsFotos.indexOf(u), false))),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: Sp.md),
        AppCard(
          padding: const EdgeInsets.all(Sp.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SeccionHeader(title: 'Videos', icon: Icons.video_library, padding: EdgeInsets.zero),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.add_circle, color: AppColors.granate), onPressed: onAgregarVideo),
                ],
              ),
              const SizedBox(height: Sp.sm),
              if (urlsVideos.isEmpty && videosNuevos.isEmpty)
                _emptyMini('Sin videos aún')
              else
                _wrapMedia(
                  items: [
                    ...videosNuevos.map((f) => _PreviewItem(file: f, esVideo: true, onEliminar: () => onEliminarVideo(videosNuevos.indexOf(f), true))),
                    ...urlsVideos.map((u) => _PreviewItem(url: u, esVideo: true, onEliminar: () => onEliminarVideo(urlsVideos.indexOf(u), false))),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyMini(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Sp.lg),
      decoration: BoxDecoration(color: AppColors.granate.withOpacity(0.04), borderRadius: Rad.rMd, border: Border.all(color: AppColors.granate.withOpacity(0.1))),
      child: Center(child: Text(text, style: AppType.captionXs.copyWith(color: AppColors.granate.withOpacity(0.5)))),
    );
  }

  Widget _wrapMedia({required List<Widget> items}) {
    return Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: items);
  }
}

class _PreviewItem extends StatelessWidget {
  final File? file;
  final String? url;
  final bool esVideo;
  final VoidCallback onEliminar;

  const _PreviewItem({this.file, this.url, this.esVideo = false, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(borderRadius: Rad.rMd, border: Border.all(color: AppColors.dorado.withOpacity(0.5)), color: Colors.grey.withOpacity(0.1)),
          child: ClipRRect(
            borderRadius: Rad.rMd,
            child: esVideo
                ? const Icon(Icons.videocam, color: AppColors.granate, size: 32)
                : (file != null ? Image.file(file!, fit: BoxFit.cover) : Image.network(url!, fit: BoxFit.cover)),
          ),
        ),
        Positioned(
          top: -6, right: -6,
          child: GestureDetector(
            onTap: onEliminar,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}