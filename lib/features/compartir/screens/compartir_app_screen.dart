// lib/features/compartir/screens/compartir_app_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../services/github_service.dart';
import '../../../widgets/dialogo_descarga.dart';

class CompartirAppScreen extends StatefulWidget {
  const CompartirAppScreen({super.key});

  @override
  State<CompartirAppScreen> createState() => _CompartirAppScreenState();
}

class _CompartirAppScreenState extends State<CompartirAppScreen> {
  static const MethodChannel _channel = MethodChannel('com.allinkawsay/native');

  static const String _enlaceDescarga =
      'https://github.com/VkYakee/AllinKawsay/releases/latest/download/AllinKawsay.apk';
  static const String _enlacePagina =
      'https://VkYakee.github.io/AllinKawsay/';

  bool _descargandoApk = false;

  Future<void> _copiar() async {
    await Clipboard.setData(const ClipboardData(text: _enlacePagina));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enlace copiado al portapapeles',
            style: AppText.body.copyWith(color: AppColors.dorado),
          ),
          backgroundColor: AppColors.granateProfundo,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
        ),
      );
    }
  }

  Future<void> _compartirWhatsApp() async {
    const texto =
        '🎶 *Allin Kawsay - App Oficial*\n\n'
        'Hermano sikuri, descarga la app oficial con todo el repertorio, numerofonía fija para tocar, audios y agenda de ensayos:\n\n'
        '📲 $_enlacePagina\n\n'
        '_Fuerza y Armonía · Juliaca, Puno_';
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(texto)}');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _descargarEInstalar() async {
    if (_descargandoApk) return;
    setState(() => _descargandoApk = true);
    try {
      String urlApk = _enlaceDescarga;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir instalador: $e')),
        );
      }
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
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        title: Text(
          'Compartir App',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        backgroundColor: AppColors.fondoOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.dorado,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
        children: [
          // ─── CARD DE ACTUALIZACIÓN / DESCARGA DIRECTA ───
          AppCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.granateProfundo,
                AppColors.granateOscuro,
              ],
            ),
            padding: const EdgeInsets.all(Sp.lg),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.dorado.withOpacity(0.15),
                    border: Border.all(
                      color: AppColors.dorado.withOpacity(0.4),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.system_update_alt_rounded,
                      color: AppColors.dorado,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: Sp.md),
                Text(
                  'Instalar o Actualizar',
                  style: AppText.h3.copyWith(
                    color: AppColors.dorado,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Sp.xs),
                Text(
                  'Descarga el APK oficial directamente en tu dispositivo Android.',
                  style: AppText.caption.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Sp.lg),
                AllinButton(
                  label: _descargandoApk ? 'PREPARANDO...' : 'DESCARGAR APK OFICIAL',
                  icono: Icons.download_rounded,
                  variant: AllinButtonVariant.gold,
                  expand: true,
                  loading: _descargandoApk,
                  onPressed: _descargarEInstalar,
                ),
              ],
            ),
          ),

          const SizedBox(height: Sp.xl),

          // ─── CARD QR CODE CEREMONIAL ───
          AppCard(
            glass: true,
            padding: const EdgeInsets.all(Sp.xl),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_2_rounded,
                      color: AppColors.dorado,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Código QR de Acceso',
                      style: AppText.h3.copyWith(
                        color: AppColors.dorado,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.xs),
                Text(
                  'Muestra este código a tus compañeros sikuris durante el ensayo.',
                  textAlign: TextAlign.center,
                  style: AppText.caption.copyWith(
                    color: AppColors.onSurfaceVariant(context),
                  ),
                ),
                const SizedBox(height: Sp.lg),

                // Contenedor QR estilizado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: Rad.rLg,
                    border: Border.all(
                      color: AppColors.dorado,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dorado.withOpacity(0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _enlacePagina,
                    size: 190,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.granateOscuro,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Sp.xl),

          // ─── BOTONES DE ACCIÓN RÁPIDA ───
          AllinButton(
            label: 'COMPARTIR POR WHATSAPP',
            icono: Icons.chat_rounded,
            variant: AllinButtonVariant.gold,
            expand: true,
            onPressed: _compartirWhatsApp,
          ),
          const SizedBox(height: Sp.sm),
          AllinButton(
            label: 'COPIAR ENLACE WEB',
            icono: Icons.copy_rounded,
            variant: AllinButtonVariant.glass,
            expand: true,
            onPressed: _copiar,
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
