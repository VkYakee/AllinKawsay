import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/descarga_service.dart';
import '../../theme/colors.dart';
import '../../screens/foto_fullscreen_screen.dart';

class GaleriaFotos extends StatelessWidget {
  final List<String> fotos;
  final String tituloRecuerdo;
  final bool puedeDescargar;

  /// Identificador único del recuerdo (usualmente `recuerdo.id`).
  /// Se usa para construir los Hero tags.
  final String heroPrefix;

  const GaleriaFotos({
    super.key,
    required this.fotos,
    required this.tituloRecuerdo,
    required this.puedeDescargar,
    this.heroPrefix = '',
  });

  String _tagDe(int index) => index == 0
      ? 'recuerdo_portada_$heroPrefix'
      : 'recuerdo_foto_${heroPrefix}_$index';

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fotos.length,
      itemBuilder: (context, i) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: i < fotos.length - 1 ? 12 : 0),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onTap: () => _verFoto(context, fotos[i], i),
                  child: _imagenConHero(fotos[i], i),
                ),
              ),
              if (puedeDescargar)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _descargarFoto(context, fotos[i]),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.download,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _imagenConHero(String url, int index) {
    final imagen = CachedNetworkImage(
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
    );

    if (heroPrefix.isEmpty) return imagen;
    return Hero(tag: _tagDe(index), child: imagen);
  }
  void _verFoto(BuildContext context, String url, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotoFullscreenScreen(
          url: url,
          titulo: '$tituloRecuerdo (${index + 1}/${fotos.length})',
          puedeDescargar: puedeDescargar,
          heroTag: heroPrefix.isEmpty ? null : _tagDe(index),
        ),
      ),
    );
  }

  Future<void> _descargarFoto(BuildContext context, String url) async {
    if (context.mounted == false) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: AppColors.dorado, strokeWidth: 2.5),
            ),
            SizedBox(width: 12),
            Text('Descargando...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    final nombre =
        DescargaService.nombreConTimestamp(tituloRecuerdo, 'jpg');
    final resultado =
        await DescargaService.descargar(url, nombre, 'image/jpeg');

    if (context.mounted == false) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.dorado),
              const SizedBox(width: 12),
              Expanded(
                  child: Text('Guardado en Descargas: $resultado')),
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