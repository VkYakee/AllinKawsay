// lib/features/recuerdos/widgets/galeria_fotos_elite.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../services/descarga_service.dart';
import '../../../services/recuerdo_cache_service.dart';
import '../../../widgets/dialogo_descarga.dart';
import '../screens/foto_fullscreen_screen.dart';

/// Galería élite: grid masonry de 2 columnas con aspect ratios variados,
/// Hero en cada foto, botón de descarga flotante, cache local.
class GaleriaFotosElite extends StatefulWidget {
  final String recuerdoId;
  final List<String> fotos;
  final String tituloRecuerdo;
  final bool puedeDescargar;
  final String heroPrefix;

  const GaleriaFotosElite({
    super.key,
    required this.recuerdoId,
    required this.fotos,
    required this.tituloRecuerdo,
    required this.puedeDescargar,
    this.heroPrefix = '',
  });

  @override
  State<GaleriaFotosElite> createState() => _GaleriaFotosEliteState();
}

class _GaleriaFotosEliteState extends State<GaleriaFotosElite> {
  String _tagDe(int index) => index == 0
      ? 'recuerdo_portada_${widget.heroPrefix}'
      : 'recuerdo_foto_${widget.heroPrefix}_$index';

  // Aspect ratios variados para look masonry
  static const _aspects = [3 / 4, 4 / 5, 1 / 1, 4 / 3, 5 / 4, 3 / 4];

  @override
  Widget build(BuildContext context) {
    if (widget.fotos.isEmpty) return const SizedBox.shrink();

    // Disparar cache en background para todas
    for (int i = 0; i < widget.fotos.length; i++) {
      RecuerdoCacheService().descargarEnBackground(
        widget.recuerdoId,
        'foto',
        i,
        widget.fotos[i],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoCol = (constraints.maxWidth - Sp.sm) / 2;

        // Repartir fotos en 2 columnas
        final colIzq = <int>[];
        final colDer = <int>[];
        for (int i = 0; i < widget.fotos.length; i++) {
          (i.isEven ? colIzq : colDer).add(i);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (final i in colIzq)
                    _FotoTile(
                      index: i,
                      ancho: anchoCol,
                      aspecto: _aspects[i % _aspects.length],
                      foto: widget.fotos[i],
                      heroTag: _tagDe(i),
                      puedeDescargar: widget.puedeDescargar,
                      recuerdoId: widget.recuerdoId,
                      tituloRecuerdo: widget.tituloRecuerdo,
                      totalFotos: widget.fotos.length,
                    ),
                ],
              ),
            ),
            const SizedBox(width: Sp.sm),
            Expanded(
              child: Column(
                children: [
                  for (final i in colDer)
                    _FotoTile(
                      index: i,
                      ancho: anchoCol,
                      aspecto: _aspects[(i + 3) % _aspects.length],
                      foto: widget.fotos[i],
                      heroTag: _tagDe(i),
                      puedeDescargar: widget.puedeDescargar,
                      recuerdoId: widget.recuerdoId,
                      tituloRecuerdo: widget.tituloRecuerdo,
                      totalFotos: widget.fotos.length,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FotoTile extends StatefulWidget {
  final int index;
  final double ancho;
  final double aspecto;
  final String foto;
  final String heroTag;
  final bool puedeDescargar;
  final String recuerdoId;
  final String tituloRecuerdo;
  final int totalFotos;

  const _FotoTile({
    required this.index,
    required this.ancho,
    required this.aspecto,
    required this.foto,
    required this.heroTag,
    required this.puedeDescargar,
    required this.recuerdoId,
    required this.tituloRecuerdo,
    required this.totalFotos,
  });

  @override
  State<_FotoTile> createState() => _FotoTileState();
}

class _FotoTileState extends State<_FotoTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          AppMotion.hapticSelection();
          _verFoto();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.spring,
          child: ClipRRect(
            borderRadius: Rad.rMd,
            child: AspectRatio(
              aspectRatio: widget.aspecto,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.heroTag,
                    child: Material(
                      color: Colors.transparent,
                      child: _buildImage(),
                    ),
                  ),
                  // Gradiente inferior sutil
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Botón descarga
                  if (widget.puedeDescargar)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          AppMotion.hapticSelection();
                          _descargarFoto();
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.55),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.download_rounded,
                            color: AppColors.dorado,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return FutureBuilder<String?>(
      future: RecuerdoCacheService().rutaDe(
        widget.recuerdoId,
        'foto',
        widget.index,
      ),
      builder: (context, snap) {
        final rutaLocal = snap.data;
        if (rutaLocal != null) {
          RecuerdoCacheService().marcarAcceso(
            widget.recuerdoId,
            'foto',
            widget.index,
          );
          return Image.file(
            File(rutaLocal),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildRemota(),
          );
        }
        return _buildRemota();
      },
    );
  }

  Widget _buildRemota() {
    return CachedNetworkImage(
      imageUrl: widget.foto,
      fit: BoxFit.cover,
      memCacheWidth: 600,
      memCacheHeight: 800,
      placeholder: (_, __) => Container(
        color: AppColors.granate.withOpacity(0.12),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.dorado,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.granate.withOpacity(0.12),
        child: const Icon(
          Icons.broken_image,
          color: AppColors.granate,
          size: 32,
        ),
      ),
    );
  }

  void _verFoto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotoFullscreenScreen(
          url: widget.foto,
          titulo:
              '${widget.tituloRecuerdo} (${widget.index + 1}/${widget.totalFotos})',
          puedeDescargar: widget.puedeDescargar,
          heroTag: widget.heroTag,
        ),
      ),
    );
  }

  Future<void> _descargarFoto() async {
    final nombre = DescargaService.nombreConTimestamp(
      '${widget.tituloRecuerdo}_${widget.index + 1}',
      'jpg',
    );
    final resultado = await DialogoDescarga.mostrar(
      context,
      url: widget.foto,
      nombre: nombre,
      mime: 'image/jpeg',
      titulo: 'Descargando foto',
    );

    if (!mounted) return;
    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Guardado en Descargas',
            style: AppText.body.copyWith(color: AppColors.dorado),
          ),
          backgroundColor: AppColors.granateOscuro,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
        ),
      );
    }
  }
}