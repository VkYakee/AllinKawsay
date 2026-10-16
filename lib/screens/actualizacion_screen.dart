import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/info_version.dart';
import '../theme/colors.dart';

class ActualizacionScreen extends StatefulWidget {
  final InfoVersion info;
  const ActualizacionScreen({super.key, required this.info});

  @override
  State<ActualizacionScreen> createState() => _ActualizacionScreenState();
}

enum _EstadoDescarga { iniciando, descargando, listo, error }

class _ActualizacionScreenState extends State<ActualizacionScreen> {
  static const _channel = MethodChannel('com.allinkawsay/native');

  _EstadoDescarga _estado = _EstadoDescarga.iniciando;
  double _progreso = 0;
  String _mensaje = 'Preparando descarga...';
  String? _error;
  File? _apkFile;

  @override
  void initState() {
    super.initState();
    _iniciarDescarga();
  }

  @override
  void dispose() {
    // Intentar borrar el APK temporal al salir de la pantalla
    _borrarApkTemporal();
    super.dispose();
  }

  Future<void> _borrarApkTemporal() async {
    try {
      if (_apkFile != null && await _apkFile!.exists()) {
        await _apkFile!.delete();
      }
    } catch (_) {}
  }

  Future<void> _iniciarDescarga() async {
    setState(() {
      _estado = _EstadoDescarga.descargando;
      _progreso = 0;
      _mensaje = 'Conectando con el servidor...';
      _error = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/allin_kawsay_update.apk';
      final archivo = File(path);

      if (await archivo.exists()) {
        await archivo.delete();
      }

      final request = http.Request('GET', Uri.parse(widget.info.url));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

      final total = response.contentLength ?? 0;
      int recibido = 0;

      final sink = archivo.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        recibido += chunk.length;
        if (total > 0 && mounted) {
          setState(() {
            _progreso = recibido / total;
            final mb = (recibido / 1048576).toStringAsFixed(1);
            final totalMb = (total / 1048576).toStringAsFixed(1);
            _mensaje = '$mb MB / $totalMb MB';
          });
        }
      }
      await sink.flush();
      await sink.close();

      if (!mounted) return;
      setState(() {
        _apkFile = archivo;
        _estado = _EstadoDescarga.listo;
        _progreso = 1.0;
        _mensaje = '¡Descarga completa!';
      });

      await Future.delayed(const Duration(milliseconds: 400));
      await _instalar();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estado = _EstadoDescarga.error;
        _error = 'No se pudo descargar la actualización.\n\n$e';
      });
    }
  }

  /// Pide el permiso de "instalar apps de origen desconocido".
  /// En Android 8+ el sistema muestra una pantalla de ajustes.
  Future<bool> _pedirPermisoInstalacion() async {
    try {
      var status = await Permission.requestInstallPackages.status;
      if (status.isGranted) return true;
      status = await Permission.requestInstallPackages.request();
      return status.isGranted;
    } catch (_) {
      // Si el plugin no soporta el permiso, intentamos instalar igual
      // (el manifest ya tiene REQUEST_INSTALL_PACKAGES).
      return true;
    }
  }

  Future<void> _instalar() async {
    if (_apkFile == null) return;

    // Pedir permiso de origen desconocido
    final ok = await _pedirPermisoInstalacion();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _estado = _EstadoDescarga.error;
        _error = 'Necesitás habilitar el permiso "Instalar apps '
            'desconocidas" para Allin Kawsay.\n\n'
            'Andá a Ajustes → Seguridad → Instalar apps desconocidas → '
            'Elegí Allin Kawsay → Permitir. Después volvé y reintentá.';
      });
      return;
    }

    try {
      await _channel.invokeMethod('instalarApk', {
        'path': _apkFile!.path,
      });

      // Programar borrado del APK a los 30 segundos.
      // (Cuando el instalador termine, ya no lo necesitamos.)
      Future.delayed(const Duration(seconds: 30), () {
        _borrarApkTemporal();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estado = _EstadoDescarga.error;
        _error = 'No se pudo abrir el instalador.\n\n'
            'Es posible que necesites habilitar "Instalar apps '
            'desconocidas" para Allin Kawsay en los ajustes de Android.\n\n$e';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return PopScope(
      canPop: _estado != _EstadoDescarga.descargando,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ACTUALIZACIÓN'),
          automaticallyImplyLeading:
              _estado != _EstadoDescarga.descargando,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: _estado == _EstadoDescarga.error
                        ? LinearGradient(colors: [
                            Colors.red.withOpacity(0.8),
                            Colors.red.shade900,
                          ])
                        : AppColors.gradienteGranate,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_estado == _EstadoDescarga.error
                                ? Colors.red
                                : AppColors.granate)
                            .withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _estado == _EstadoDescarga.error
                        ? Icons.error_outline
                        : _estado == _EstadoDescarga.listo
                            ? Icons.check_circle_outline
                            : Icons.system_update_alt,
                    color: AppColors.dorado,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                _estado == _EstadoDescarga.error
                    ? 'Error'
                    : _estado == _EstadoDescarga.listo
                        ? '¡Listo!'
                        : 'Descargando',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.seccionTitulo(context),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                _estado == _EstadoDescarga.error
                    ? _error ?? 'Error desconocido'
                    : _mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              if (_estado == _EstadoDescarga.descargando) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progreso > 0 ? _progreso : null,
                    minHeight: 8,
                    backgroundColor:
                        AppColors.granate.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.granate),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_progreso * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.seccionTitulo(context),
                    letterSpacing: 2,
                  ),
                ),
              ],

              if (_estado == _EstadoDescarga.listo) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dorado.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.dorado.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: AppColors.granate),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Se abrirá el instalador de Android. '
                          'Segui las instrucciones para completar la '
                          'instalación.',
                          style: TextStyle(
                            fontSize: 12,
                            color: onSurface.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              if (_estado == _EstadoDescarga.error)
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _estado = _EstadoDescarga.iniciando;
                      });
                      _iniciarDescarga();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'REINTENTAR',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

              if (_estado == _EstadoDescarga.listo)
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text(
                      'CERRAR',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}