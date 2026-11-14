// lib/widgets/dialogo_descarga_apk.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/components/allin_button.dart';
import '../core/components/allin_dialog.dart';
import '../core/components/allin_download_bar.dart';
import '../core/design/colors.dart';
import '../core/design/tokens.dart';
import '../core/design/typography.dart';

class DialogoDescargaApk extends StatefulWidget {
  final String url;
  final String versionLegible;

  const DialogoDescargaApk({
    super.key,
    required this.url,
    required this.versionLegible,
  });

  static Future<bool?> mostrar(
    BuildContext context, {
    required String url,
    required String versionLegible,
  }) {
    return AllinDialog.show<bool>(
      context,
      child: DialogoDescargaApk(
        url: url,
        versionLegible: versionLegible,
      ),
    );
  }

  @override
  State<DialogoDescargaApk> createState() => _DialogoDescargaApkState();
}

class _DialogoDescargaApkState extends State<DialogoDescargaApk> {
  static const _channel = MethodChannel('com.allinkawsay.app/apk_installer');

  double _progreso = 0;
  String _estado = 'descargando';
  String _msg = 'Iniciando descarga...';
  File? _apkFile;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    try {
      final dir = await getExternalStorageDirectory() ?? await getTemporaryDirectory();
      final file = File('${dir.path}/allin_kawsay_v${widget.versionLegible}.apk');
      if (await file.exists()) await file.delete();

      final request = http.Request('GET', Uri.parse(widget.url));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('Servidor respondió con código ${response.statusCode}');
      }

      final total = response.contentLength ?? 0;
      int bytes = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        bytes += chunk.length;
        if (total > 0 && mounted) {
          setState(() {
            _progreso = bytes / total;
            final mb = (bytes / 1048576).toStringAsFixed(1);
            final totalMb = (total / 1048576).toStringAsFixed(1);
            _msg = '$mb MB de $totalMb MB';
          });
        }
      }
      await sink.flush();
      await sink.close();
      if (mounted) {
        _apkFile = file;
        setState(() => _estado = 'permiso');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _estado = 'error';
          _msg = 'Error al descargar: $e';
        });
      }
    }
  }

  Future<void> _instalar() async {
    try {
      if (!await Permission.requestInstallPackages.request().isGranted) {
        throw Exception('Permiso de instalación no otorgado');
      }
      if (mounted) setState(() => _estado = 'instalando');
      await _channel.invokeMethod('instalarApk', {'path': _apkFile!.path});
      if (mounted) setState(() => _estado = 'listo');
    } catch (e) {
      if (mounted) {
        setState(() {
          _estado = 'error';
          _msg = 'No se pudo instalar la APK: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Sp.xl),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: AppColors.fondoOLED.withOpacity(0.95),
          borderRadius: Rad.rXl,
          border: Border.all(
            color: AppColors.oroSolar.withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(Sp.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_estado == 'descargando') ...[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.granateSagrado.withOpacity(0.3),
                      border: Border.all(color: AppColors.oroSolar.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.download_rounded, color: AppColors.oroSolar, size: 26),
                  ),
                  const SizedBox(height: Sp.md),
                  Text(
                    'Descargando v${widget.versionLegible}',
                    style: AppText.h3.copyWith(color: AppColors.oroSolar, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: Sp.md),
                  AllinDownloadBar(progress: _progreso, subtitle: _msg),
                ] else if (_estado == 'permiso') ...[
                  const Icon(Icons.security_rounded, color: AppColors.oroSolar, size: 48),
                  const SizedBox(height: Sp.md),
                  Text(
                    'Permiso de Instalación',
                    style: AppText.h3.copyWith(color: AppColors.oroSolar, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: Sp.xs),
                  Text(
                    'Android te pedirá permitir la instalación de esta actualización oficial. Es 100% seguro.',
                    style: AppText.bodySm.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Sp.xl),
                  AllinButton(text: 'INSTALAR ACTUALIZACIÓN', onPressed: _instalar),
                ] else if (_estado == 'listo') ...[
                  const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 48),
                  const SizedBox(height: Sp.md),
                  Text('¡Actualización Lista!', style: AppText.h3.copyWith(color: Colors.greenAccent)),
                  const SizedBox(height: Sp.xl),
                  AllinButton(text: 'CERRAR', variant: AllinButtonVariant.glass, onPressed: () => Navigator.pop(context, true)),
                ] else ...[
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: Sp.md),
                  Text(_msg, style: AppText.bodySm.copyWith(color: Colors.redAccent), textAlign: TextAlign.center),
                  const SizedBox(height: Sp.xl),
                  AllinButton(text: 'CERRAR', variant: AllinButtonVariant.glass, onPressed: () => Navigator.pop(context, false)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
