// lib/features/home/widgets/allin_floating_nav_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';

class AllinFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int eventosNuevos;

  const AllinFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.eventosNuevos = 0,
  });

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      label: 'Inicio',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _NavDestination(
      label: 'Música',
      icon: Icons.library_music_outlined,
      activeIcon: Icons.library_music_rounded,
    ),
    _NavDestination(
      label: 'Eventos',
      icon: Icons.event_outlined,
      activeIcon: Icons.event_rounded,
      hasBadge: true,
    ),
    _NavDestination(
      label: 'Recuerdos',
      icon: Icons.photo_library_outlined,
      activeIcon: Icons.photo_library_rounded,
    ),
    _NavDestination(
      label: 'Perfil',
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.lg),
      child: ClipRRect(
        borderRadius: Rad.rPill,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.fondoOLED.withOpacity(0.82),
              borderRadius: Rad.rPill,
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.granateSagrado.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = constraints.maxWidth / _destinations.length;

                return Stack(
                  children: [
                    // Pastilla activa deslizante con física de resorte
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 320),
                      curve: AppMotion.spring,
                      left: selectedIndex * itemWidth,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.granateSagrado,
                              AppColors.granate,
                            ],
                          ),
                          borderRadius: Rad.rPill,
                          border: Border.all(
                            color: AppColors.oroSolar.withOpacity(0.45),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.oroSolar.withOpacity(0.25),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: AppColors.granate.withOpacity(0.5),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Fila de ítems táctiles
                    Row(
                      children: List.generate(_destinations.length, (index) {
                        final dest = _destinations[index];
                        final isSelected = index == selectedIndex;
                        final badgeCount = dest.hasBadge ? eventosNuevos : 0;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isSelected) {
                                AppMotion.hapticSelection();
                                onDestinationSelected(index);
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: AnimatedScale(
                                scale: isSelected ? 1.08 : 1.0,
                                duration: AppMotion.fast,
                                curve: AppMotion.spring,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Icon(
                                          isSelected ? dest.activeIcon : dest.icon,
                                          color: isSelected
                                              ? AppColors.oroSolar
                                              : Colors.white.withOpacity(0.42),
                                          size: 23,
                                        ),
                                        if (badgeCount > 0)
                                          Positioned(
                                            top: -3,
                                            right: -6,
                                            child: Container(
                                              padding: const EdgeInsets.all(3.5),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFFF3B30), Color(0xFFE52D27)],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red.withOpacity(0.6),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 14,
                                                minHeight: 14,
                                              ),
                                              child: Text(
                                                '$badgeCount',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    AnimatedDefaultTextStyle(
                                      duration: AppMotion.fast,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.oroSolar
                                            : Colors.white.withOpacity(0.38),
                                        fontSize: 9.5,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        letterSpacing: 0.2,
                                      ),
                                      child: Text(dest.label),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool hasBadge;

  const _NavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.hasBadge = false,
  });
}
