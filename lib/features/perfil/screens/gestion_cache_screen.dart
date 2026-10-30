// lib/features/perfil/screens/gestion_cache_screen.dart
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../services/audio_cache_service.dart';
import '../../../services/recuerdo_cache_service.dart';
import '../../../theme/colors.dart';

class GestionCacheScreen extends StatefulWidget {
  const GestionCacheScreen({super.key});

  @override
  State<GestionCacheScreen> createState() => _GestionCacheScreenState();
}

class _GestionCacheScreenState extends State<GestionCacheScreen> {
  int _audioBytes = 0, _audioCantidad = 0;
  int _recuerdoBytes = 0, _recuerdoCantidad = 0;
  bool _cargando = true, _limpiando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final aB = await AudioCacheService().espacioUsado();
    final aC = await AudioCacheService().cantidad();
    final rB = await RecuerdoCacheService().espacioUsado();
    final rC = await RecuerdoCacheService().cantidad();
    if (mounted) {
      setState(() {
        _audioBytes = aB;
        _audioCantidad = aC;
        _recuerdoBytes = rB;
        _recuerdoCantidad = rC;
        _cargando = false;
      });
    }
  }

  String _fmt(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
  }

  Future<void> _confirmar(
    String titulo,
    String mensaje,
    Future<void> Function() accion,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          titulo,
          style: AppType.h3.copyWith(color: AppColors.granate),
        ),
        content: Text(mensaje, style: AppType.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _limpiando = true);
      await accion();
      await _cargar();
      if (mounted) setState(() => _limpiando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AppScaffold(
      title: 'Almacenamiento',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.dorado),
          onPressed: _cargando ? null : _cargar,
        ),
      ],
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.granate),
            )
          : _limpiando
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.dorado),
                )
              : ListView(
                  padding: const EdgeInsets.all(Sp.lg),
                  children: [
                    AppCard(
                      color: AppColors.granate,
                      child: Column(
                        children: [
                          Text(
                            'USO TOTAL',
                            style: AppType.label.copyWith(
                              color: AppColors.dorado,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: Sp.sm),
                          Text(
                            _fmt(_audioBytes + _recuerdoBytes),
                            style: AppType.h1.copyWith(
                              color: AppColors.dorado,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(height: Sp.xs),
                          Text(
                            '${_audioCantidad + _recuerdoCantidad} archivos guardados',
                            style: AppType.caption.copyWith(
                              color: AppColors.dorado.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.lg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SeccionHeader(
                            title: 'Audios',
                            icon: Icons.music_note,
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: Sp.sm),
                          Text(
                            '${_fmt(_audioBytes)} · $_audioCantidad canciones',
                            style: AppType.subtitle.copyWith(
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: Sp.md),
                          AppButton(
                            label: 'LIMPIAR AUDIOS',
                            variant: AppButtonVariant.secondary,
                            fullWidth: true,
                            onPressed: _audioCantidad == 0
                                ? null
                                : () => _confirmar(
                                      'Limpiar audios',
                                      'Se borrarán los audios descargados. Se volverán a descargar cuando los reproduzcas.',
                                      () => AudioCacheService().limpiarTodo(),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.md),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SeccionHeader(
                            title: 'Recuerdos',
                            icon: Icons.photo_library,
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: Sp.sm),
                          Text(
                            '${_fmt(_recuerdoBytes)} · $_recuerdoCantidad archivos',
                            style: AppType.subtitle.copyWith(
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: Sp.md),
                          AppButton(
                            label: 'LIMPIAR RECUERDOS',
                            variant: AppButtonVariant.secondary,
                            fullWidth: true,
                            onPressed: _recuerdoCantidad == 0
                                ? null
                                : () => _confirmar(
                                      'Limpiar recuerdos',
                                      'Se borrarán las fotos y videos descargados.',
                                      () =>
                                          RecuerdoCacheService().limpiarTodo(),
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