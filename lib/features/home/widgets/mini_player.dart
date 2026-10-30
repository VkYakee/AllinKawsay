// lib/features/home/widgets/mini_player.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
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
            borderRadius: Rad.rLg,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.granateOscuro.withOpacity(0.92),
                  borderRadius: Rad.rLg,
                  border: Border.all(
                    color: AppColors.dorado.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.granate.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          const SizedBox(width: Sp.md),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradienteDorado,
                              borderRadius: Rad.rSm,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.dorado.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: MiniEqualizer(
                                isPlaying: estado.playing,
                                color: AppColors.granate,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: Sp.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  estado.cancionTitulo ?? 'Reproduciendo',
                                  style: AppText.subtitle.copyWith(
                                    color: AppColors.dorado,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  estado.cargando
                                      ? 'Cargando...'
                                      : 'Allin Kawsay',
                                  style: AppText.captionXs.copyWith(
                                    color: AppColors.dorado.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              estado.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.dorado,
                              size: 30,
                            ),
                            onPressed: () {
                              if (estado.playing) {
                                PlayerService().player.pause();
                              } else {
                                PlayerService().player.play();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                              size: 20,
                            ),
                            onPressed: () => PlayerService().detener(),
                          ),
                          const SizedBox(width: Sp.sm),
                        ],
                      ),
                    ),
                    AudioVisualizer(
                      isPlaying: estado.playing,
                      color: AppColors.dorado.withOpacity(0.45),
                      height: 8,
                      barCount: 44,
                      barWidth: 2,
                      gap: 2,
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