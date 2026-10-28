// lib/widgets/ensayo/controles_ensayo.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class ControlesEnsayo extends StatelessWidget {
  final bool reproduciendo;
  final double velocidad;
  final bool bucle;
  final double posMs;
  final double totalMs;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback onToggleBucle;
  final ValueChanged<double> onVelocidad;
  final ValueChanged<double> onSeek;

  const ControlesEnsayo({
    super.key,
    required this.reproduciendo,
    required this.velocidad,
    required this.bucle,
    required this.posMs,
    required this.totalMs,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onToggleBucle,
    required this.onVelocidad,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: Rad.rLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: Rad.rLg,
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(reproduciendo ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.dorado, size: 36),
                    onPressed: reproduciendo ? onPause : onPlay,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.dorado,
                        thumbColor: AppColors.dorado,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(value: posMs.clamp(0, totalMs), max: totalMs > 0 ? totalMs : 1, onChanged: onSeek),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.stop, color: Colors.redAccent, size: 20), onPressed: onStop),
                  IconButton(
                    icon: Icon(bucle ? Icons.repeat_one : Icons.repeat, color: bucle ? AppColors.dorado : Colors.white54, size: 20),
                    onPressed: onToggleBucle,
                  ),
                  const SizedBox(width: Sp.sm),
                  const Icon(Icons.speed, color: AppColors.dorado, size: 16),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.dorado,
                        thumbColor: AppColors.dorado,
                        trackHeight: 2,
                      ),
                      child: Slider(min: 0.5, max: 1.5, divisions: 10, value: velocidad, onChanged: onVelocidad),
                    ),
                  ),
                  Text('${velocidad.toStringAsFixed(1)}x', style: AppType.captionXs.copyWith(color: AppColors.dorado)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}