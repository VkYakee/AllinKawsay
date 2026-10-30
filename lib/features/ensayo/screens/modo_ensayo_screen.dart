// lib/features/ensayo/screens/modo_ensayo_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/bloque_audio.dart';
import '../../../models/cancion.dart';
import '../../../models/numerofonia.dart';
import '../../../services/player_service.dart';
import '../../../services/zampona_service.dart';
import '../../../widgets/visor_numerofonia.dart';
import '../../../widgets/zampona/tool_scaffold.dart';
import '../widgets/zampona_3d.dart';
import '../widgets/controles_ensayo.dart';

class ModoEnsayoScreen extends StatefulWidget {
  final Cancion cancion;
  const ModoEnsayoScreen({super.key, required this.cancion});

  @override
  State<ModoEnsayoScreen> createState() => _ModoEnsayoScreenState();
}

class _EventoEnsayo {
  final int columna;
  final bool esFila7;
  final String idNota; 
  final int inicioMs;
  final int finMs;
  _EventoEnsayo({required this.columna, required this.esFila7, required this.idNota, required this.inicioMs, required this.finMs});
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
  String _textoKaraokeActual = '';
  
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
      _textoKaraokeActual = '';
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

    _EventoEnsayo? eventoActual;
    for (final ev in _eventosDelBloque) {
      if (msActual >= ev.inicioMs && msActual < ev.finMs) {
        eventoActual = ev;
        break;
      }
    }

    if (eventoActual != null) {
      if (_notaSonando != eventoActual.idNota) {
        _celdaActiva = CeldaActiva(estrofa: 0, columna: eventoActual.columna, esFila7: eventoActual.esFila7, notaIndex: 0);
        _notaSonando = eventoActual.idNota; 
        necesitaRedibujar = true;
      }
    } else {
      if (_celdaActiva != null) {
        _celdaActiva = null;
        _notaSonando = null;
        necesitaRedibujar = true;
      }
    }

    String textoNuevo = '';
    for (final frag in bloque.karaokeFragments) {
      if (msActual >= frag.inicioMs && msActual <= frag.finMs) {
        textoNuevo = frag.texto;
        break;
      }
    }

    if (textoNuevo != _textoKaraokeActual) {
      _textoKaraokeActual = textoNuevo;
      necesitaRedibujar = true;
    }

    if (necesitaRedibujar && mounted) {
      setState(() {});
    }
  }

  void _calcularEventosDelBloque(BloqueAudio bloque) {
    _eventosDelBloque = [];
    if (!bloque.tieneVisual) return;

    final estrofas = widget.cancion.estrofas.where((e) => !e.vacia).toList();
    if (bloque.estrofaRef < 0 || bloque.estrofaRef >= estrofas.length) return;
    final estrofa = estrofas[bloque.estrofaRef];

    List<MapEntry<int, String>> secuenciaNotas = []; 
    for (int c = 0; c < estrofa.columnas.length; c++) {
      final col = estrofa.columnas[c];
      for (int i = 0; i < col.nota7.trim().length; i++) {
        final char = col.nota7.trim()[i];
        secuenciaNotas.add(MapEntry(c, char == '.' ? 'fila7_.' : 'fila7_$char'));
      }
      for (int i = 0; i < col.nota6.trim().length; i++) {
        final char = col.nota6.trim()[i];
        secuenciaNotas.add(MapEntry(c, char == '.' ? 'fila6_.' : 'fila6_$char'));
      }
    }

    List<int> timingsToUse = bloque.timingsMs;
    if (timingsToUse.isEmpty) {
      final currentIndex = _bloques.indexOf(bloque);
      for (int i = currentIndex - 1; i >= 0; i--) {
        if (_bloques[i].estrofaRef == bloque.estrofaRef && _bloques[i].timingsMs.isNotEmpty) {
          timingsToUse = _bloques[i].timingsMs;
          break;
        }
      }
    }

    if (timingsToUse.isEmpty) return;

    // NORMALIZACIÓN: El primer toque grabado se convierte en el inicio (0ms relativo)
    final int offsetGrabacion = timingsToUse[0];

    for (int i = 0; i < secuenciaNotas.length; i++) {
      if (i >= timingsToUse.length) break;
      
      final inicio = bloque.inicioMs + (timingsToUse[i] - offsetGrabacion);
      final fin = (i + 1 < timingsToUse.length) 
          ? bloque.inicioMs + (timingsToUse[i + 1] - offsetGrabacion)
          : inicio + 2000;

      _eventosDelBloque.add(_EventoEnsayo(
        columna: secuenciaNotas[i].key,
        esFila7: secuenciaNotas[i].value.startsWith('fila7'),
        idNota: secuenciaNotas[i].value,
        inicioMs: inicio,
        finMs: fin,
      ));
    }
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
          // 1. TABLA (Ocupa todo el ancho disponible)
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
                    ? Text('Esperando estrofa...', style: AppText.caption.copyWith(color: AppColors.dorado.withOpacity(0.5)))
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
          
          // 2. LETRA SINCRO (Karaoke)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _textoKaraokeActual.isEmpty ? '♪ (Esperando letra...) ♪' : _textoKaraokeActual,
                  key: ValueKey(_textoKaraokeActual),
                  textAlign: TextAlign.center,
                  style: AppText.body.copyWith(color: AppColors.dorado, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),

          // 3. ZAMPOÑA 3D + CONTROLES
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Zampona3D(
                    brillando: _notaSonando != null ? {_notaSonando!} : {},
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