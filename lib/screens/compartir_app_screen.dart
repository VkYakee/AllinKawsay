import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../widgets/watermark_overlay.dart';

class CompartirAppScreen extends StatelessWidget {
  const CompartirAppScreen({super.key});

  /// URL de descarga del último release estable.
  static const String enlaceDescarga =
      'https://github.com/yeo-drake/AllinKawsay/releases/latest/download/AllinKawsay.apk';

  Future<void> _copiar(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: enlaceDescarga));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enlace copiado al portapapeles'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _compartirWhatsApp(BuildContext context) async {
    const texto = '📲 Descargá la app oficial del grupo Allin Kawsay:\n\n'
        '$enlaceDescarga\n\n'
        'Es la app con el cancionero, numerofonía, audios y más. 🎶';
    final uri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(texto)}');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _abrirNavegador(BuildContext context) async {
    final uri = Uri.parse(enlaceDescarga);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el navegador')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
            // Header
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
                      data: enlaceDescarga,
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
                onPressed: () => _compartirWhatsApp(context),
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
                onPressed: () => _copiar(context),
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
                onPressed: () => _abrirNavegador(context),
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