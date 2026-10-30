// lib/features/recuerdos/screens/recuerdo_detalle_screen.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/recuerdo.dart';
import '../../../models/usuario.dart';
import '../../../services/recuerdo_cache_service.dart';
import '../../../services/usuario_service.dart';
import '../../../widgets/recuerdo/galeria_fotos.dart'; // Widget viejo que funciona bien
import '../../../widgets/recuerdo/video_player_card.dart'; // Widget viejo que funciona bien

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
    final onSurface = AppColors.onSurface(context);

    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        title: Text('Recuerdo', style: AppText.h3.copyWith(color: AppColors.dorado)),
        backgroundColor: AppColors.fondoOscuro,
        iconTheme: const IconThemeData(color: AppColors.dorado),
        actions: [
          if (r.totalMedia > 0)
            IconButton(
              icon: _descargando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.dorado))
                  : const Icon(Icons.download_for_offline_outlined, color: AppColors.dorado),
              onPressed: _descargando ? null : _descargar,
              tooltip: 'Descargar todo',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Sp.xxxl),
        children: [
          // Cabecera
          Padding(
            padding: const EdgeInsets.all(Sp.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.titulo, style: AppText.h1.copyWith(color: AppColors.dorado)),
                const SizedBox(height: Sp.sm),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.dorado),
                    const SizedBox(width: 4),
                    Text(r.creadorNombre, style: AppText.caption.copyWith(color: onSurface.withOpacity(0.6))),
                    if (r.fecha != null) ...[
                      const SizedBox(width: Sp.md),
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.dorado),
                      const SizedBox(width: 4),
                      Text(
                        '${r.fecha!.day}/${r.fecha!.month}/${r.fecha!.year}',
                        style: AppText.caption.copyWith(color: onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ],
                ),
                if (r.descripcion.isNotEmpty) ...[
                  const SizedBox(height: Sp.md),
                  Text(r.descripcion, style: AppText.body.copyWith(color: onSurface.withOpacity(0.8))),
                ],
              ],
            ),
          ),

          // Videos
          if (r.tieneVideos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
              child: Column(
                children: [
                  for (int i = 0; i < r.videos.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Sp.md),
                      child: VideoPlayerCard(recuerdoId: r.id, url: r.videos[i], index: i),
                    ),
                ],
              ),
            ),

          // Fotos
          if (r.tieneFotos)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
              child: AppCard(
                glass: true,
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

          // Nota personal
          const SizedBox(height: Sp.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
            child: AppCard(
              glass: true,
              padding: const EdgeInsets.all(Sp.lg),
              onTap: _editarNota,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sticky_note_2, color: AppColors.dorado, size: 18),
                      const SizedBox(width: Sp.sm),
                      Text('MI NOTA PERSONAL', style: AppText.label.copyWith(color: AppColors.dorado)),
                    ],
                  ),
                  const SizedBox(height: Sp.sm),
                  Text(
                    nota.isEmpty ? 'Toca aquí para escribir una nota (solo la ves tú)' : nota,
                    style: AppText.body.copyWith(
                      color: nota.isEmpty ? onSurface.withOpacity(0.5) : onSurface,
                      fontStyle: nota.isEmpty ? FontStyle.italic : FontStyle.normal,
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