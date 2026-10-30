// lib/features/update/screens/actualizacion_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../design/design.dart';
import '../../../models/info_version.dart';
import '../../../theme/colors.dart';

class ActualizacionScreen extends StatefulWidget {
  final InfoVersion info;
  const ActualizacionScreen({super.key, required this.info});

  @override
  State<ActualizacionScreen> createState() => _ActualizacionScreenState();
}

enum _Estado { iniciando, descargando, listo, error }

class _ActualizacionScreenState extends State<ActualizacionScreen> {
  static const _channel = MethodChannel('com.allinkawsay/native');
  _Estado _estado = _Estado.iniciando;
  double _progreso = 0;
  String _mensaje = 'Preparando descarga...';
  String? _error;
  File? _apkFile;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    _borrar();
    super.dispose();
  }

  Future<void> _borrar() async {
    try {
      if (_apkFile != null && await _apkFile!.exists()) {
        await _apkFile!.delete();
      }
    } catch (_) {}
  }

  Future<void> _iniciar() async {
    setState(() {
      _estado = _Estado.descargando;
      _progreso = 0;
      _mensaje = 'Conectando...';
      _error = null;
    });
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/update.apk');
      if (await file.exists()) await file.delete();

      final request = http.Request('GET', Uri.parse(widget.info.url));
      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}');
      }

      final total = response.contentLength ?? 0;
      int recibido = 0;
      final sink = file.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        recibido += chunk.length;
        if (total > 0 && mounted) {
          setState(() {
            _progreso = recibido / total;
            _mensaje =
                '${(recibido / 1048576).toStringAsFixed(1)} / ${(total / 1048576).toStringAsFixed(1)} MB';
          });
        }
      }
      await sink.flush();
      await sink.close();

      if (!mounted) return;
      setState(() {
        _apkFile = file;
        _estado = _Estado.listo;
        _mensaje = '¡Descarga completa!';
      });
      await Future.delayed(const Duration(milliseconds: 400));
      await _instalar();
    } catch (e) {
      if (mounted) {
        setState(() {
          _estado = _Estado.error;
          _error = 'Error al descargar: $e';
        });
      }
    }
  }

  Future<void> _instalar() async {
    if (_apkFile == null) return;
    final status = await Permission.requestInstallPackages.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() {
        _estado = _Estado.error;
        _error = 'Necesitas habilitar "Instalar apps desconocidas".';
      });
      return;
    }
    try {
      await _channel.invokeMethod('instalarApk', {'path': _apkFile!.path});
      Future.delayed(const Duration(seconds: 30), _borrar);
    } catch (e) {
      if (mounted) {
        setState(() {
          _estado = _Estado.error;
          _error = 'No se pudo abrir el instalador: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _estado != _Estado.descargando,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F0F0F),
                AppColors.granateOscuro,
                AppColors.granate,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Sp.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(Sp.xxl),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _estado == _Estado.error
                            ? null
                            : AppColors.gradienteGranate,
                        color: _estado == _Estado.error
                            ? Colors.red.withOpacity(0.2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: (_estado == _Estado.error
                                    ? Colors.red
                                    : AppColors.granate)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _estado == _Estado.error
                            ? Icons.error_outline
                            : (_estado == _Estado.listo
                                ? Icons.check_circle_outline
                                : Icons.system_update_alt),
                        color: AppColors.dorado,
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: Sp.xxl),
                  Text(
                    _estado == _Estado.error
                        ? 'Error'
                        : (_estado == _Estado.listo
                            ? '¡Listo!'
                            : 'Descargando'),
                    textAlign: TextAlign.center,
                    style: AppType.h2.copyWith(color: AppColors.dorado),
                  ),
                  const SizedBox(height: Sp.md),
                  Text(
                    _estado == _Estado.error ? _error! : _mensaje,
                    textAlign: TextAlign.center,
                    style: AppType.body.copyWith(
                      color: AppColors.dorado.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: Sp.xxl),
                  if (_estado == _Estado.descargando) ...[
                    ClipRRect(
                      borderRadius: Rad.rPill,
                      child: LinearProgressIndicator(
                        value: _progreso > 0 ? _progreso : null,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.dorado,
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.md),
                    Text(
                      '${(_progreso * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                      style: AppType.h3.copyWith(color: AppColors.dorado),
                    ),
                  ],
                  if (_estado == _Estado.error)
                    AppButton(
                      label: 'REINTENTAR',
                      fullWidth: true,
                      onPressed: _iniciar,
                    ),
                  if (_estado == _Estado.listo)
                    AppButton(
                      label: 'CERRAR',
                      variant: AppButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}