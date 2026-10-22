// lib/screens/compartir_app_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design/design.dart';
import '../services/github_service.dart';
import '../theme/colors.dart';
import '../widgets/dialogo_descarga.dart';

class CompartirAppScreen extends StatefulWidget {
  const CompartirAppScreen({super.key});

  @override
  State<CompartirAppScreen> createState() => _CompartirAppScreenState();
}

class _CompartirAppScreenState extends State<CompartirAppScreen> {
  static const MethodChannel _channel = MethodChannel('com.allinkawsay/native');
  
  // Link directo al ÚLTIMO RELEASE ESTABLE (El que tú lanzas manualmente)
  static const String _enlaceDescarga = 'https://github.com/yeo-drake/AllinKawsay/releases/latest/download/AllinKawsay.apk';
  static const String _enlacePagina = 'https://yeo-drake.github.io/AllinKawsay/';
  
  bool _descargandoApk = false;

  Future<void> _copiar() async {
    await Clipboard.setData(const ClipboardData(text: _enlacePagina));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace copiado')));
  }

  Future<void> _compartirWhatsApp() async {
    const texto = '📲 Descarga la app oficial de Allin Kawsay:\n\n$_enlacePagina\n\nLa app con el cancionero, numerofonía y más. 🎶';
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(texto)}');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _descargarEInstalar() async {
    if (_descargandoApk) return;
    setState(() => _descargandoApk = true);
    try {
      String urlApk = _enlaceDescarga;
      
      // Si la API de GitHub falla, usa el enlace por defecto. 
      // Si funciona, asegura obtener el link del último Release manual.
      try {
        final releases = await GithubService.listarEstables(limite: 1);
        if (releases.isNotEmpty && releases.first.tieneApk) {
          urlApk = releases.first.urlApk;
        }
      } catch (_) {}

      final resultado = await DialogoDescarga.mostrar(
        context,
        url: urlApk,
        nombre: 'AllinKawsay.apk',
        mime: 'application/vnd.android.package-archive',
      );

      if (resultado == null) return;
      final tempDir = await getTemporaryDirectory();
      final archivoTemp = File('${tempDir.path}/update.apk');
      final bytes = await _descargarBytes(urlApk);
      if (bytes != null) {
        await archivoTemp.writeAsBytes(bytes);
        await _channel.invokeMethod('instalarApk', {'path': archivoTemp.path});
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al abrir instalador: $e')));
    } finally {
      if (mounted) setState(() => _descargandoApk = false);
    }
  }

  Future<List<int>?> _descargarBytes(String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) return null;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) builder.add(chunk);
      return builder.takeBytes();
    } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Compartir App',
      body: ListView(
        padding: const EdgeInsets.all(Sp.lg),
        children: [
          AppCard(
            color: AppColors.granate,
            child: Column(
              children: [
                const Icon(Icons.system_update_alt, color: AppColors.dorado, size: 40),
                const SizedBox(height: Sp.md),
                Text('Actualiza tu App', style: AppType.h3.copyWith(color: AppColors.dorado)),
                const SizedBox(height: Sp.sm),
                Text('Descarga la última versión oficial directamente.', style: AppType.bodySm.copyWith(color: AppColors.dorado.withOpacity(0.7)), textAlign: TextAlign.center),
                const SizedBox(height: Sp.lg),
                AppButton(
                  label: 'DESCARGAR ÚLTIMA VERSIÓN',
                  variant: AppButtonVariant.secondary,
                  fullWidth: true,
                  loading: _descargandoApk,
                  onPressed: _descargarEInstalar,
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.xl),
          AppCard(
            child: Column(
              children: [
                Text('Escanea el código QR', style: AppType.h3),
                const SizedBox(height: Sp.sm),
                Text('Comparte la app con otros miembros del grupo.', style: AppType.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: Sp.xl),
                Container(
                  padding: const EdgeInsets.all(Sp.md),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: Rad.rLg),
                  child: QrImageView(
                    data: _enlaceDescarga, // <-- Ahora el QR va al APK directo
                    size: 200,
                    eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.granate),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.negro),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.xl),
          AppButton(label: 'COMPARTIR POR WHATSAPP', icon: Icons.chat, onPressed: _compartirWhatsApp),
          const SizedBox(height: Sp.sm),
          AppButton(label: 'COPIAR ENLACE DE LA WEB', icon: Icons.copy, variant: AppButtonVariant.secondary, onPressed: _copiar),
          const SizedBox(height: Sp.xxxl),
        ],
      ),
    );
  }
}