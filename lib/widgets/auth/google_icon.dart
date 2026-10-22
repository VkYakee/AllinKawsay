// lib/widgets/auth/google_icon.dart
import 'package:flutter/material.dart';

class GoogleIcon extends StatelessWidget {
  final double size;
  const GoogleIcon({super.key, this.size = 22});

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
        ).createShader(bounds),
        child: const Icon(
          Icons.g_mobiledata_rounded, // Usamos este ícono redondeado como base para el 'G'
          size: 40, // Tamaño grande para que el shader se vea bien
          color: Colors.white,
        ),
      ),
    );
  }
}