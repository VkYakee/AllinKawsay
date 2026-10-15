import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/github_service.dart';
import '../theme/colors.dart';
import '../widgets/dialogo_descarga.dart';
import '../widgets/watermark_overlay.dart';

class CompartirAppScreen extends StatefulWidget {
  const CompartirAppScreen({super.key});

  @override
  State<CompartirAppScreen> createState() => _CompartirAppScreenState();
}

class _CompartirAppScreenState extends State<CompartirAppScreen> {
  static const String _channel =
      MethodChannel('com.sikuris/screen_security');

  static const String _enlaceDescarga =
      'https://github.com/yeo-drake/AllinKawsay/releases/latest/download/AllinKawsay.apk';

  bool _descargandoApk = false;

  Future<void> _copiar() async {
    await Clipboard.setData(const ClipboardData(text: _enlaceDescarga));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enlace copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _compartirWhatsApp() async {
    const texto = '📲 Descargá la app oficial del grupo Allin Kawsay:\n\n'
        '$_enlaceDescarga\n\n'
        'Es la app con el cancionero, numerofonía, audios y más. 🎶';
    final uri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(texto)}');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _abrirNavegador() async {
    final uri = Uri.parse(_enlaceDescarga);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el navegador')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Descarga la última versión estable del APK y abre el instalador.
  Future<void> _descargarEInstalar() async {
    if (_descargandoApk) return;
    setState(() => _descargandoApk = true);

    // 1) Obtener la última release estable para tener la URL correcta
    String urlApk = _enlaceDescarga;
    String versionLegible = 'última versión';

    try {
      final releases = await GithubService.listarEstables(limite: 1);
      if (releases.isNotEmpty && releases.first.tieneApk) {
        urlApk = releases.first.urlApk;
        versionLegible = releases.first.tag;
      }
    } catch (_) {
      // Si falla la API, usamos el enlace genérico de todas formas
    }

    if (!mounted) return;

    // 2) Mostrar diálogo de descarga
    final nombre = 'AllinKawsay_$versionLegible.apk'.replaceAll(' ', '_');
    final resultado = await DialogoDescarga.mostrar(
      context,
      url: urlApk,
      nombre: nombre,
      mime: 'application/vnd.android.package-archive',
      titulo: 'Descargando Allin Kawsay',
    );

    if (!mounted) return;
    setState(() => _descargandoApk = false);

    if (resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo descargar el APK'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3) El archivo se guardó en Descargas. Ahora lo copiamos a temp
    //    para poder abrirlo con el instalador vía FileProvider.
    //    Como no tenemos el path exacto (el nativo lo maneja), vamos
    //    a descargar directo a temp con un segundo paso.
    try {
      final tempDir = await getTemporaryDirectory();
      final archivoTemp = File('${tempDir.path}/$nombre');

      // Si el archivo temp no existe, lo descargamos de nuevo a temp
      // (no es lo ideal pero es lo más simple para abrir el instalador)
      if (!await archivoTemp.exists()) {
        // Volvemos a descargar a temp con progreso
        if (!mounted) return;
        setState(() => _descargandoApk = true);

        final bytes = await _descargarATempConProgreso(urlApk);
        if (bytes == null) {
          if (!mounted) return;
          setState(() => _descargandoApk = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo preparar el instalador'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        await archivoTemp.writeAsBytes(bytes);
        if (!mounted) return;
        setState(() => _descargandoApk = false);
      }

      // 4) Lanzar el instalador de Android
      await _channel.invokeMethod('instalarApk', {
        'path': archivoTemp.path,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _descargandoApk = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'No se pudo abrir el instalador.\n\n'
              'Es posible que necesites habilitar "Instalar apps '
              'desconocidas" para Allin Kawsay en los ajustes de Android.\n\n$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<int>?> _descargarATempConProgreso(String url) async {
    // Reusamos el servicio pero necesitamos los bytes, así que
    // hacemos una descarga directa sin progreso por simplicidad.
    // El progreso visible ya lo mostró el diálogo anterior.
    try {
      final releases = await GithubService.listarEstables(limite: 1);
      if (releases.isEmpty) return null;

      // Descargamos usando el servicio de descarga a temp
      final bytes = await _descargarBytes(url);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<List<int>?> _descargarBytes(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await HttpClient()
          .getUrl(uri)
          .then((req) => req.close());
      if (response.statusCode != 200) return null;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        builder.add(chunk);
      }
      return builder.takeBytes();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('COMPARTIR APP')),
      body: WatermarkOverlay(
        opacity: 0.04,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            // ═══ BOTÓN GRANDE: DESCARGAR ACTUALIZACIÓN ═══
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.granate,
                    AppColors.granateOscuro,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.granate.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.system_update_alt,
                            color: AppColors.dorado, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DESCARGAR ACTUALIZACIÓN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.dorado,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bajá la última versión e instalala directo',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed:
                          _descargandoApk ? null : _descargarEInstalar,
                      icon: _descargandoApk
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: AppColors.granate,
                                  strokeWidth: 2.5),
                            )
                          : const Icon(Icons.download,
                              size: 18, color: AppColors.granate),
                      label: Text(
                        _descargandoApk
                            ? 'PREPARANDO...'
                            : 'DESCARGAR E INSTALAR',
                        style: const TextStyle(
                          color: AppColors.granate,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.dorado,
                        foregroundColor: AppColors.granate,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Header QR
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.granate.withOpacity(0.08),
                    AppColors.dorado.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.dorado.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradienteDorado,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.share,
                        color: AppColors.granate, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COMPARTIR LA APP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.seccionTitulo(context),
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mostrá este QR o compartí el enlace para que '
                          'otros descarguen Allin Kawsay.',
                          style: TextStyle(
                            fontSize: 11,
                            color: onSurface.withOpacity(0.65),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // QR
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppColors.dorado.withOpacity(0.5),
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70,
                          height: 70,
                          color: AppColors.granate,
                          child: const Icon(Icons.music_note,
                              color: AppColors.dorado, size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ALLIN KAWSAY',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.granate,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: _enlaceDescarga,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.granate,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.negro,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Escaneá para descargar',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.negro.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Botones
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _compartirWhatsApp,
                icon: const Icon(Icons.chat, size: 18),
                label: const Text(
                  'COMPARTIR POR WHATSAPP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _copiar,
                icon: const Icon(Icons.copy,
                    size: 18, color: AppColors.granate),
                label: const Text(
                  'COPIAR ENLACE',
                  style: TextStyle(
                    color: AppColors.granate,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppColors.granate.withOpacity(0.6)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: TextButton.icon(
                onPressed: _abrirNavegador,
                icon: Icon(Icons.open_in_new,
                    size: 18, color: onSurface.withOpacity(0.7)),
                label: Text(
                  'ABRIR ENLACE EN EL NAVEGADOR',
                  style: TextStyle(
                    color: onSurface.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.dorado.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.dorado.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.granate),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Al escanear el QR o tocar el enlace, se descarga '
                      'el APK desde GitHub. Android pedirá permiso para '
                      'instalar apps de origen desconocido la primera vez.',
                      style: TextStyle(
                        fontSize: 12,
                        color: onSurface.withOpacity(0.75),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}