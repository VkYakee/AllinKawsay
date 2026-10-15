import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/descarga_service.dart';
import '../../theme/colors.dart';
import '../../screens/foto_fullscreen_screen.dart';
import '../dialogo_descarga.dart';

class GaleriaFotos extends StatelessWidget {
  final List<String> fotos;
  final String tituloRecuerdo;
  final bool puedeDescargar;
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
                    onTap: () => _descargarFoto(context, fotos[i], i),
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

  Future<void> _descargarFoto(
      BuildContext context, String url, int index) async {
    final nombre = DescargaService.nombreConTimestamp(
      '${tituloRecuerdo}_${index + 1}',
      'jpg',
    );
    final resultado = await DialogoDescarga.mostrar(
      context,
      url: url,
      nombre: nombre,
      mime: 'image/jpeg',
      titulo: 'Descargando foto',
    );

    if (!context.mounted) return;
    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.dorado),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Guardado en Descargas: $resultado'),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}