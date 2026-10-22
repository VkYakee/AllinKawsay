// lib/widgets/watermark_overlay.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class WatermarkOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double logoSize;

  const WatermarkOverlay({
    super.key,
    required this.child,
    this.opacity = 0.06,
    this.logoSize = 260,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ajustada = isDark ? opacity * 0.35 : opacity;
    
    // Obtenemos el correo del usuario actual para la marca de agua
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Allin Kawsay';

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        IgnorePointer(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo central
                Opacity(
                  opacity: ajustada,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Texto dinámico con el correo del usuario
                Opacity(
                  opacity: ajustada * 1.5, // Un poco más visible que el logo
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black45 : Colors.white45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '© $email',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : AppColors.granate,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}