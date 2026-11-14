// lib/widgets/social_buttons.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/tokens.dart';
import '../core/design/typography.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  static const String _facebook = 'https://www.facebook.com/share/1CvfrrGhag/';
  static const String _tiktok = 'https://www.tiktok.com/@allin.kawsay';
  static const String _whatsapp = 'https://chat.whatsapp.com/FKfCZogyh6aAwaTzKzbyMY?s=cl&p=a&mlu=4&ilr=4';

  Future<void> _abrir(BuildContext context, String url) async {
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication) && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hub_rounded,
                size: 16,
                color: AppColors.dorado.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'COMUNIDAD ALLIN KAWSAY',
                style: AppText.label.copyWith(
                  color: AppColors.dorado,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SocialBtn(
                icono: Icons.facebook,
                color: const Color(0xFF1877F2),
                label: 'Facebook',
                onTap: () => _abrir(context, _facebook),
              ),
              _SocialBtn(
                icono: Icons.music_note_rounded,
                color: const Color(0xFF1F1F24),
                label: 'TikTok',
                onTap: () => _abrir(context, _tiktok),
              ),
              _SocialBtn(
                icono: Icons.chat_bubble_rounded,
                color: const Color(0xFF25D366),
                label: 'WhatsApp',
                onTap: () => _abrir(context, _whatsapp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatefulWidget {
  final IconData icono;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SocialBtn({
    required this.icono,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        AppMotion.hapticSelection();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.dorado.withOpacity(0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(widget.icono, color: Colors.white, size: 24),
            ),
            const SizedBox(height: Sp.xs),
            Text(
              widget.label,
              style: AppText.caption.copyWith(
                color: AppColors.onSurfaceVariant(context),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
