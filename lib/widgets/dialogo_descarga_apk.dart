import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/colors.dart';

/// Muestra una barra flotante arriba con el progreso de descarga
/// del APK, y al terminar ofrece instalar automáticamente.
///
/// Devuelve:
///   - true si el usuario instaló (o intentó instalar).
///   - false si canceló o hubo error.
class DialogoDescargaApk {
  static Future<bool> mostrar(
    BuildContext context, {
    required String url,
    required String nombre,
    required String versionLegible,
  }) async {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return false;

    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DescargaApkDialog(
        url: url,
        nombre: nombre,
        versionLegible: versionLegible,
      ),
    );
    return resultado ?? false;
  }
}

class _DescargaApkDialog extends StatefulWidget {
  final String url;
  final String nombre;
  final String versionLegible;

  const _DescargaApkDialog({
    required this.url,
    required this.nombre,
    required this.versionLegible,
  });

  @override
  State<_DescargaApkDialog> createState() => _DescargaApkDialogState();
}

enum _Fase { descargando, permiso, instalando, listo, error }

class _DescargaApkDialogState extends State<_DescargaApkDialog> {
  static const _channel = MethodChannel('com.allinkawsay/native');

  _Fase _fase = _Fase.descargando;
  double _progreso = 0;
  String _mensaje = 'Conectando...';
  String? _error;
  File? _apkFile;
  bool _borrado = false;

  @override
  void initState() {
    super.initState();
    _descargar();
  }

  @override
  void dispose() {
    _borrar();
    super.dispose();
  }

  Future<void> _borrar() async {
    if (_borrado) return;
    _borrado = true;
    try {
      if (_apkFile != null && await _apkFile!.exists()) {
        await _apkFile!.delete();
      }
    } catch (_) {}
  }

  Future<void> _descargar() async {
    setState(() {
      _fase = _Fase.descargando;
      _progreso = 0;
      _mensaje = 'Conectando...';
      _error = null;
    });

    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/allin_kawsay_${widget.versionLegible}.apk';
      final archivo = File(path);

      if (await archivo.exists()) {
        await archivo.delete();
      }

      final request = http.Request('GET', Uri.parse(widget.url));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Error ${response.statusCode}');
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
            _mensaje = '$mb / $totalMb MB';
          });
        }
      }
      await sink.flush();
      await sink.close();

      if (!mounted) return;
      _apkFile = archivo;

      // Pasamos a la fase de permisos
      setState(() => _fase = _Fase.permiso);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fase = _Fase.error;
        _error = 'No se pudo descargar.\n\n$e';
      });
    }
  }

  /// Pide el permiso de instalar apps de origen desconocido.
  Future<void> _pedirPermiso() async {
    try {
      var status = await Permission.requestInstallPackages.status;
      if (!status.isGranted) {
        status = await Permission.requestInstallPackages.request();
      }
      if (!mounted) return;
      if (!status.isGranted) {
        setState(() {
          _fase = _Fase.error;
          _error = 'Necesitás habilitar "Instalar apps desconocidas" '
              'para Allin Kawsay.\n\n'
              'Ajustes → Seguridad → Instalar apps desconocidas → '
              'elegí Allin Kawsay → Permitir.';
        });
        return;
      }
      await _instalar();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fase = _Fase.error;
        _error = 'No se pudo pedir el permiso: $e';
      });
    }
  }
  Future<void> _instalar() async {
    if (_apkFile == null) return;
    setState(() => _fase = _Fase.instalando);

    try {
      await _channel.invokeMethod('instalarApk', {
        'path': _apkFile!.path,
      });
      if (!mounted) return;
      setState(() => _fase = _Fase.listo);

      // Programar borrado del APK después de un rato
      Future.delayed(const Duration(seconds: 30), _borrar);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fase = _Fase.error;
        _error = 'No se pudo abrir el instalador.\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _contenido(),
      ),
    );
  }

  Widget _contenido() {
    switch (_fase) {
      case _Fase.descargando:
        return _vistaDescarga();
      case _Fase.permiso:
        return _vistaPermiso();
      case _Fase.instalando:
        return _vistaInstalando();
      case _Fase.listo:
        return _vistaListo();
      case _Fase.error:
        return _vistaError();
    }
  }

  Widget _vistaDescarga() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.gradienteGranate,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.download,
                  color: AppColors.dorado, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Descargando v${widget.versionLegible}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.granate,
                ),
              ),
            ),
            Text(
              '${(_progreso * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.granate,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _progreso > 0 ? _progreso : null,
            minHeight: 6,
            backgroundColor: AppColors.granate.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation(AppColors.granate),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _mensaje,
          style: TextStyle(
            fontSize: 11,
            color: Colors.black.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Al terminar te pediremos permiso para instalar la app. '
          'Tranqui, es normal — la instalación se hace desde la '
          'propia app oficial.',
          style: TextStyle(
            fontSize: 11,
            height: 1.4,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _vistaPermiso() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.dorado.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined,
                  color: AppColors.granate, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Permiso necesario',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.granate,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bullet('Android te pedirá habilitar "Instalar apps '
                  'desconocidas" para Allin Kawsay.'),
              const SizedBox(height: 8),
              _bullet('Es seguro: la app viene del repositorio oficial '
                  'del grupo y usa Firebase (misma tecnología que '
                  'Duolingo, Twitter, etc.).'),
              const SizedBox(height: 8),
              _bullet('Solo se pide 1 vez. Después se actualiza sola.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.black.withOpacity(0.2)),
                  foregroundColor: Colors.black.withOpacity(0.6),
                ),
                child: const Text('CANCELAR'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _pedirPermiso,
                child: const Text('CONTINUAR'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bullet(String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.dorado,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _vistaInstalando() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 42,
          height: 42,
          child: CircularProgressIndicator(
            color: AppColors.granate,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Abriendo instalador...',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.granate,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Seguí las instrucciones en pantalla.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  Widget _vistaListo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle,
              color: Colors.green, size: 32),
        ),
        const SizedBox(height: 14),
        const Text(
          '¡Listo!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.granate,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Completá la instalación desde el instalador de Android. '
          'El archivo se borrará automáticamente.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CERRAR'),
          ),
        ),
      ],
    );
  }

  Widget _vistaError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline,
              color: Colors.red, size: 32),
        ),
        const SizedBox(height: 14),
        const Text(
          'Algo salió mal',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.granate,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Error desconocido',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CERRAR'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _descargar,
                child: const Text('REINTENTAR'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}