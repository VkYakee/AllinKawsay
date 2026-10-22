// lib/widgets/social_buttons.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design/design.dart';
import '../theme/colors.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  static const String _facebook = 'https://www.facebook.com/share/1CvfrrGhag/';
  static const String _tiktok = 'https://www.tiktok.com/@allin.kawsay';
  static const String _whatsapp = 'https://chat.whatsapp.com/FKfCZogyh6aAwaTzKzbyMY?s=cl&p=a&mlu=4&ilr=4';

  Future<void> _abrir(BuildContext context, String url) async {
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication) && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: Column(
        children: [
          const SeccionHeader(title: 'Síguenos', icon: Icons.share, padding: EdgeInsets.zero),
          const SizedBox(height: Sp.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _boton(context, Icons.facebook, const Color(0xFF1877F2), 'Facebook', _facebook),
              _boton(context, Icons.music_note, const Color(0xFF000000), 'TikTok', _tiktok),
              _boton(context, Icons.chat, const Color(0xFF25D366), 'WhatsApp', _whatsapp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boton(BuildContext context, IconData icono, Color color, String label, String url) {
    return GestureDetector(
      onTap: () => _abrir(context, url),
      child: Column(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Icon(icono, color: Colors.white, size: 24),
          ),
          const SizedBox(height: Sp.xs),
          Text(label, style: AppType.captionXs),
        ],
      ),
    );
  }
}