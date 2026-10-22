// lib/widgets/dialogo_descarga.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../services/descarga_progreso_service.dart';
import '../theme/colors.dart';

class DialogoDescarga {
  static Future<String?> mostrar(
    BuildContext context, {
    required String url,
    required String nombre,
    required String mime,
    String titulo = 'Descargando...',
  }) async {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return DescargaProgresoService.descargar(url, nombre, mime);

    final completer = Completer<String?>();
    late OverlayEntry entry;
    bool removido = false;

    entry = OverlayEntry(
      builder: (ctx) => _BarraFlotanteDescarga(
        url: url,
        nombre: nombre,
        mime: mime,
        titulo: titulo,
        onFinish: (resultado) {
          if (removido) return;
          removido = true;
          entry.remove();
          if (!completer.isCompleted) completer.complete(resultado);
        },
      ),
    );

    overlay.insert(entry);
    return completer.future;
  }
}

class _BarraFlotanteDescarga extends StatefulWidget {
  final String url, nombre, mime, titulo;
  final void Function(String?) onFinish;

  const _BarraFlotanteDescarga({
    required this.url,
    required this.nombre,
    required this.mime,
    required this.titulo,
    required this.onFinish,
  });

  @override
  State<_BarraFlotanteDescarga> createState() => _BarraFlotanteDescargaState();
}

class _BarraFlotanteDescargaState extends State<_BarraFlotanteDescarga> {
  double _progreso = 0;
  bool _terminado = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final resultado = await DescargaProgresoService.descargar(
      widget.url, widget.nombre, widget.mime,
      onProgreso: (p, r, t) { if (mounted) setState(() => _progreso = p); },
    );

    if (!mounted) return;
    setState(() {
      _error = resultado == null;
      _terminado = true;
      if (resultado != null) _progreso = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) widget.onFinish(resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: Sp.lg, right: Sp.lg, bottom: Sp.xxl,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: AppCard(
            padding: const EdgeInsets.all(Sp.md),
            border: Border.all(color: _error ? Colors.red.withOpacity(0.5) : AppColors.dorado.withOpacity(0.5)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Sp.sm),
                  decoration: BoxDecoration(
                    color: _error ? Colors.red.withOpacity(0.1) : AppColors.granate.withOpacity(0.1),
                    borderRadius: Rad.rMd,
                  ),
                  child: Icon(_error ? Icons.error_outline : (_terminado ? Icons.check_circle : Icons.download), color: _error ? Colors.red : AppColors.granate, size: 20),
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_error ? 'Error al descargar' : (_terminado ? '¡Completado!' : widget.titulo), style: AppType.subtitle.copyWith(color: _error ? Colors.red : AppColors.granate)),
                      Text(widget.nombre, style: AppType.captionXs.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (!_error && !_terminado) ...[
                        const SizedBox(height: Sp.sm),
                        ClipRRect(
                          borderRadius: Rad.rPill,
                          child: LinearProgressIndicator(value: _progreso > 0 ? _progreso : null, minHeight: 4, backgroundColor: AppColors.granate.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation(AppColors.granate)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}