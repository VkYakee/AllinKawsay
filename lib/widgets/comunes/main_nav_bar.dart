// lib/widgets/comunes/main_nav_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../design/design.dart';
import '../../services/player_service.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Mini-Player Flotante estilo Apple Music (aparece al reproducir) ──
            const _FloatingMiniPlayer(),

            // ── Cápsula de Navegación Liquid Glass ──
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: GlassBlur.heavy,
                  sigmaY: GlassBlur.heavy,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sp.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF160B0E).withOpacity(0.72)
                        : const Color(0xFF280910).withOpacity(0.84),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.dorado.withOpacity(0.24),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.28),
                        blurRadius: 28,
                        spreadRadius: -4,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Inicio',
                        index: 0,
                        selectedIndex: selectedIndex,
                        onTap: onDestinationSelected,
                      ),
                      _NavItem(
                        icon: Icons.library_music_outlined,
                        activeIcon: Icons.library_music_rounded,
                        label: 'Música',
                        index: 1,
                        selectedIndex: selectedIndex,
                        onTap: onDestinationSelected,
                      ),
                      _NavItem(
                        icon: Icons.event_outlined,
                        activeIcon: Icons.event_rounded,
                        label: 'Eventos',
                        index: 2,
                        selectedIndex: selectedIndex,
                        onTap: onDestinationSelected,
                        badge: eventosNuevos,
                      ),
                      _NavItem(
                        icon: Icons.photo_library_outlined,
                        activeIcon: Icons.photo_library_rounded,
                        label: 'Recuerdos',
                        index: 3,
                        selectedIndex: selectedIndex,
                        onTap: onDestinationSelected,
                      ),
                      _NavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person_rounded,
                        label: 'Perfil',
                        index: 4,
                        selectedIndex: selectedIndex,
                        onTap: onDestinationSelected,
                      ),
                    ],
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

class _FloatingMiniPlayer extends StatelessWidget {
  const _FloatingMiniPlayer();

  @override
  Widget build(BuildContext context) {
    final playerService = PlayerService();

    return ValueListenableBuilder<EstadoPlayer>(
      valueListenable: playerService.estado,
      builder: (context, estado, _) {
        if (estado.cancionId == null) return const SizedBox.shrink();

        final tag = playerService.player.sequenceState?.currentSource?.tag;
        final mediaItem = tag is MediaItem ? tag : null;
        final titulo = mediaItem?.title ?? 'Reproduciendo...';
        final autor = mediaItem?.artist ?? 'Allin Kawsay';

        return Padding(
          padding: const EdgeInsets.only(bottom: Sp.sm),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: GlassBlur.medium,
                sigmaY: GlassBlur.medium,
              ),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: Sp.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.granate.withOpacity(0.85),
                      AppColors.granateOscuro.withOpacity(0.88),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.dorado.withOpacity(0.32),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.dorado.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: AppColors.dorado,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: Sp.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppType.subtitle.copyWith(
                              color: AppColors.blanco,
                              fontSize: 13.5,
                            ),
                          ),
                          Text(
                            autor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppType.captionXs.copyWith(
                              color: AppColors.dorado.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (estado.cargando)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.dorado,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          estado.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.dorado,
                          size: 26,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          if (estado.playing) {
                            playerService.player.pause();
                          } else {
                            playerService.player.play();
                          }
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.dorado.withOpacity(0.65),
                        size: 20,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        playerService.detener();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          if (!isSelected) HapticFeedback.selectionClick();
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Dur.normal,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.granateClaro.withOpacity(0.95),
                      AppColors.granate.withOpacity(0.95),
                    ],
                  )
                : null,
            borderRadius: Rad.rPill,
            border: isSelected
                ? Border.all(
                    color: AppColors.dorado.withOpacity(0.35),
                    width: 0.8,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.granate.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.08 : 1.0,
                    duration: Dur.fast,
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      color: isSelected
                          ? AppColors.dorado
                          : AppColors.dorado.withOpacity(0.52),
                      size: 23,
                    ),
                  ),
                  if (badge > 0)
                    Positioned(
                      top: -4,
                      right: -7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: Rad.rPill,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          '$badge',
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
                duration: Dur.fast,
                style: AppType.labelXs.copyWith(
                  color: isSelected
                      ? AppColors.dorado
                      : AppColors.dorado.withOpacity(0.45),
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
