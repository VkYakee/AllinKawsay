// lib/widgets/dialogo_descarga_apk.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../design/design.dart';
import '../theme/colors.dart';

class DialogoDescargaApk {
  static Future<bool> mostrar(BuildContext context, {required String url, required String nombre, required String versionLegible}) async {
    final r = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DescargaApkDialog(url: url, nombre: nombre, versionLegible: versionLegible),
    );
    return r ?? false;
  }
}

class _DescargaApkDialog extends StatefulWidget {
  final String url, nombre, versionLegible;
  const _DescargaApkDialog({required this.url, required this.nombre, required this.versionLegible});

  @override
  State<_DescargaApkDialog> createState() => _DescargaApkDialogState();
}

class _DescargaApkDialogState extends State<_DescargaApkDialog> {
  static const _channel = MethodChannel('com.allinkawsay/native');
  String _estado = 'descargando';
  double _progreso = 0;
  String _msg = 'Conectando...';
  File? _apkFile;

  @override
  void initState() {
    super.initState();
    _descargar();
  }

  Future<void> _descargar() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/update.apk');
      if (await file.exists()) await file.delete();

      final req = http.Request('GET', Uri.parse(widget.url));
      final res = await req.send();
      if (res.statusCode != 200) throw Exception('Error ${res.statusCode}');

      final total = res.contentLength ?? 0;
      int recibido = 0;
      final sink = file.openWrite();
      await for (final chunk in res.stream) {
        sink.add(chunk);
        recibido += chunk.length;
        if (total > 0 && mounted) setState(() { _progreso = recibido / total; _msg = '${(recibido / 1048576).toStringAsFixed(1)} MB'; });
      }
      await sink.flush();
      await sink.close();
      if (mounted) { _apkFile = file; setState(() => _estado = 'permiso'); }
    } catch (e) {
      if (mounted) setState(() { _estado = 'error'; _msg = 'Error al descargar: $e'; });
    }
  }

  Future<void> _instalar() async {
    try {
      if (!await Permission.requestInstallPackages.request().isGranted) throw Exception('Permiso denegado');
      if (mounted) setState(() => _estado = 'instalando');
      await _channel.invokeMethod('instalarApk', {'path': _apkFile!.path});
      if (mounted) setState(() => _estado = 'listo');
    } catch (e) {
      if (mounted) setState(() { _estado = 'error'; _msg = 'No se pudo instalar: $e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: Rad.rXl),
      contentPadding: const EdgeInsets.all(Sp.xl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_estado == 'descargando') ...[
            const Icon(Icons.download, color: AppColors.granate, size: 48),
            const SizedBox(height: Sp.lg),
            Text('Descargando v${widget.versionLegible}', style: AppType.h3, textAlign: TextAlign.center),
            const SizedBox(height: Sp.md),
            ClipRRect(borderRadius: Rad.rPill, child: LinearProgressIndicator(value: _progreso > 0 ? _progreso : null, color: AppColors.granate)),
            const SizedBox(height: Sp.sm),
            Text(_msg, style: AppType.captionXs),
          ] else if (_estado == 'permiso') ...[
            const Icon(Icons.shield, color: AppColors.granate, size: 48),
            const SizedBox(height: Sp.lg),
            Text('Permiso necesario', style: AppType.h3),
            const SizedBox(height: Sp.sm),
            Text('Android te pedirá permitir la instalación. Es seguro.', style: AppType.captionXs, textAlign: TextAlign.center),
            const SizedBox(height: Sp.xl),
            AppButton(label: 'CONTINUAR', onPressed: _instalar),
          ] else if (_estado == 'listo') ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: Sp.lg),
            Text('¡Listo!', style: AppType.h3),
            const SizedBox(height: Sp.xl),
            AppButton(label: 'CERRAR', onPressed: () => Navigator.pop(context, true)),
          ] else ...[
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: Sp.lg),
            Text(_msg, style: AppType.body.copyWith(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: Sp.xl),
            AppButton(label: 'CERRAR', variant: AppButtonVariant.secondary, onPressed: () => Navigator.pop(context, false)),
          ],
        ],
      ),
    );
  }
}