// lib/widgets/perfil/perfil_stats.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/usuario.dart';
import '../../services/cancion_service.dart';
import '../../theme/colors.dart';

class PerfilStats extends StatelessWidget {
  final Usuario usuario;

  const PerfilStats({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SeccionHeader(
              title: 'Mis estadísticas',
              icon: Icons.bar_chart,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: Sp.md),
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: CancionService().contarPorUsuario(
                        usuario.uid, nombre: usuario.nombre),
                    builder: (context, snap) {
                      if (!snap.hasData) return const _StatSkeleton();
                      return _StatCard(
                          Icons.library_music,
                          snap.data.toString(),
                          'Canciones');
                    },
                  ),
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: FutureBuilder<int>(
                    future: CancionService().totalReproduccionesDeUsuario(
                        usuario.uid, nombre: usuario.nombre),
                    builder: (context, snap) {
                      if (!snap.hasData) return const _StatSkeleton();
                      return _StatCard(
                          Icons.play_arrow,
                          snap.data.toString(),
                          'Reproducciones');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String label;

  const _StatCard(this.icono, this.valor, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.granate.withOpacity(0.1),
          AppColors.granate.withOpacity(0.02),
        ]),
        borderRadius: Rad.rMd,
        border: Border.all(color: AppColors.granate.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icono, color: AppColors.granate, size: 24),
          const SizedBox(height: Sp.xs),
          Text(valor,
              style: AppType.h3.copyWith(color: AppColors.granate)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppType.captionXs.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: Rad.rMd,
      ),
    );
  }
}