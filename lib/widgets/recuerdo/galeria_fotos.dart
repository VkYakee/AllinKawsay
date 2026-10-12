import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../screens/foto_fullscreen_screen.dart';

class GaleriaFotos extends StatelessWidget {
  final List<String> fotos;
  final String tituloRecuerdo;
  final bool puedeDescargar;

  const GaleriaFotos({
    super.key,
    required this.fotos,
    required this.tituloRecuerdo,
    required this.puedeDescargar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // CLAVE: Arregla el bug de memoria
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fotos.length,
      itemBuilder: (context, i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < fotos.length - 1 ? 12 : 0),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onTap: () => _verFoto(context, fotos[i], i),
                  child: CachedNetworkImage(
                    imageUrl: fotos[i],
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    memCacheWidth: 800,
                    memCacheHeight: 600,
                    placeholder: (_, __) => Container(
                      height: 300,
                      color: AppColors.granate.withOpacity(0.1),
                      child: const Center(child: CircularProgressIndicator(color: AppColors.granate)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 300,
                      color: AppColors.granate.withOpacity(0.1),
                      child: const Icon(Icons.broken_image, color: AppColors.granate, size: 48),
                    ),
                  ),
                ),
              ),
              // TODO: Aquí integraremos el botón de descarga más adelante
            ],
          ),
        );
      },
    );
  }

  void _verFoto(BuildContext context, String url, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotoFullscreenScreen(
          url: url,
          titulo: '$tituloRecuerdo (${index + 1}/${fotos.length})',
          puedeDescargar: puedeDescargar,
        ),
      ),
    );
  }
}