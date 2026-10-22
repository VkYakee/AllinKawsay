// lib/screens/compartir_imagen_screen.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../design/design.dart';
import '../models/cancion.dart';
import '../services/compartir_service.dart';
import '../theme/colors.dart';
import '../widgets/tarjeta_compartible.dart';

class CompartirImagenScreen extends StatefulWidget {
  final Cancion cancion;
  const CompartirImagenScreen({super.key, required this.cancion});

  @override
  State<CompartirImagenScreen> createState() => _CompartirImagenScreenState();
}

class _CompartirImagenScreenState extends State<CompartirImagenScreen> {
  final _repaintKey = GlobalKey();
  bool _compartiendo = false;

  Future<void> _compartir() async {
    setState(() => _compartiendo = true);
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('No se pudo capturar');
      
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Error al generar PNG');

      final bytes = byteData.buffer.asUint8List();
      await CompartirService.compartirImagen(bytes, 'allin_kawsay_${widget.cancion.titulo.replaceAll(" ", "_")}.png');
      
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imagen lista para compartir')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Compartir Imagen',
      actions: [
        IconButton(icon: const Icon(Icons.share), onPressed: _compartiendo ? null : _compartir),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Sp.lg),
            child: AppCard(
              color: AppColors.granate.withOpacity(0.05),
              padding: const EdgeInsets.all(Sp.md),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates, color: AppColors.granate, size: 20),
                  const SizedBox(width: Sp.sm),
                  Expanded(child: Text('Desliza para ver la vista previa. Toca el botón para compartir.', style: AppType.captionXs)),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Sp.lg),
              child: InteractiveViewer(
                minScale: 0.5, maxScale: 2.0,
                child: Center(
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: SizedBox(
                      width: 800,
                      child: Material(
                        color: AppColors.blanco,
                        child: TarjetaCompartible(cancion: widget.cancion),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(Sp.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: AppButton(
                label: _compartiendo ? 'GENERANDO...' : 'COMPARTIR IMAGEN',
                icon: Icons.share,
                fullWidth: true,
                loading: _compartiendo,
                onPressed: _compartir,
              ),
            ),
          ),
        ],
      ),
    );
  }
}