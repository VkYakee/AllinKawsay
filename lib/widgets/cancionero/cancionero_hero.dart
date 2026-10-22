// lib/widgets/cancionero/cancionero_hero.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class CancioneroHero extends StatelessWidget {
  final int totalCanciones;
  final int filtrosActivos;
  final bool modoIndice;
  final VoidCallback onFiltros;
  final VoidCallback onToggleVista;
  final VoidCallback onPracticar;

  const CancioneroHero({
    super.key,
    required this.totalCanciones,
    required this.filtrosActivos,
    required this.modoIndice,
    required this.onFiltros,
    required this.onToggleVista,
    required this.onPracticar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          Sp.xl, Sp.lg, Sp.xl, Sp.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.granateOscuro,
            AppColors.granate,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancionero',
                        style: AppType.h1.copyWith(
                          color: AppColors.dorado,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.dorado.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$totalCanciones canciones',
                            style: AppType.caption.copyWith(
                              color: AppColors.dorado.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _BotonRedondo(
                  icon: modoIndice
                      ? Icons.grid_view_rounded
                      : Icons.view_list_rounded,
                  onTap: onToggleVista,
                ),
                const SizedBox(width: Sp.sm),
                _BotonRedondo(
                  icon: Icons.tune,
                  onTap: onFiltros,
                  badge: filtrosActivos > 0 ? filtrosActivos : null,
                ),
              ],
            ),
            const SizedBox(height: Sp.lg),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPracticar,
                icon: const Icon(Icons.school, size: 16),
                label: const Text('Practicar con zampoña'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.dorado,
                  side: BorderSide(
                    color: AppColors.dorado.withOpacity(0.5),
                    width: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
                  textStyle: AppType.label.copyWith(
                    color: AppColors.dorado,
                    letterSpacing: 0.8,
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

class _BotonRedondo extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;

  const _BotonRedondo({
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withOpacity(0.12),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Sp.sm + 2),
              child: Icon(icon, color: AppColors.dorado, size: 20),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18),
              decoration: BoxDecoration(
                color: AppColors.dorado,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.granateOscuro, width: 2),
              ),
              child: Text(
                '$badge',
                textAlign: TextAlign.center,
                style: AppType.labelXs.copyWith(
                  color: AppColors.granateOscuro,
                  fontSize: 9,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}