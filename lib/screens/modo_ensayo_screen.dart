import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../data/zampona_catalogo.dart';
import '../models/bloque_audio.dart';
import '../models/cancion.dart';
import '../models/zampona_nota.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';

enum ModoEnsayo { audioUrl, solo7, solo6 }

class ModoEnsayoScreen extends StatefulWidget {
  final Cancion cancion;
  const ModoEnsayoScreen({super.key, required this.cancion});

  @override
  State<ModoEnsayoScreen> createState() => _ModoEnsayoScreenState();
}

class _NotaEnsayable {
  final int estrofa;
  final int columna;
  final bool esFila7;
  final int notaIndex;
  final int delayMs;

  _NotaEnsayable({
    required this.estrofa,
    required this.columna,
    required this.esFila7,
    required this.notaIndex,
    required this.delayMs,
  });
}

class _ModoEnsayoScreenState extends State<ModoEnsayoScreen> {
  final _service = ZamponaService();
  final _player = AudioPlayer();

  bool _cargando = true;
  bool _reproduciendo = false;
  bool _pausa = false;
  bool _bucle = true;
  double _velocidad = 1.0;
  late ModoEnsayo _modo;

  int _estrofaActual = 0;
  _NotaEnsayable? _notaActiva;
  String? _notaSonando;

  Duration _posAudio = Duration.zero;
  Duration? _duracionAudio;
  int _bloqueActual = -1;

  String? _ultimaNotaSonada;

  int _runId = 0;
  StreamSubscription<Duration>? _subPos;

  bool get _puedeAudioUrl => widget.cancion.puedeAudioUrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _modo = _puedeAudioUrl ? ModoEnsayo.audioUrl : ModoEnsayo.solo7;

    _inicializar();
  }

  @override
  void dispose() {
    _runId++;
    _subPos?.cancel();
    _player.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _inicializar() async {
    await _service.init();
    if (_puedeAudioUrl) {
      try {
        final tag = MediaItem(
          id: 'ensayo_${widget.cancion.id}',
          title: widget.cancion.titulo,
          artist: 'Allin Kawsay · Ensayo',
        );

        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(widget.cancion.audioUrl),
            tag: tag,
          ),
        );

        _subPos = _player.positionStream.listen((p) {
          if (mounted) {
            _posAudio = p;
            _actualizarBloqueDesdePosicion();
          }
        });
        _player.durationStream.listen((d) {
          if (mounted) setState(() => _duracionAudio = d);
        });
        _player.playerStateStream.listen((s) {
          if (mounted) setState(() {});
        });
      } catch (e) {
        debugPrint('⚠️ Error al cargar audio: $e');
      }
    }
    if (mounted) setState(() => _cargando = false);
  }

  // ═══════════════════════════════════════════════════════════
  // MODO AUDIO URL
  // ═══════════════════════════════════════════════════════════
  void _actualizarBloqueDesdePosicion() {
    if (_modo != ModoEnsayo.audioUrl) return;
    final bloques = widget.cancion.setlist;
    if (bloques.isEmpty) return;

    final posMs = _posAudio.inMilliseconds;

    int nuevo = -1;
    for (int i = 0; i < bloques.length; i++) {
      if (bloques[i].inicioMs <= posMs) {
        nuevo = i;
      } else {
        break;
      }
    }

    if (nuevo != _bloqueActual) {
      setState(() {
        _bloqueActual = nuevo;
        _notaActiva = null;
        _notaSonando = null;
      });
      if (nuevo >= 0) {
        _calcularColumnaEnBloque(bloques[nuevo], posMs);
      }
    } else if (nuevo >= 0) {
      _calcularColumnaEnBloque(bloques[nuevo], posMs);
    }
  }

  void _calcularColumnaEnBloque(BloqueAudio bloque, int posMs) {
    if (!bloque.tieneVisual) return;

    final estrofas =
        widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (bloque.estrofaRef < 0 || bloque.estrofaRef >= estrofas.length) {
      return;
    }

    final estrofa = estrofas[bloque.estrofaRef];
    final elapsedMs = posMs - bloque.inicioMs;

    int acumulado = 0;
    int colActiva = -1;
    bool esFila7 = true;
    int notaIdx = 0;

    for (int c = 0; c < estrofa.columnas.length; c++) {
      final col = estrofa.columnas[c];

      final n7 = col.nota7.trim();
      for (int i = 0; i < n7.length; i++) {
        final rawDelta = i < col.timings7.length
            ? col.timings7[i]
            : (i == 0 ? 0 : 400);
        final delta = (rawDelta / bloque.velocidad).round();
        acumulado += delta;
        if (acumulado >= elapsedMs) {
          colActiva = c;
          esFila7 = true;
          notaIdx = i;
          break;
        }
      }
      if (colActiva >= 0) break;

      final n6 = col.nota6.trim();
      for (int i = 0; i < n6.length; i++) {
        final rawDelta = i < col.timings6.length
            ? col.timings6[i]
            : 400;
        final delta = (rawDelta / bloque.velocidad).round();
        acumulado += delta;
        if (acumulado >= elapsedMs) {
          colActiva = c;
          esFila7 = false;
          notaIdx = i;
          break;
        }
      }
      if (colActiva >= 0) break;
    }

    if (colActiva < 0) return;

    final nueva = _NotaEnsayable(
      estrofa: bloque.estrofaRef,
      columna: colActiva,
      esFila7: esFila7,
      notaIndex: notaIdx,
      delayMs: 0,
    );

    if (_notaActiva == null ||
        _notaActiva!.columna != nueva.columna ||
        _notaActiva!.esFila7 != nueva.esFila7 ||
        _notaActiva!.notaIndex != nueva.notaIndex ||
        _notaActiva!.estrofa != nueva.estrofa) {
      setState(() {
        _notaActiva = nueva;
        _estrofaActual = bloque.estrofaRef;
      });
    }
  }
// ═══════════════════════════════════════════════════════════
// TIMING B — extracción con GAP entre columnas
// ═══════════════════════════════════════════════════════════
List<_NotaEnsayable> _extraerNotas() {
  final estrofas =
      widget.cancion.estrofas.where((e) => !e.vacia).toList();
  if (estrofas.isEmpty) return [];

  final lista = <_NotaEnsayable>[];
  bool esPrimeraNotaGlobal = true;

  for (int e = 0; e < estrofas.length; e++) {
    final cols = estrofas[e].columnas;

    for (int c = 0; c < cols.length; c++) {
      final col = cols[c];

      final n7 = col.nota7.trim();
      for (int i = 0; i < n7.length; i++) {
        int delay;
        if (i == 0) {
          // Primera nota de la columna.
          final stored = col.timings7.isNotEmpty
              ? col.timings7[0]
              : 0;
          if (esPrimeraNotaGlobal) {
            delay = 0;
          } else {
            // Gap por defecto entre columnas: 400ms si el stored es 0.
            delay = stored > 0 ? stored : 400;
          }
          esPrimeraNotaGlobal = false;
        } else {
          delay = i < col.timings7.length ? col.timings7[i] : 400;
        }
        lista.add(_NotaEnsayable(
          estrofa: e,
          columna: c,
          esFila7: true,
          notaIndex: i,
          delayMs: delay,
        ));
      }

      final n6 = col.nota6.trim();
      for (int i = 0; i < n6.length; i++) {
        int delay;
        if (i == 0) {
          final stored = col.timings6.isNotEmpty
              ? col.timings6[0]
              : 0;
          if (esPrimeraNotaGlobal) {
            delay = 0;
          } else {
            delay = stored > 0 ? stored : 400;
          }
          esPrimeraNotaGlobal = false;
        } else {
          delay = i < col.timings6.length ? col.timings6[i] : 400;
        }
        lista.add(_NotaEnsayable(
          estrofa: e,
          columna: c,
          esFila7: false,
          notaIndex: i,
          delayMs: delay,
        ));
      }
    }
  }

  return lista;
}

String _caracterDe(_NotaEnsayable n) {
  final estrofas =
      widget.cancion.estrofas.where((e) => !e.vacia).toList();
  if (n.estrofa >= estrofas.length) return '';
  final cols = estrofas[n.estrofa].columnas;
  if (n.columna >= cols.length) return '';
  final texto =
      n.esFila7 ? cols[n.columna].nota7 : cols[n.columna].nota6;
  final limpio = texto.trim();
  if (n.notaIndex >= limpio.length) return '';
  return limpio[n.notaIndex];
}

ZamponaNota? _zamponaDe(String caracter, bool esFila7) {
  if (caracter == '.' || caracter.isEmpty) return null;
  final pos = int.tryParse(caracter);
  if (pos == null || pos < 1) return null;
  final id = esFila7 ? 'fila7_$pos' : 'fila6_$pos';
  for (final n in zamponaNotas) {
    if (n.id == id) return n;
  }
  return null;
}

bool _debeSonar(bool esFila7) {
  switch (_modo) {
    case ModoEnsayo.audioUrl:
      return false;
    case ModoEnsayo.solo7:
      return esFila7;
    case ModoEnsayo.solo6:
      return !esFila7;
  }
}

// ═══════════════════════════════════════════════════════════
// LOOP DE REPRODUCCIÓN — FIX de desync y pop
// ═══════════════════════════════════════════════════════════
Future<void> _reproducir() async {
  final id = ++_runId;
  setState(() {
    _reproduciendo = true;
    _pausa = false;
    _ultimaNotaSonada = null;
  });

  final notas = _extraerNotas();
  if (notas.isEmpty) {
    if (mounted) setState(() => _reproduciendo = false);
    return;
  }

  while (true) {
    if (id != _runId) return;

    for (final n in notas) {
      if (id != _runId) return;

      while (_pausa && id == _runId) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (id != _runId) return;

      // Delay ANTES de tocar (así el próximo toque cae en el momento justo).
      final delay = (n.delayMs / _velocidad).round();
      if (delay > 0) {
        await Future.delayed(Duration(milliseconds: delay));
        if (id != _runId) return;
      }

      final caracter = _caracterDe(n);
      final nota = _zamponaDe(caracter, n.esFila7);

      // Caso: nota no tocable (punto, fuera de rango)
      if (nota == null) {
        if (_ultimaNotaSonada != null) {
          final anterior = _ultimaNotaSonada!;
          _ultimaNotaSonada = null;
          // FIX: stop instantáneo, no fade.
          unawaited(_service.detenerNota(anterior));
        }
        if (mounted) {
          setState(() {
            _estrofaActual = n.estrofa;
            _notaActiva = n;
            _notaSonando = null;
          });
        }
        continue;
      }

      final debeSonar = _debeSonar(n.esFila7);

      // FIX: parar la nota anterior ANTES de arrancar la nueva,
      // y hacerlo sin await (fire-and-forget). Así no hay overlap
      // de audio y no hay pop.
      if (_ultimaNotaSonada != null &&
          _ultimaNotaSonada != nota.id) {
        unawaited(_service.detenerNota(_ultimaNotaSonada!));
        _ultimaNotaSonada = null;
      }

      // FIX: NO await en tocar(). Fire-and-forget.
      // Así el loop no acumula 50ms de latencia por nota.
      if (debeSonar) {
        unawaited(_service.tocar(nota.id));
        _ultimaNotaSonada = nota.id;
      }

      // Actualizar visual combinado en 1 solo setState.
      if (mounted) {
        setState(() {
          _estrofaActual = n.estrofa;
          _notaActiva = n;
          _notaSonando = nota.id;
        });
      }

      final brilloMs = (260 / _velocidad).round().clamp(80, 800);
      Future.delayed(Duration(milliseconds: brilloMs), () {
        if (mounted && id == _runId) {
          setState(() => _notaSonando = null);
        }
      });
    }

    // ═══ FIN DE UNA VUELTA ═══
    // FIX: fade-out de la última nota para que no suene larga
    // mientras el bucle arranca de nuevo (o mientras se detiene).
    if (_ultimaNotaSonada != null) {
      unawaited(_service.fadeOutNota(_ultimaNotaSonada!));
      _ultimaNotaSonada = null;
    }

    if (!_bucle) break;

    await Future.delayed(
        Duration(milliseconds: (700 / _velocidad).round()));
  }

  if (mounted && id == _runId) {
    setState(() {
      _reproduciendo = false;
      _notaActiva = null;
      _notaSonando = null;
    });
  }
}

void _pausar() => setState(() => _pausa = true);
void _reanudar() => setState(() => _pausa = false);

void _detener() {
  _runId++;
  final ultima = _ultimaNotaSonada;
  _ultimaNotaSonada = null;
  setState(() {
    _reproduciendo = false;
    _pausa = false;
    _notaActiva = null;
    _notaSonando = null;
  });
  if (ultima != null) {
    unawaited(_service.fadeOutNota(ultima));
  }
  Future.delayed(const Duration(milliseconds: 250), () {
    _service.detener();
  });
}

void _reiniciar() {
  _detener();
  Future.delayed(const Duration(milliseconds: 300), () {
    if (mounted) _reproducir();
  });
}

// ═══════════════════════════════════════════════════════════
// AUDIO URL CONTROLES
// ═══════════════════════════════════════════════════════════
bool get _audioReproduciendo =>
    _modo == ModoEnsayo.audioUrl &&
    _player.playerState.playing &&
    _player.processingState != ProcessingState.completed;

Future<void> _toggleAudioPlay() async {
  if (_modo != ModoEnsayo.audioUrl) return;
  if (_audioReproduciendo) {
    await _player.pause();
  } else {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }
}

Future<void> _seekAudio(Duration d) async {
  if (_modo != ModoEnsayo.audioUrl) return;
  await _player.seek(d);
  _posAudio = d;
  _actualizarBloqueDesdePosicion();
}

String _fmtDur(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
// ═══════════════════════════════════════════════════════════
// BUILD
// ═══════════════════════════════════════════════════════════
@override
Widget build(BuildContext context) {
  if (_cargando) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.dorado),
      ),
    );
  }

  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Column(
        children: [
          _barraSuperior(),
          const SizedBox(height: 4),
          _filaModos(),
          const SizedBox(height: 4),
          if (_modo != ModoEnsayo.audioUrl) ...[
            _filaVelocidad(),
            const SizedBox(height: 4),
          ],
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14080A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.4)),
                    ),
                    child: SingleChildScrollView(
                      child: _tablaCompleta(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4),
                    child: _zamponaMini(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (_modo == ModoEnsayo.audioUrl)
            _controlesAudio()
          else
            _controles(),
          const SizedBox(height: 6),
        ],
      ),
    ),
  );
}

Widget _barraSuperior() {
  final ensayando = _modo == ModoEnsayo.audioUrl
      ? _audioReproduciendo
      : _reproduciendo;

  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.dorado),
          onPressed: () {
            _detener();
            _player.pause();
            Navigator.pop(context);
          },
          tooltip: 'Salir',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.cancion.titulo,
            style: const TextStyle(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (ensayando)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent),
            ),
            child: const Text(
              '● ENSAYANDO',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _filaModos() {
  final modos = <(ModoEnsayo, String, IconData, Color)>[
    if (_puedeAudioUrl)
      (ModoEnsayo.audioUrl, 'Audio', Icons.headphones,
          Colors.purpleAccent),
    (ModoEnsayo.solo7, 'Solo 7', Icons.arrow_upward, Colors.green),
    (ModoEnsayo.solo6, 'Solo 6', Icons.arrow_downward, Colors.blueAccent),
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        for (final m in modos)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _chipModo(
                label: m.$2,
                icono: m.$3,
                color: m.$4,
                activo: _modo == m.$1,
                onTap: () => _cambiarModo(m.$1),
              ),
            ),
          ),
      ],
    ),
  );
}

Future<void> _cambiarModo(ModoEnsayo nuevo) async {
  if (_reproduciendo) _detener();
  if (_modo == ModoEnsayo.audioUrl && nuevo != ModoEnsayo.audioUrl) {
    await _player.pause();
  }
  setState(() {
    _modo = nuevo;
    _notaActiva = null;
    _notaSonando = null;
    _bloqueActual = -1;
  });
}

Widget _chipModo({
  required String label,
  required IconData icono,
  required Color color,
  required bool activo,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        gradient: activo
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.95),
                  color.withOpacity(0.55),
                ],
              )
            : null,
        color: activo ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activo ? color : color.withOpacity(0.3),
          width: activo ? 1.8 : 1.2,
        ),
        boxShadow: activo
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono,
              size: 14,
              color: activo ? Colors.white : color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: activo ? Colors.white : color.withOpacity(0.9),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _filaVelocidad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.speed, color: AppColors.dorado, size: 14),
          const SizedBox(width: 6),
          Text(
            '${_velocidad.toStringAsFixed(2)}x',
            style: const TextStyle(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.dorado,
                thumbColor: AppColors.dorado,
                inactiveTrackColor: AppColors.dorado.withOpacity(0.2),
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                min: 0.25,
                max: 2.0,
                divisions: 35,
                value: _velocidad,
                onChanged: (v) => setState(() => _velocidad = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tablaCompleta() {
    final estrofas =
        widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (estrofas.isEmpty) return const SizedBox.shrink();

    CeldaActiva? activa;
    if (_notaActiva != null) {
      activa = CeldaActiva(
        estrofa: _notaActiva!.estrofa,
        columna: _notaActiva!.columna,
        esFila7: _notaActiva!.esFila7,
        notaIndex: _notaActiva!.notaIndex,
      );
    }

    return VisorNumerofonia(
      estrofas: estrofas,
      escala: 0.85,
      celdaActiva: activa,
    );
  }

  Widget _controles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_reproduciendo)
            _botonControl(
              icono: Icons.play_arrow,
              label: 'REPRODUCIR',
              color: Colors.green,
              filled: true,
              onTap: _reproducir,
            )
          else if (_pausa)
            _botonControl(
              icono: Icons.play_arrow,
              label: 'REANUDAR',
              color: Colors.green,
              filled: true,
              onTap: _reanudar,
            )
          else
            _botonControl(
              icono: Icons.pause,
              label: 'PAUSA',
              color: Colors.orange,
              filled: true,
              onTap: _pausar,
            ),
          const SizedBox(width: 6),
          _botonControl(
            icono: Icons.restart_alt,
            label: 'REINICIAR',
            color: AppColors.dorado,
            onTap: _reiniciar,
          ),
          const SizedBox(width: 6),
          _botonControl(
            icono: _bucle ? Icons.repeat_one : Icons.repeat,
            label: 'BUCLE',
            color: AppColors.dorado,
            activo: _bucle,
            onTap: () => setState(() => _bucle = !_bucle),
          ),
          const SizedBox(width: 6),
          _botonControl(
            icono: Icons.stop,
            label: 'DETENER',
            color: Colors.redAccent,
            onTap: _detener,
          ),
        ],
      ),
    );
  }

  Widget _controlesAudio() {
    final total = _duracionAudio ?? Duration.zero;
    final posSec = _posAudio.inMilliseconds.toDouble();
    final totalSec =
        total.inMilliseconds.toDouble().clamp(1.0, 999999999.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _audioReproduciendo
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: AppColors.dorado,
              size: 32,
            ),
            onPressed: _toggleAudioPlay,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.dorado,
                thumbColor: AppColors.dorado,
                inactiveTrackColor: AppColors.dorado.withOpacity(0.2),
                trackHeight: 4,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 15),
              ),
              child: Slider(
                value: posSec.clamp(0.0, totalSec),
                max: totalSec,
                onChanged: (v) =>
                    _seekAudio(Duration(milliseconds: v.toInt())),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 4),
            child: Text(
              '${_fmtDur(_posAudio)} / '
              '${total == Duration.zero ? '--:--' : _fmtDur(total)}',
              style: TextStyle(
                color: AppColors.dorado.withOpacity(0.85),
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonControl({
    required IconData icono,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
    bool activo = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: filled
                ? color.withOpacity(0.22)
                : (activo
                    ? color.withOpacity(0.28)
                    : Colors.white.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color
                  .withOpacity(filled || activo ? 0.8 : 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: color, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 9.5,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ZAMPOÑA
  // ═══════════════════════════════════════════════════════════
  Widget _zamponaMini() {
    return LayoutBuilder(
      builder: (context, cons) {
        const separacion = 3.0;
        final disponible = cons.maxWidth - (separacion * 6) - 24;
        final maxPorAltura = (cons.maxHeight - 20) / 2.2;
        final diametroBase = disponible / 7;
        final diametro = diametroBase < maxPorAltura
            ? diametroBase
            : maxPorAltura;

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final nota in notasFila7)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: separacion / 2),
                      child: _tubo(nota, diametro),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 8,
                width: diametro * 7 + separacion * 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A0308),
                      AppColors.granateOscuro,
                      Color(0xFF2A0308),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: AppColors.dorado.withOpacity(0.35),
                    width: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final nota in notasFila6)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: separacion / 2),
                      child: _tubo(nota, diametro),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String? _idCaniaBrillando() {
    if (_modo == ModoEnsayo.audioUrl) {
      if (_notaActiva == null) return null;
      final caracter = _caracterDe(_notaActiva!);
      final nota = _zamponaDe(caracter, _notaActiva!.esFila7);
      return nota?.id;
    }
    return _notaSonando;
  }

  Widget _tubo(ZamponaNota nota, double diametro) {
    final brillando = _idCaniaBrillando() == nota.id;

    return AnimatedScale(
      scale: brillando ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        width: diametro,
        height: diametro,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: brillando
                ? [
                    const Color(0xFF0A0103),
                    const Color(0xFF1A0205),
                    AppColors.granate,
                    AppColors.dorado,
                  ]
                : [
                    const Color(0xFF0A0103),
                    const Color(0xFF1A0205),
                    const Color(0xFF3A0810),
                    AppColors.granateClaro,
                  ],
            stops: const [0.0, 0.35, 0.78, 1.0],
          ),
          border: Border.all(
            color: brillando
                ? AppColors.dorado
                : AppColors.dorado.withOpacity(0.35),
            width: brillando ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.85),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
            if (brillando)
              BoxShadow(
                color: AppColors.dorado.withOpacity(0.7),
                blurRadius: 16,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Center(
          child: Text(
            '${nota.posicion}',
            style: TextStyle(
              color: brillando
                  ? AppColors.dorado
                  : AppColors.dorado.withOpacity(0.6),
              fontWeight: FontWeight.bold,
              fontSize: diametro * 0.32,
              height: 1.0,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.9),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}