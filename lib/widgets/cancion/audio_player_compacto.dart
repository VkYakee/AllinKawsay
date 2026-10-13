import 'package:flutter/material.dart';
import '../../models/cancion.dart';
import '../../services/descarga_service.dart';
import '../../services/player_service.dart';
import '../../theme/colors.dart';

class AudioPlayerCompacto extends StatelessWidget {
  final Cancion cancion;
  final bool puedeDescargar;
  final PlayerService player;
  final Future<void> Function() onTogglePlay;
  final Future<void> Function(String url, {String? nombre, String mime}) onDescargar;

  const AudioPlayerCompacto({
    super.key,
    required this.cancion,
    required this.puedeDescargar,
    required this.player,
    required this.onTogglePlay,
    required this.onDescargar,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (cancion.audioUrl.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.dorado.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.music_off, color: AppColors.granate.withOpacity(0.5), size: 20),
            ),
            const SizedBox(width: 12),
            Text('Sin audio subido', style: TextStyle(color: onSurface.withOpacity(0.5), fontSize: 13, fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    return ValueListenableBuilder<EstadoPlayer>(
      valueListenable: player.estado,
      builder: (context, estado, _) {
        final esEsta = estado.cancionId == cancion.id;
        final playing = esEsta && estado.playing;
        final cargando = esEsta && estado.cargando;
        final bucle = estado.modoBucle;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.negro, Color(0xFF2A2A2A)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onTogglePlay,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradienteDorado,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dorado.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: cargando
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(color: AppColors.granate, strokeWidth: 2.5),
                            )
                          : Icon(
                              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: AppColors.granate,
                              size: 32,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: esEsta
                        ? StreamBuilder<Duration>(
                            stream: player.player.positionStream,
                            builder: (context, snap) {
                              final pos = snap.data ?? Duration.zero;
                              final dur = player.player.duration ?? Duration.zero;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: AppColors.dorado,
                                      thumbColor: AppColors.dorado,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                      inactiveTrackColor: AppColors.dorado.withOpacity(0.2),
                                      trackHeight: 3,
                                    ),
                                    child: Slider(
                                      value: pos.inSeconds.toDouble().clamp(0, dur.inSeconds.toDouble().clamp(1, double.infinity)),
                                      max: dur.inSeconds.toDouble().clamp(1, double.infinity),
                                      onChanged: (v) => player.player.seek(Duration(seconds: v.toInt())),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '${_fmt(pos)} / ${_fmt(dur)}',
                                      style: TextStyle(color: AppColors.dorado.withOpacity(0.8), fontSize: 11, letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'Toca para escuchar',
                              style: TextStyle(color: AppColors.dorado.withOpacity(0.6), fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _botonControl(
                    icono: bucle ? Icons.repeat_one : Icons.repeat,
                    label: 'Bucle',
                    activo: bucle,
                    onTap: () => player.toggleBucle(),
                  ),
                  if (puedeDescargar)
                    _botonControl(
                      icono: Icons.download_outlined,
                      label: 'Descargar',
                      onTap: () => onDescargar(
                        cancion.audioUrl,
                        nombre: DescargaService.nombreConTimestamp(cancion.titulo, 'mp3'),
                        mime: 'audio/mpeg',
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _botonControl({
    required IconData icono,
    required String label,
    bool activo = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? AppColors.dorado.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activo ? AppColors.dorado.withOpacity(0.5) : AppColors.dorado.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: activo ? AppColors.dorado : AppColors.dorado.withOpacity(0.7), size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: activo ? AppColors.dorado : AppColors.dorado.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}