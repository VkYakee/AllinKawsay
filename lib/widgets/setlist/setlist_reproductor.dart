// lib/widgets/setlist/setlist_reproductor.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class SetlistReproductor extends StatelessWidget {
  final Duration posicion;
  final Duration? duracion;
  final bool reproduciendo;
  final VoidCallback onTogglePlay;
  final ValueChanged<double> onSeek;

  const SetlistReproductor({
    super.key,
    required this.posicion,
    required this.duracion,
    required this.reproduciendo,
    required this.onTogglePlay,
    required this.onSeek,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final total = duracion ?? Duration.zero;
    final posSec = posicion.inMilliseconds.toDouble();
    final totalSec = total.inMilliseconds.toDouble().clamp(1.0, 999999999.0);

    return Container(
      padding: const EdgeInsets.all(Sp.md),
      margin: const EdgeInsets.symmetric(horizontal: Sp.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.negro, Color(0xFF2A2A2A)]),
        borderRadius: Rad.rLg,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTogglePlay,
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.gradienteDorado,
                shape: BoxShape.circle,
              ),
              child: Icon(reproduciendo ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.granate, size: 30),
            ),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.dorado,
                    thumbColor: AppColors.dorado,
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: posSec.clamp(0.0, totalSec),
                    max: totalSec,
                    onChanged: onSeek,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(posicion), style: AppType.mono.copyWith(color: AppColors.dorado.withOpacity(0.8), fontSize: 11)),
                    Text(total == Duration.zero ? '--:--' : _fmt(total), style: AppType.mono.copyWith(color: AppColors.dorado.withOpacity(0.5), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}