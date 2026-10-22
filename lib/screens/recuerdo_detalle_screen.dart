// lib/screens/recuerdo_detalle_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/recuerdo.dart';
import '../models/usuario.dart';
import '../services/recuerdo_cache_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/recuerdo/galeria_fotos.dart';
import '../widgets/recuerdo/video_player_card.dart';
import '../widgets/recuerdos/recuerdo_header.dart';

class RecuerdoDetalleScreen extends StatefulWidget {
  final Recuerdo recuerdo;
  const RecuerdoDetalleScreen({super.key, required this.recuerdo});

  @override
  State<RecuerdoDetalleScreen> createState() => _RecuerdoDetalleScreenState();
}

class _RecuerdoDetalleScreenState extends State<RecuerdoDetalleScreen> {
  Usuario? _usuario;
  bool _descargando = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  Future<void> _descargar() async {
    final r = widget.recuerdo;
    if (r.totalMedia == 0) return;
    setState(() => _descargando = true);
    try {
      await RecuerdoCacheService().descargarRecuerdoCompleto(
        r.id, fotos: r.fotos, videos: r.videos,
        onProgreso: (_, __) {},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recuerdo descargado para offline')),
        );
      }
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  Future<void> _editarNota() async {
    final ctrl = TextEditingController(
        text: _usuario?.notaRecuerdo(widget.recuerdo.id) ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mi nota personal'),
        content: TextField(controller: ctrl, maxLines: 4),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      await UsuarioService().guardarNotaRecuerdo(
          widget.recuerdo.id, ctrl.text);
      _cargarUsuario();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recuerdo;
    final nota = _usuario?.notaRecuerdo(r.id) ?? '';

    return AppScaffold(
      title: 'Recuerdo',
      actions: [
        if (r.totalMedia > 0)
          IconButton(
            icon: _descargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_for_offline_outlined),
            onPressed: _descargando ? null : _descargar,
            tooltip: 'Descargar todo',
          ),
      ],
      body: ListView(
        padding: const EdgeInsets.only(bottom: Sp.xxxl),
        children: [
          RecuerdoHeader(recuerdo: r),
          if (r.tieneVideos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
              child: Column(
                children: [
                  for (int i = 0; i < r.videos.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Sp.md),
                      child: VideoPlayerCard(
                          recuerdoId: r.id, url: r.videos[i], index: i),
                    ),
                ],
              ),
            ),
          if (r.tieneFotos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
              child: AppCard(
                padding: const EdgeInsets.all(Sp.md),
                child: GaleriaFotos(
                  recuerdoId: r.id,
                  fotos: r.fotos,
                  tituloRecuerdo: r.titulo,
                  puedeDescargar: _usuario?.puedeDescargar ?? false,
                  heroPrefix: r.id,
                ),
              ),
            ),
          const SizedBox(height: Sp.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
            child: AppCard(
              padding: const EdgeInsets.all(Sp.lg),
              onTap: _editarNota,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SeccionHeader(
                      title: 'Mi nota personal',
                      icon: Icons.sticky_note_2,
                      padding: EdgeInsets.zero),
                  const SizedBox(height: Sp.sm),
                  Text(
                    nota.isEmpty
                        ? 'Toca aquí para escribir una nota (solo la ves tú)'
                        : nota,
                    style: AppType.body.copyWith(
                      color: nota.isEmpty
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5)
                          : Theme.of(context).colorScheme.onSurface,
                      fontStyle:
                          nota.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}