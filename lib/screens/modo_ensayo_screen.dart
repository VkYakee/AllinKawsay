// lib/screens/modo_ensayo_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../design/design.dart';
import '../models/bloque_audio.dart';
import '../models/cancion.dart';
import '../models/numerofonia.dart';
import '../services/player_service.dart';
import '../services/zampona_service.dart';
import '../theme/colors.dart';
import '../widgets/visor_numerofonia.dart';
import '../widgets/ensayo/letra_sincronizada.dart';
import '../widgets/ensayo/controles_ensayo.dart';
import '../widgets/zampona/tool_scaffold.dart';
import '../widgets/zampona/zampona_widget.dart';

class ModoEnsayoScreen extends StatefulWidget {
  final Cancion cancion;
  const ModoEnsayoScreen({super.key, required this.cancion});

  @override
  State<ModoEnsayoScreen> createState() => _ModoEnsayoScreenState();
}

class _EventoEnsayo {
  final int columna;
  final bool esFila7;
  final int inicioMs;
  final int finMs;
  _EventoEnsayo({required this.columna, required this.esFila7, required this.inicioMs, required this.finMs});
}

class _ModoEnsayoScreenState extends State<ModoEnsayoScreen> {
  final _player = PlayerService().player;
  final _service = ZamponaService();
  bool _cargando = true;
  double _velocidad = 1.0;
  bool _bucle = true;
  int _bloqueActual = -1;
  
  CeldaActiva? _celdaActiva;
  String? _notaSonando;
  int _lineaLetraActiva = 0;
  
  late List<BloqueAudio> _bloques;
  List<_EventoEnsayo> _eventosDelBloque = [];
  Duration _pos = Duration.zero;
  Duration? _duracion;
  StreamSubscription<Duration>? _subPos;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _bloques = widget.cancion.setlist;
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    try {
      await _player.stop();
      if (widget.cancion.audioUrl.isNotEmpty) {
        final tag = MediaItem(id: 'ensayo_${widget.cancion.id}', title: 'Ensayo: ${widget.cancion.titulo}', artist: 'Allin Kawsay');
        await _player.setAudioSource(AudioSource.uri(Uri.parse(widget.cancion.audioUrl), tag: tag));
        
        _subPos = _player.positionStream.listen((p) {
          _pos = p;
          _actualizarEstado();
        });
        _player.durationStream.listen((d) { if (mounted) setState(() => _duracion = d); });
      }
    } catch (e) {
      debugPrint('Error al cargar audio: $e');
    }
    if (mounted) setState(() => _cargando = false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _subPos?.cancel();
    _player.pause();
    _service.detener();
    super.dispose();
  }

  int _getBloqueIndex(Duration pos) {
    final ms = pos.inMilliseconds;
    for (int i = 0; i < _bloques.length; i++) {
      if (_bloques[i].inicioMs <= ms) {
        if (i == _bloques.length - 1) return i;
        if (_bloques[i + 1].inicioMs > ms) return i;
      }
    }
    return -1;
  }

  void _actualizarEstado() {
    if (_bloques.isEmpty) return;
    final idx = _getBloqueIndex(_pos);
    
    bool necesitaRedibujar = false;

    if (idx != _bloqueActual) {
      _bloqueActual = idx;
      _celdaActiva = null;
      _notaSonando = null;
      _lineaLetraActiva = 0;
      necesitaRedibujar = true;
      if (idx >= 0) {
        _calcularEventosDelBloque(_bloques[idx]);
      } else {
        _eventosDelBloque = [];
      }
    }

    if (idx < 0) {
      if (necesitaRedibujar && mounted) setState(() {});
      return;
    }

    final bloque = _bloques[idx];
    final msActual = _pos.inMilliseconds;

    // 1. Detectar casilla activa
    _EventoEnsayo? eventoActual;
    for (final ev in _eventosDelBloque) {
      if (msActual >= ev.inicioMs && msActual < ev.finMs) {
        eventoActual = ev;
        break;
      }
    }

    if (eventoActual != null) {
      if (_celdaActiva?.columna != eventoActual.columna || _celdaActiva?.esFila7 != eventoActual.esFila7) {
        _celdaActiva = CeldaActiva(estrofa: 0, columna: eventoActual.columna, esFila7: eventoActual.esFila7, notaIndex: 0);
        _notaSonando = eventoActual.esFila7 ? 'fila7_1' : 'fila6_1'; // Simulación visual
        necesitaRedibujar = true;
      }
    } else {
      if (_celdaActiva != null) {
        _celdaActiva = null;
        _notaSonando = null;
        necesitaRedibujar = true;
      }
    }

    // 2. Detectar línea de letra
    if (bloque.conLetra && bloque.letraTimingsMs.isNotEmpty) {
      int linea = 0;
      for (int i = 0; i < bloque.letraTimingsMs.length; i++) {
        if (msActual >= bloque.letraTimingsMs[i]) {
          linea = i;
        } else {
          break;
        }
      }
      if (linea != _lineaLetraActiva) {
        _lineaLetraActiva = linea;
        necesitaRedibujar = true;
      }
    }

    if (necesitaRedibujar && mounted) {
      setState(() {});
    }
  }

  void _calcularEventosDelBloque(BloqueAudio bloque) {
    _eventosDelBloque = [];
    if (!bloque.tieneVisual || bloque.timingsMs.isEmpty) return;

    final estrofas = widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (bloque.estrofaRef < 0 || bloque.estrofaRef >= estrofas.length) return;
    final estrofa = estrofas[bloque.estrofaRef];

    // Creamos una lista plana de qué columna y fila toca cada nota
    List<MapEntry<int, bool>> secuenciaNotas = []; // Key = Columna, Value = EsFila7
    for (int c = 0; c < estrofa.columnas.length; c++) {
      final col = estrofa.columnas[c];
      for (int i = 0; i < col.nota7.trim().length; i++) {
        secuenciaNotas.add(MapEntry(c, true));
      }
      for (int i = 0; i < col.nota6.trim().length; i++) {
        secuenciaNotas.add(MapEntry(c, false));
      }
    }

    // Emparejamos la secuencia con los timings guardados
    for (int i = 0; i < secuenciaNotas.length; i++) {
      if (i >= bloque.timingsMs.length) break;
      
      final inicio = bloque.timingsMs[i];
      final fin = (i + 1 < bloque.timingsMs.length) 
          ? bloque.timingsMs[i + 1] 
          : inicio + 400; // Si es la última nota, dura 400ms por defecto

      _eventosDelBloque.add(_EventoEnsayo(
        columna: secuenciaNotas[i].key,
        esFila7: secuenciaNotas[i].value,
        inicioMs: inicio,
        finMs: fin,
      ));
    }
  }

  String get _letraActual {
    final b = _bloqueActual >= 0 && _bloqueActual < _bloques.length ? _bloques[_bloqueActual] : null;
    if (b == null || !b.conLetra || !widget.cancion.tieneLetra) return '';
    final lineas = widget.cancion.letras.first.texto.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lineas.isEmpty) return '';
    return lineas[_lineaLetraActiva.clamp(0, lineas.length - 1)];
  }

  List<EstrofaNumerofonia> get _estrofasAMostrar {
    if (_bloqueActual < 0 || _bloqueActual >= _bloques.length) return [];
    final bloque = _bloques[_bloqueActual];
    if (!bloque.tieneVisual) return [];
    final estrofas = widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (bloque.estrofaRef < 0 || bloque.estrofaRef >= estrofas.length) return [];
    return [estrofas[bloque.estrofaRef]];
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: AppColors.dorado)));

    return ToolScaffold(
      titulo: widget.cancion.titulo,
      subtitulo: 'Modo Ensayo con Audio',
      onCerrar: () { _player.pause(); Navigator.pop(context); },
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(Sp.sm),
              padding: const EdgeInsets.all(Sp.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF14080A),
                borderRadius: Rad.rMd,
                border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
              ),
              child: Center(
                child: _estrofasAMostrar.isEmpty
                    ? Text('Esperando estrofa...', style: AppType.caption.copyWith(color: AppColors.dorado.withOpacity(0.5)))
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: VisorNumerofonia(
                          estrofas: _estrofasAMostrar,
                          escala: 1.2,
                          fondoOscuro: true,
                          celdaActiva: _celdaActiva,
                        ),
                      ),
              ),
            ),
          ),
          
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _letraActual.isEmpty ? '♪ (Sin letra en este bloque) ♪' : _letraActual,
                  key: ValueKey(_letraActual),
                  textAlign: TextAlign.center,
                  style: AppType.body.copyWith(color: AppColors.dorado, fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: ZamponaWidget(
                    brillando: _notaSonando != null ? {_notaSonando!} : {}, 
                    onTapNota: null,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(Sp.sm),
                    child: ControlesEnsayo(
                      reproduciendo: _player.playing,
                      velocidad: _velocidad,
                      bucle: _bucle,
                      posMs: _pos.inMilliseconds.toDouble(),
                      totalMs: (_duracion?.inMilliseconds ?? 1).toDouble(),
                      onPlay: () async {
                        if (_player.processingState == ProcessingState.completed) await _player.seek(Duration.zero);
                        _player.play();
                      },
                      onPause: () => _player.pause(),
                      onStop: () { _player.pause(); _player.seek(Duration.zero); },
                      onToggleBucle: () => setState(() => _bucle = !_bucle),
                      onVelocidad: (v) { setState(() => _velocidad = v); _player.setSpeed(v); },
                      onSeek: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}