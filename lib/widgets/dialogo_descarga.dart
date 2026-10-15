import 'package:flutter/material.dart';
import '../services/descarga_progreso_service.dart';
import '../theme/colors.dart';

/// Diálogo modal que muestra una barra de progreso mientras descarga.
///
/// Uso:
/// ```dart
/// final ok = await DialogoDescarga.mostrar(
///   context,
///   url: 'https://...',
///   nombre: 'archivo.mp3',
///   mime: 'audio/mpeg',
///   titulo: 'Descargando audio',
/// );
/// if (ok != null) { /* éxito */ }
/// ```
class DialogoDescarga {
  /// Descarga con progreso y devuelve el nombre del archivo guardado
  /// (o null si falló). Muestra un diálogo mientras dura.
  static Future<String?> mostrar(
    BuildContext context, {
    required String url,
    required String nombre,
    required String mime,
    String titulo = 'Descargando...',
  }) async {
    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoDescarga(
        url: url,
        nombre: nombre,
        mime: mime,
        titulo: titulo,
      ),
    );
  }
}

class _DialogoDescarga extends StatefulWidget {
  final String url;
  final String nombre;
  final String mime;
  final String titulo;

  const _DialogoDescarga({
    required this.url,
    required this.nombre,
    required this.mime,
    required this.titulo,
  });

  @override
  State<_DialogoDescarga> createState() => _DialogoDescargaState();
}

class _DialogoDescargaState extends State<_DialogoDescarga> {
  double _progreso = 0;
  int _recibidos = 0;
  int _totales = 0;
  bool _error = false;
  bool _terminado = false;
  String? _nombreGuardado;

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
      // Auto-cerrar después de 3 segundos si falla
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.pop(context, null);
      return;
    }

    setState(() {
      _nombreGuardado = resultado;
      _terminado = true;
      _progreso = 1.0;
    });

    // Auto-cerrar después de 1.2s si tuvo éxito
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.pop(context, resultado);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return PopScope(
      canPop: _terminado,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono de estado
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: _error
                      ? LinearGradient(colors: [
                          Colors.red.withOpacity(0.8),
                          Colors.red.shade900,
                        ])
                      : AppColors.gradienteGranate,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _error
                      ? Icons.error_outline
                      : _terminado
                          ? Icons.check_circle
                          : Icons.download,
                  color: AppColors.dorado,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                _error
                    ? 'Error al descargar'
                    : _terminado
                        ? '¡Descarga completa!'
                        : widget.titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.seccionTitulo(context),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),

              // Nombre del archivo
              Text(
                widget.nombre,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),

              // Barra de progreso
              if (!_error) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progreso > 0 ? _progreso : null,
                    minHeight: 8,
                    backgroundColor:
                        AppColors.granate.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.granate),
                  ),
                ),
                const SizedBox(height: 10),

                // Texto de progreso
                Text(
                  _totales > 0
                      ? '${DescargaProgresoService.formatearTamano(_recibidos)}'
                          ' / ${DescargaProgresoService.formatearTamano(_totales)}'
                          '  ·  ${(_progreso * 100).toStringAsFixed(0)}%'
                      : 'Descargando...',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.seccionTitulo(context),
                    letterSpacing: 0.3,
                  ),
                ),
              ] else ...[
                Text(
                  'No se pudo descargar el archivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}