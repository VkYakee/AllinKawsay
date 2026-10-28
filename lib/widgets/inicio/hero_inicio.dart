// lib/widgets/inicio/hero_inicio.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class HeroInicio extends StatelessWidget {
  final String nombreUsuario;
  final VoidCallback onBuscar;
  final VoidCallback onZampona;

  const HeroInicio({
    super.key,
    required this.nombreUsuario,
    required this.onBuscar,
    required this.onZampona,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(Sp.xxl, Sp.lg, Sp.xxl, Sp.xxxl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0A0A), AppColors.granateOscuro, AppColors.granate],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _BotonCristal(icono: Icons.search, onTap: onBuscar),
                const SizedBox(width: Sp.sm),
                _BotonCristal(icono: Icons.piano, onTap: onZampona),
              ],
            ),
            const SizedBox(height: Sp.md),
            // Halo de luz difuminado detrás del logo
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dorado.withOpacity(0.25),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.dorado.withOpacity(0.6), width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.granate,
                      child: const Icon(Icons.music_note, color: AppColors.dorado, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Sp.lg),
            Text(
              'ALLIN KAWSAY',
              style: AppType.h2.copyWith(
                color: AppColors.dorado,
                letterSpacing: 8,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: Sp.xs),
            Text(
              'C.I.A.C. · Juliaca · Perú',
              style: AppType.captionXs.copyWith(
                color: AppColors.dorado.withOpacity(0.6),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: Sp.lg),
            // Píldora de cristal (Glass Pill) para el saludo
            ClipRRect(
              borderRadius: Rad.rPill,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: Rad.rPill,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: Text(
                    'Hola, $nombreUsuario',
                    style: AppType.caption.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonCristal extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  const _BotonCristal({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.white.withOpacity(0.12),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Sp.md),
              child: Icon(icono, color: AppColors.dorado, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}