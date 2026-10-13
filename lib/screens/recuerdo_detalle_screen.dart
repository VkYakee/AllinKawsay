import 'package:flutter/material.dart';
import '../models/recuerdo.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/comunes/seccion_card.dart';
import '../widgets/recuerdo/galeria_fotos.dart';
import '../widgets/recuerdo/hero_titulo.dart';
import '../widgets/recuerdo/video_player_card.dart';
import '../widgets/watermark_overlay.dart';

class RecuerdoDetalleScreen extends StatefulWidget {
  final Recuerdo recuerdo;
  const RecuerdoDetalleScreen({super.key, required this.recuerdo});

  @override
  State<RecuerdoDetalleScreen> createState() =>
      _RecuerdoDetalleScreenState();
}

class _RecuerdoDetalleScreenState extends State<RecuerdoDetalleScreen> {
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
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
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await UsuarioService()
          .guardarNotaRecuerdo(widget.recuerdo.id, ctrl.text);
      await _cargarUsuario();
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
            nota.isEmpty
                ? Icons.sticky_note_2_outlined
                : Icons.sticky_note_2,
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
          HeroTitulo(recuerdo: r, onSurface: onSurface),
          const SizedBox(height: 20),

          if (r.descripcion.isNotEmpty) ...[
            SeccionCard(
              icono: Icons.notes,
              titulo: 'DESCRIPCIÓN',
              child: Text(
                r.descripcion,
                style: TextStyle(
                    fontSize: 15, height: 1.6, color: onSurface),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (r.tieneVideos) ...[
            SeccionCard(
              icono: Icons.video_library,
              titulo: 'VIDEOS (${r.videos.length})',
              child: Column(
                children: [
                  for (int i = 0; i < r.videos.length; i++) ...[
                    VideoPlayerCard(url: r.videos[i], index: i),
                    if (i < r.videos.length - 1)
                      const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (r.tieneFotos) ...[
            SeccionCard(
              icono: Icons.photo_library,
              titulo: 'FOTOS (${r.fotos.length})',
              child: GaleriaFotos(
                fotos: r.fotos,
                tituloRecuerdo: r.titulo,
                puedeDescargar: puedeDescargar,
              ),
            ),
            const SizedBox(height: 16),
          ],

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