import 'package:flutter/material.dart';
import '../../models/cancion.dart';
import '../../services/descarga_service.dart';
import '../../services/player_service.dart';
import '../../theme/colors.dart';

class AudioPlayerCompacto extends StatefulWidget {
  final Cancion cancion;
  final bool puedeDescargar;
  final PlayerService player;
  final Future<void> Function() onTogglePlay;
  final Future<void> Function(String url,
      {String? nombre, String mime}) onDescargar;

  const AudioPlayerCompacto({
    super.key,
    required this.cancion,
    required this.puedeDescargar,
    required this.player,
    required this.onTogglePlay,
    required this.onDescargar,
  });

  @override
  State<AudioPlayerCompacto> createState() => _AudioPlayerCompactoState();
}

class _AudioPlayerCompactoState extends State<AudioPlayerCompacto> {
  bool _modoEnsayo = false;

  String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (widget.cancion.audioUrl.isEmpty) {
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
              child: Icon(Icons.music_off,
                  color: AppColors.granate.withOpacity(0.5), size: 20),
            ),
            const SizedBox(width: 12),
            Text('Sin audio subido',
                style: TextStyle(
                    color: onSurface.withOpacity(0.5),
                    fontSize: 13,
                    fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    return ValueListenableBuilder<EstadoPlayer>(
      valueListenable: widget.player.estado,
      builder: (context, estado, _) {
        final esEsta = estado.cancionId == widget.cancion.id;
        final playing = esEsta && estado.playing;
        final cargando = esEsta && estado.cargando;
        final bucle = estado.modoBucle;
        final ab = esEsta && estado.abActivo;

        // Si el usuario cambia de canción, cerramos el modo ensayo.
        if (!esEsta && _modoEnsayo) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _modoEnsayo = false);
          });
        }

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
              // Fila principal
              _filaPrincipal(context, estado, esEsta, playing, cargando),

              // Panel de ensayo (se expande)
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: (_modoEnsayo && esEsta)
                    ? _panelEnsayo(context, estado)
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 8),

              // Barra inferior
              _barraBotones(context, estado, esEsta, bucle, ab),
            ],
          ),
        );
      },
    );
  }
  Widget _filaPrincipal(
    BuildContext context,
    EstadoPlayer estado,
    bool esEsta,
    bool playing,
    bool cargando,
  ) {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onTogglePlay,
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
                    child: CircularProgressIndicator(
                        color: AppColors.granate, strokeWidth: 2.5),
                  )
                : Icon(
                    playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.granate,
                    size: 32,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: esEsta
              ? StreamBuilder<Duration>(
                  stream: widget.player.player.positionStream,
                  builder: (context, snap) {
                    final pos = snap.data ?? Duration.zero;
                    final dur =
                        widget.player.player.duration ?? Duration.zero;
                    final posSec = pos.inMilliseconds.toDouble();
                    final durSec = dur.inMilliseconds
                        .toDouble()
                        .clamp(1.0, 999999999.0);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.dorado,
                            thumbColor: AppColors.dorado,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape:
                                const RoundSliderOverlayShape(
                                    overlayRadius: 14),
                            inactiveTrackColor:
                                AppColors.dorado.withOpacity(0.2),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: posSec.clamp(0.0, durSec),
                            max: durSec,
                            onChanged: (v) => widget.player.player.seek(
                                Duration(milliseconds: v.toInt())),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${_fmt(pos)} / ${_fmt(dur)}',
                            style: TextStyle(
                                color:
                                    AppColors.dorado.withOpacity(0.8),
                                fontSize: 11,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Center(
                  child: Text(
                    'Toca para escuchar',
                    style: TextStyle(
                        color: AppColors.dorado.withOpacity(0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _panelEnsayo(BuildContext context, EstadoPlayer estado) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final ab = estado.abActivo;
    final a = estado.puntoA;
    final b = estado.puntoB;
    const velocidades = [0.5, 0.75, 1.0, 1.25, 1.5];

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dorado.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.dorado.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school,
                      color: AppColors.dorado, size: 14),
                ),
                const SizedBox(width: 8),
                const Text(
                  'MODO ENSAYO',
                  style: TextStyle(
                    color: AppColors.dorado,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                if (ab)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.green.withOpacity(0.6)),
                    ),
                    child: const Text(
                      'A-B',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Fila ⏪ / ▶ / ⏩
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _btnRedondo(
                  icono: Icons.replay_5,
                  onTap: () =>
                      widget.player.saltar(const Duration(seconds: -5)),
                ),
                _btnRedondo(
                  icono: Icons.forward_5,
                  onTap: () =>
                      widget.player.saltar(const Duration(seconds: 5)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Velocidad
            Text(
              'VELOCIDAD · ${estado.velocidad}x',
              style: TextStyle(
                color: AppColors.dorado.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: velocidades.map((v) {
                final activo = estado.velocidad == v;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () => widget.player.cambiarVelocidad(v),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: activo
                              ? AppColors.dorado
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: activo
                                ? AppColors.dorado
                                : AppColors.dorado.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${v}x',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: activo
                                ? AppColors.granate
                                : AppColors.dorado,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Bucle A-B
            Text(
              'BUCLE A-B',
              style: TextStyle(
                color: AppColors.dorado.withOpacity(0.9),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _cajaAB(
                    'A',
                    a == null ? '--:--' : _fmt(a),
                    Colors.green.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _cajaAB(
                    'B',
                    b == null ? '--:--' : _fmt(b),
                    Colors.red.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: FilledButton.icon(
                      onPressed: widget.player.marcarA,
                      icon: const Icon(Icons.play_arrow_rounded, size: 14),
                      label: const Text('MARCAR A',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          )),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: FilledButton.icon(
                      onPressed: widget.player.marcarB,
                      icon: const Icon(Icons.flag_rounded, size: 14),
                      label: const Text('MARCAR B',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          )),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                if (a != null || b != null) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 38,
                    width: 38,
                    child: OutlinedButton(
                      onPressed: widget.player.limpiarAB,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(
                            color: AppColors.dorado.withOpacity(0.6)),
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.dorado),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btnRedondo({
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icono, color: AppColors.dorado, size: 28),
        ),
      ),
    );
  }

  Widget _cajaAB(String letra, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Text(
              letra,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            valor,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _barraBotones(
    BuildContext context,
    EstadoPlayer estado,
    bool esEsta,
    bool bucle,
    bool ab,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _botonControl(
          icono: bucle ? Icons.repeat_one : Icons.repeat,
          label: 'Bucle',
          activo: bucle,
          onTap: () => widget.player.toggleBucle(),
        ),
        if (esEsta)
          _botonControl(
            icono: _modoEnsayo ? Icons.expand_less : Icons.school_outlined,
            label: _modoEnsayo ? 'Cerrar' : 'Ensayo',
            activo: _modoEnsayo || ab,
            onTap: () => setState(() => _modoEnsayo = !_modoEnsayo),
          ),
        if (widget.puedeDescargar)
          _botonControl(
            icono: Icons.download_outlined,
            label: 'Descargar',
            onTap: () => widget.onDescargar(
              widget.cancion.audioUrl,
              nombre: DescargaService.nombreConTimestamp(
                  widget.cancion.titulo, 'mp3'),
              mime: 'audio/mpeg',
            ),
          ),
      ],
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
          color: activo
              ? AppColors.dorado.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activo
                ? AppColors.dorado.withOpacity(0.5)
                : AppColors.dorado.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono,
                color: activo
                    ? AppColors.dorado
                    : AppColors.dorado.withOpacity(0.7),
                size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: activo
                        ? AppColors.dorado
                        : AppColors.dorado.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}