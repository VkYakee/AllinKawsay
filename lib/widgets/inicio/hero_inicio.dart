// lib/widgets/inicio/hero_inicio.dart
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
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _BotonHeader(icono: Icons.search, onTap: onBuscar),
                const SizedBox(width: Sp.sm),
                _BotonHeader(icono: Icons.piano, onTap: onZampona),
              ],
            ),
            const SizedBox(height: Sp.md),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dorado.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dorado.withOpacity(0.2),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
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
            const SizedBox(height: Sp.lg),
            Text(
              'ALLIN KAWSAY',
              style: AppType.h2.copyWith(
                color: AppColors.dorado,
                letterSpacing: 6,
                fontSize: 24,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: Rad.rPill,
                border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
              ),
              child: Text(
                'Hola, $nombreUsuario',
                style: AppType.caption.copyWith(color: AppColors.dorado),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonHeader extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  const _BotonHeader({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Sp.sm + 2),
          child: Icon(icono, color: AppColors.dorado, size: 22),
        ),
      ),
    );
  }
}