// lib/widgets/auth/google_icon.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleIcon extends StatelessWidget {
  final double size;
  const GoogleIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4285F4), // Azul
            Color(0xFFEA4335), // Rojo
            Color(0xFFFBBC05), // Amarillo
            Color(0xFF34A853), // Verde
          ],
          stops: [0.2, 0.5, 0.75, 1.0],
        ).createShader(bounds),
        child: FaIcon(
          FontAwesomeIcons.google,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }
}