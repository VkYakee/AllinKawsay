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
          colors: [
            Color(0xFF0A0A0A),
            AppColors.granateOscuro,
            AppColors.granate,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _BotonHeader(
                    icono: Icons.search,
                    tooltip: 'Buscar',
                    onTap: onBuscar),
                const SizedBox(width: Sp.sm),
                _BotonHeader(
                    icono: Icons.piano,
                    tooltip: 'Zampoña',
                    onTap: onZampona),
              ],
            ),
            const SizedBox(height: Sp.xs),
            _Logo(),
            const SizedBox(height: Sp.lg),
            const Text(
              'ALLIN KAWSAY',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.dorado,
                letterSpacing: 5,
              ),
            ),
            const SizedBox(height: Sp.xs),
            _Saludo(nombre: nombreUsuario),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.dorado.withOpacity(0.3),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.granate,
            child: const Icon(Icons.music_note,
                color: AppColors.dorado, size: 45),
          ),
        ),
      ),
    );
  }
}

class _Saludo extends StatelessWidget {
  final String nombre;
  const _Saludo({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Sp.md, vertical: Sp.xs),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: Rad.rPill,
      ),
      child: Text(
        'Hola, $nombre',
        style: TextStyle(
          color: AppColors.dorado.withOpacity(0.9),
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _BotonHeader extends StatelessWidget {
  final IconData icono;
  final String tooltip;
  final VoidCallback onTap;

  const _BotonHeader({
    required this.icono,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: Rad.rPill,
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(Sp.sm + 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.dorado.withOpacity(0.3)),
            ),
            child: Icon(icono, color: AppColors.dorado, size: 22),
          ),
        ),
      ),
    );
  }
}