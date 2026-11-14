// lib/widgets/perfil/modal_ajustes.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/design/colors.dart';
import '../../core/design/motion.dart';
import '../../core/design/tokens.dart';
import '../../core/design/typography.dart';
import '../../features/perfil/screens/gestion_cache_screen.dart';
import '../../theme/theme_provider.dart';

class ModalAjustes {
  static void mostrar(BuildContext context, VoidCallback onReasignar) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fondoOLED.withOpacity(0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: AppColors.oroSolar.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 30,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: Sp.md),
                    // Pastilla de arrastre
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.oroSolar.withOpacity(0.4),
                        borderRadius: Rad.rPill,
                      ),
                    ),
                    const SizedBox(height: Sp.lg),
                    Text(
                      'AJUSTES DE LA APP',
                      style: AppText.h3.copyWith(
                        color: AppColors.oroSolar,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: Sp.sm),
                    Text(
                      'Personaliza tu experiencia en Allin Kawsay',
                      style: AppText.captionXs.copyWith(color: Colors.white54),
                    ),
                    const SizedBox(height: Sp.lg),

                    // Selector de Tema con chips interactivos
                    Container(
                      padding: const EdgeInsets.all(Sp.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: Rad.rMd,
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'APARIENCIA VISUAL',
                            style: AppText.captionXs.copyWith(
                              color: AppColors.oroSolar,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: Sp.sm),
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: ThemeProvider.mode,
                            builder: (context, modo, _) {
                              return Row(
                                children: [
                                  _ThemeChip(
                                    label: 'Oscuro',
                                    icon: Icons.dark_mode_outlined,
                                    selected: modo == ThemeMode.dark,
                                    onTap: () => ThemeProvider.cambiar(ThemeMode.dark),
                                  ),
                                  const SizedBox(width: Sp.sm),
                                  _ThemeChip(
                                    label: 'Claro',
                                    icon: Icons.light_mode_outlined,
                                    selected: modo == ThemeMode.light,
                                    onTap: () => ThemeProvider.cambiar(ThemeMode.light),
                                  ),
                                  const SizedBox(width: Sp.sm),
                                  _ThemeChip(
                                    label: 'Auto',
                                    icon: Icons.brightness_auto_outlined,
                                    selected: modo == ThemeMode.system,
                                    onTap: () => ThemeProvider.cambiar(ThemeMode.system),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.md),

                    // Opciones de almacenamiento y datos
                    _OpcionTile(
                      icon: Icons.storage_rounded,
                      titulo: 'Almacenamiento y Caché',
                      subtitulo: 'Gestionar espacio de audios y fotos',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GestionCacheScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: Sp.sm),
                    _OpcionTile(
                      icon: Icons.assignment_ind_outlined,
                      titulo: 'Reasignar mis subidas',
                      subtitulo: 'Vincular canciones subidas a mi usuario',
                      onTap: () {
                        Navigator.pop(context);
                        onReasignar();
                      },
                    ),
                    const SizedBox(height: Sp.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppMotion.hapticSelection();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.granateSagrado : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.oroSolar : Colors.white12,
              width: selected ? 1.2 : 0.8,
            ),
            boxShadow: selected ? AppColors.glowDorado(intens: 0.25, blur: 8) : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.oroSolar : Colors.white60,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? AppColors.oroReflejo : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcionTile extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcionTile({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppMotion.hapticLight();
        onTap();
      },
      borderRadius: Rad.rMd,
      child: Container(
        padding: const EdgeInsets.all(Sp.md),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: Rad.rMd,
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.granateSagrado.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.oroSolar.withOpacity(0.35)),
              ),
              child: Icon(icon, color: AppColors.oroSolar, size: 20),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: AppText.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: AppText.captionXs.copyWith(color: Colors.white38),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}
