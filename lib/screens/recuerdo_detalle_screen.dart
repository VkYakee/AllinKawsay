import 'package:flutter/material.dart';
import '../models/recuerdo.dart';
import '../models/usuario.dart';
import '../services/recuerdo_cache_service.dart';
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
  bool _descargando = false;
  int _progresoDescarga = 0;
  int _totalDescarga = 0;

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

  /// Descarga todo el recuerdo al cache interno.
  Future<void> _descargarRecuerdoCompleto() async {
    final r = widget.recuerdo;
    final total = r.fotos.length + r.videos.length;
    if (total == 0) return;

    setState(() {
      _descargando = true;
      _progresoDescarga = 0;
      _totalDescarga = total;
    });

    try {
      await RecuerdoCacheService().descargarRecuerdoCompleto(
        r.id,
        fotos: r.fotos,
        videos: r.videos,
        onProgreso: (c, t) {
          if (!mounted) return;
          setState(() {
            _progresoDescarga = c;
            _totalDescarga = t;
          });
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Recuerdo descargado!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  /// Borra el recuerdo del cache local.
  Future<void> _borrarCacheRecuerdo() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Borrar caché del recuerdo',
            style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        content: const Text(
            'Se borrarán todas las fotos y videos cacheados de este recuerdo. Se descargarán de nuevo la próxima vez que los veas.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await RecuerdoCacheService().borrarRecuerdo(
      widget.recuerdo.id,
      widget.recuerdo.fotos.length,
      widget.recuerdo.videos.length,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caché del recuerdo borrado')),
    );
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
          if (r.totalMedia > 0)
            IconButton(
              icon: _descargando
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.dorado,
                        strokeWidth: 2.5,
                        value: _totalDescarga > 0
                            ? _progresoDescarga / _totalDescarga
                            : null,
                      ),
                    )
                  : const Icon(Icons.download_for_offline_outlined),
              tooltip: 'Descargar recuerdo completo',
              onPressed: _descargando ? null : _descargarRecuerdoCompleto,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            onSelected: (v) {
              if (v == 'borrar_cache') _borrarCacheRecuerdo();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'borrar_cache',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services_outlined,
                        size: 20, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Borrar caché de este recuerdo'),
                  ],
                ),
              ),
            ],
          ),
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

            if (_descargando) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dorado.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.dorado.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.granate, strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Descargando $_progresoDescarga de $_totalDescarga...',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.granate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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
                      VideoPlayerCard(
                        recuerdoId: r.id,
                        url: r.videos[i],
                        index: i,
                      ),
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
                  recuerdoId: r.id,
                  fotos: r.fotos,
                  tituloRecuerdo: r.titulo,
                  puedeDescargar: puedeDescargar,
                  heroPrefix: r.id,
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