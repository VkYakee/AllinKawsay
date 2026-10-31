// lib/features/home/widgets/main_nav_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

class MainNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int eventosNuevos;

  const MainNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.eventosNuevos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.xl),
      child: ClipRRect(
        borderRadius: Rad.rPill,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72, // Un poco más alto
            padding: const EdgeInsets.symmetric(horizontal: Sp.sm),
            decoration: BoxDecoration(
              // Fondo semi-transparente con un tinte vino
              color: AppColors.granateOscuro.withOpacity(0.75),
              borderRadius: Rad.rPill,
              border: Border.all(color: AppColors.dorado.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dorado.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Inicio', index: 0, selectedIndex: selectedIndex, onTap: onDestinationSelected),
                _NavItem(icon: Icons.library_music_outlined, activeIcon: Icons.library_music_rounded, label: 'Música', index: 1, selectedIndex: selectedIndex, onTap: onDestinationSelected),
                _NavItem(icon: Icons.event_outlined, activeIcon: Icons.event_rounded, label: 'Eventos', index: 2, selectedIndex: selectedIndex, onTap: onDestinationSelected, badge: eventosNuevos),
                _NavItem(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library_rounded, label: 'Recuerdos', index: 3, selectedIndex: selectedIndex, onTap: onDestinationSelected),
                _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Perfil', index: 4, selectedIndex: selectedIndex, onTap: onDestinationSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppMotion.hapticLight();
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.spring,
            padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: Sp.sm),
            decoration: BoxDecoration(
              // Solo la pestaña activa tiene un fondo brillante
              color: isSelected ? AppColors.granate : Colors.transparent,
              borderRadius: Rad.rPill,
              boxShadow: isSelected ? [
                BoxShadow(color: AppColors.granate.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
              ] : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isSelected ? activeIcon : icon,
                      color: isSelected ? AppColors.dorado : Colors.white54,
                      size: 26,
                    ),
                    if (badge > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
                AnimatedSize(
                  duration: AppMotion.fast,
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            label,
                            style: AppText.labelXs.copyWith(color: AppColors.dorado, fontSize: 10),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}