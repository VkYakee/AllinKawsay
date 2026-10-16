import 'dart:async';
import 'package:flutter/material.dart';
import '../services/descarga_progreso_service.dart';
import '../theme/colors.dart';

/// Barra flotante de descarga. NO bloquea la app.
/// Se muestra en la parte inferior de la pantalla y desaparece sola
/// cuando termina.
class DialogoDescarga {
  /// Inicia una descarga con progreso y devuelve el nombre del archivo
  /// guardado (o null si falló). La UI no se bloquea.
  static Future<String?> mostrar(
    BuildContext context, {
    required String url,
    required String nombre,
    required String mime,
    String titulo = 'Descargando...',
  }) async {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      // Fallback: sin overlay, descarga directa sin UI
      return DescargaProgresoService.descargar(url, nombre, mime);
    }

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
  final String url;
  final String nombre;
  final String mime;
  final String titulo;
  final void Function(String?) onFinish;

  const _BarraFlotanteDescarga({
    required this.url,
    required this.nombre,
    required this.mime,
    required this.titulo,
    required this.onFinish,
  });

  @override
  State<_BarraFlotanteDescarga> createState() =>
      _BarraFlotanteDescargaState();
}

class _BarraFlotanteDescargaState extends State<_BarraFlotanteDescarga> {
  double _progreso = 0;
  int _recibidos = 0;
  int _totales = 0;
  bool _terminado = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final resultado = await DescargaProgresoService.descargar(
      widget.url,
      widget.nombre,
      widget.mime,
      onProgreso: (p, r, t) {
        if (!mounted) return;
        setState(() {
          _progreso = p;
          _recibidos = r;
          _totales = t;
        });
      },
    );

    if (!mounted) return;

    if (resultado == null) {
      setState(() {
        _error = true;
        _terminado = true;
      });
    } else {
      setState(() {
        _terminado = true;
        _progreso = 1.0;
      });
    }

    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) widget.onFinish(resultado);
  }

  @override
  Widget build(BuildContext context) {
    final icono = _error
        ? Icons.error_outline
        : _terminado
            ? Icons.check_circle
            : Icons.download;

    final titulo = _error
        ? 'Error al descargar'
        : _terminado
            ? '¡Descarga completa!'
            : widget.titulo;

    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: _error
                  ? LinearGradient(colors: [
                      Colors.red.shade900,
                      Colors.red.shade700,
                    ])
                  : const LinearGradient(
                      colors: [AppColors.negro, Color(0xFF2A2A2A)],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _error
                    ? Colors.red.shade400.withOpacity(0.6)
                    : AppColors.dorado.withOpacity(0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.dorado.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono,
                      color: AppColors.dorado, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: AppColors.dorado,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.nombre,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!_error && !_terminado) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progreso > 0 ? _progreso : null,
                            minHeight: 4,
                            backgroundColor:
                                Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.dorado),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!_error && !_terminado && _totales > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      '${(_progreso * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.dorado,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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