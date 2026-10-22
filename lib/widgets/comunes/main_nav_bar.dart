// lib/widgets/comunes/main_nav_bar.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.negro,
        border: Border(
          top: BorderSide(color: AppColors.dorado.withOpacity(0.15)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: Sp.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Inicio', index: 0, selectedIndex: selectedIndex, onTap: onDestinationSelected),
              _NavItem(icon: Icons.library_music_outlined, activeIcon: Icons.library_music, label: 'Cancionero', index: 1, selectedIndex: selectedIndex, onTap: onDestinationSelected),
              _NavItem(icon: Icons.event_outlined, activeIcon: Icons.event, label: 'Eventos', index: 2, selectedIndex: selectedIndex, onTap: onDestinationSelected, badge: eventosNuevos),
              _NavItem(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library, label: 'Recuerdos', index: 3, selectedIndex: selectedIndex, onTap: onDestinationSelected),
              _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil', index: 4, selectedIndex: selectedIndex, onTap: onDestinationSelected),
            ],
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
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.granate : Colors.transparent,
          borderRadius: Rad.rPill,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppColors.dorado : AppColors.dorado.withOpacity(0.5),
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    top: -4, right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppType.labelXs.copyWith(
                color: isSelected ? AppColors.dorado : AppColors.dorado.withOpacity(0.5),
                letterSpacing: 0.5,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}