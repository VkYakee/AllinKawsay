// lib/features/home/widgets/mini_player.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/audio_visualizer.dart';
import '../../../services/player_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EstadoPlayer>(
      valueListenable: PlayerService().estado,
      builder: (context, estado, _) {
        if (estado.cancionId == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.sm),
          child: ClipRRect(
            borderRadius: Rad.rPill,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.fondoOLED.withOpacity(0.92),
                      AppColors.granateSagrado.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: Rad.rPill,
                  border: Border.all(
                    color: AppColors.oroSolar.withOpacity(0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.oroSolar.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          const SizedBox(width: Sp.sm),
                          // Icono ecualizador temático
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradienteDorado,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.oroSolar.withOpacity(0.45),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: MiniEqualizer(
                                isPlaying: estado.playing,
                                color: AppColors.granateOscuro,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: Sp.md),
                          // Título y estado
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  estado.cancionTitulo ?? 'Reproduciendo',
                                  style: AppText.subtitle.copyWith(
                                    color: AppColors.oroReflejo,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  estado.cargando
                                      ? 'Sincronizando audio...'
                                      : 'C.I.A.C. Allin Kawsay',
                                  style: AppText.captionXs.copyWith(
                                    color: AppColors.oroSolar.withOpacity(0.7),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botón Play / Pause con micro-animación
                          GestureDetector(
                            onTap: () {
                              AppMotion.hapticLight();
                              if (estado.playing) {
                                PlayerService().player.pause();
                              } else {
                                PlayerService().player.play();
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.oroSolar.withOpacity(0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: Icon(
                                estado.playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.oroSolar,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Botón cerrar
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                              size: 18,
                            ),
                            onPressed: () {
                              AppMotion.hapticLight();
                              PlayerService().detener();
                            },
                          ),
                          const SizedBox(width: Sp.xs),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
                      child: AudioVisualizer(
                        isPlaying: estado.playing,
                        color: AppColors.oroSolar.withOpacity(0.4),
                        height: 5,
                        barCount: 36,
                        barWidth: 2,
                        gap: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
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
