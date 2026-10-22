// lib/widgets/ensayo/ensayo_controles.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class EnsayoControles extends StatelessWidget {
  final bool reproduciendo;
  final bool pausa;
  final bool bucle;
  final double velocidad;
  final bool esModoAudio;
  final bool audioReproduciendo;
  final double audioPos;
  final double audioTotal;
  final VoidCallback onPlay;
  final VoidCallback onPausa;
  final VoidCallback onReset;
  final VoidCallback onDetener;
  final VoidCallback onToggleBucle;
  final ValueChanged<double> onVelocidad;
  final VoidCallback onAudioPlay;
  final ValueChanged<double> onAudioSeek;

  const EnsayoControles({
    super.key,
    required this.reproduciendo,
    required this.pausa,
    required this.bucle,
    required this.velocidad,
    required this.esModoAudio,
    required this.audioReproduciendo,
    required this.audioPos,
    required this.audioTotal,
    required this.onPlay,
    required this.onPausa,
    required this.onReset,
    required this.onDetener,
    required this.onToggleBucle,
    required this.onVelocidad,
    required this.onAudioPlay,
    required this.onAudioSeek,
  });

  @override
  Widget build(BuildContext context) {
    if (esModoAudio) return _audioControls(context);
    return _zampoControls(context);
  }

  Widget _audioControls(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(audioReproduciendo ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.dorado, size: 32),
          onPressed: onAudioPlay,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: AppColors.dorado, thumbColor: AppColors.dorado, trackHeight: 3),
            child: Slider(
              value: audioPos.clamp(0, audioTotal),
              max: audioTotal > 0 ? audioTotal : 1,
              onChanged: onAudioSeek,
            ),
          ),
        ),
      ],
    );
  }

  Widget _zampoControls(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.speed, color: AppColors.dorado, size: 16),
            const SizedBox(width: Sp.sm),
            Text('${velocidad.toStringAsFixed(2)}x', style: AppType.labelXs.copyWith(color: AppColors.dorado)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(activeTrackColor: AppColors.dorado, thumbColor: AppColors.dorado, trackHeight: 2),
                child: Slider(min: 0.25, max: 2.0, divisions: 35, value: velocidad, onChanged: onVelocidad),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (!reproduciendo) _btn(Icons.play_arrow, 'PLAY', Colors.green, onPlay)
            else if (pausa) _btn(Icons.play_arrow, 'SEGUIR', Colors.green, onPlay)
            else _btn(Icons.pause, 'PAUSA', Colors.orange, onPausa),
            _btn(Icons.restart_alt, 'RESET', AppColors.dorado, onReset),
            _btn(bucle ? Icons.repeat_one : Icons.repeat, 'BUCLE', bucle ? AppColors.dorado : Colors.grey, onToggleBucle),
            _btn(Icons.stop, 'STOP', Colors.redAccent, onDetener),
          ],
        ),
      ],
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: Rad.rMd,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            Text(label, style: AppType.labelXs.copyWith(color: color, fontSize: 8)),
          ],
        ),
      ),
    );
  }
}