// lib/widgets/cancion_form/cancion_form_media.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class CancionFormMedia extends StatelessWidget {
  final String? imagenUrl;
  final String? audioUrl;
  final String? audioNombre;
  final bool subiendoImagen;
  final bool subiendoAudio;
  final VoidCallback onSubirImagen;
  final VoidCallback onSubirAudio;
  final VoidCallback onLimpiarImagen;
  final VoidCallback onLimpiarAudio;
  final TextEditingController videoCtrl;

  const CancionFormMedia({
    super.key,
    this.imagenUrl,
    this.audioUrl,
    this.audioNombre,
    required this.subiendoImagen,
    required this.subiendoAudio,
    required this.onSubirImagen,
    required this.onSubirAudio,
    required this.onLimpiarImagen,
    required this.onLimpiarAudio,
    required this.videoCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return AppCard(
      padding: const EdgeInsets.all(Sp.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SeccionHeader(
              title: 'Multimedia',
              icon: Icons.perm_media_outlined,
              padding: EdgeInsets.zero),
          const SizedBox(height: Sp.md),
          
          // AUDIO
          if (audioUrl != null)
            Container(
              padding: const EdgeInsets.all(Sp.md),
              decoration: BoxDecoration(
                color: AppColors.dorado.withOpacity(0.1),
                borderRadius: Rad.rMd,
                border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.audiotrack, color: AppColors.granate),
                  const SizedBox(width: Sp.sm),
                  Expanded(child: Text(audioNombre ?? 'Audio cargado', style: AppType.caption, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: onLimpiarAudio),
                ],
              ),
            )
          else
            AppButton(
              label: 'SUBIR AUDIO (MP3)',
              icon: Icons.upload_file,
              variant: AppButtonVariant.secondary,
              loading: subiendoAudio,
              onPressed: onSubirAudio,
            ),
          const SizedBox(height: Sp.md),

          // IMAGEN
          if (imagenUrl != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: Rad.rMd,
                  child: Image.network(imagenUrl!, height: 160, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18), onPressed: onLimpiarImagen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Sp.md),
          ],
          AppButton(
            label: imagenUrl != null ? 'CAMBIAR IMAGEN' : 'AÑADIR IMAGEN (Opcional)',
            icon: Icons.image_outlined,
            variant: AppButtonVariant.secondary,
            loading: subiendoImagen,
            onPressed: onSubirImagen,
          ),
          const SizedBox(height: Sp.lg),

          // VIDEO
          AppInput(
            controller: videoCtrl,
            label: 'Video de YouTube (opcional)',
            hint: 'https://youtube.com/watch?v=...',
            prefixIcon: Icons.play_circle_outline,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}