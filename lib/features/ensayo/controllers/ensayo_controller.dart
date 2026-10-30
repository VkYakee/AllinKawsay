// lib/features/ensayo/controllers/ensayo_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../../models/bloque_audio.dart';
import '../../../models/cancion.dart';
import '../../../models/numerofonia.dart';
import '../../../services/player_service.dart';
import '../../../services/zampona_service.dart';

/// Evento de una nota en el tiempo del bloque.
class EventoEnsayo {
  final int columna;
  final bool esFila7;
  final String idNota;
  final int inicioMs;
  final int finMs;

  const EventoEnsayo({
    required this.columna,
    required this.esFila7,
    required this.idNota,
    required this.inicioMs,
    required this.finMs,
  });
}

/// Controlador único del Modo Ensayo.
///
/// Antes: la lógica de cálculo de timings, la posición del audio,
/// el bloque activo, la celda activa y el karaoke vivían dentro del
/// State del widget. Eso hacía que cada frame de audio disparara un
/// setState que redibujaba TODO el árbol.
///
/// Ahora: todo vive acá. La UI escucha al controller y solo redibuja
/// la parte que cambió (bloque actual, nota sonando, texto karaoke).
class EnsayoController extends ChangeNotifier {
  final Cancion cancion;

  final _player = PlayerService().player;
  final _zampona = ZamponaService();

  late List<BloqueAudio> _bloques;
  late List<EstrofaNumerofonia> _estrofasValidas;

  Duration _pos = Duration.zero;
  Duration? _duracion;
  StreamSubscription<Duration>? _subPos;
  StreamSubscription<Duration?>? _subDur;
  StreamSubscription<ProcessingState>? _subState;

  int _bloqueActual = -1;
  CeldaActiva? _celdaActiva;
  String? _notaSonando;
  String _textoKaraokeActual = '';
  bool _cargando = true;
  double _velocidad = 1.0;
  bool _bucle = true;

  List<EventoEnsayo> _eventosDelBloque = [];
  bool _disposed = false;

  // ─── Getters ────────────────────────────────────────────────
  Duration get pos => _pos;
  Duration? get duracion => _duracion;
  int get bloqueActual => _bloqueActual;
  CeldaActiva? get celdaActiva => _celdaActiva;
  String? get notaSonando => _notaSonando;
  String get textoKaraoke => _textoKaraokeActual;
  bool get cargando => _cargando;
  double get velocidad => _velocidad;
  bool get bucle => _bucle;
  bool get reproduciendo => _player.playing;
  List<BloqueAudio> get bloques => _bloques;

  /// Estrofas a mostrar en la tabla: la del bloque actual, o vacío.
  List<EstrofaNumerofonia> get estrofasAMostrar {
    if (_bloqueActual < 0 || _bloqueActual >= _bloques.length) return [];
    final bloque = _bloques[_bloqueActual];
    if (!bloque.tieneVisual) return [];
    if (bloque.estrofaRef < 0 || bloque.estrofaRef >= _estrofasValidas.length) {
      return [];
    }
    return [_estrofasValidas[bloque.estrofaRef]];
  }

  EnsayoController({required this.cancion}) {
    _bloques = cancion.setlist;
    _estrofasValidas = cancion.estrofas.where((e) => !e.vacia).toList();
    _init();
  }

  Future<void> _init() async {
    await _zampona.init();
    try {
      await _player.stop();
      if (cancion.audioUrl.isEmpty) {
        if (!_disposed) {
          _cargando = false;
          notifyListeners();
        }
        return;
      }

      final tag = MediaItem(
        id: 'ensayo_${cancion.id}',
        title: 'Ensayo: ${cancion.titulo}',
        artist: 'Allin Kawsay',
      );

      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(cancion.audioUrl), tag: tag),
      );

      _subPos = _player.positionStream.listen((p) {
        if (_disposed) return;
        _pos = p;
        _actualizarEstado();
      });

      _subDur = _player.durationStream.listen((d) {
        if (_disposed) return;
        _duracion = d;
        notifyListeners();
      });

      _subState = _player.processingStateStream.listen((s) {
        if (_disposed) return;
        if (s == ProcessingState.completed && _bucle) {
          _player.seek(Duration.zero);
          _player.play();
        }
      });
    } catch (e) {
      debugPrint('EnsayoController: error al cargar audio: $e');
    }
    if (!_disposed) {
      _cargando = false;
      notifyListeners();
    }
  }

  // ─── Cálculo de bloque ──────────────────────────────────────

  int _getBloqueIndex(Duration pos) {
    final ms = pos.inMilliseconds;
    if (_bloques.isEmpty) return -1;
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
      if (necesitaRedibujar) notifyListeners();
      return;
    }

    final bloque = _bloques[idx];
    final msActual = _pos.inMilliseconds;

    // Nota activa
    EventoEnsayo? eventoActual;
    for (final ev in _eventosDelBloque) {
      if (msActual >= ev.inicioMs && msActual < ev.finMs) {
        eventoActual = ev;
        break;
      }
    }

    if (eventoActual != null) {
      if (_notaSonando != eventoActual.idNota) {
        _celdaActiva = CeldaActiva(
          estrofa: 0,
          columna: eventoActual.columna,
          esFila7: eventoActual.esFila7,
          notaIndex: 0,
        );
        _notaSonando = eventoActual.idNota;
        // Tocar la nota real de la zampoña
        _zampona.tocar(eventoActual.idNota);
        necesitaRedibujar = true;
      }
    } else {
      if (_celdaActiva != null) {
        _celdaActiva = null;
        _notaSonando = null;
        necesitaRedibujar = true;
      }
    }

    // Karaoke
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

    if (necesitaRedibujar) notifyListeners();
  }

  void _calcularEventosDelBloque(BloqueAudio bloque) {
    _eventosDelBloque = [];
    if (!bloque.tieneVisual) return;
    if (bloque.estrofaRef < 0 || bloque.estrofaRef >= _estrofasValidas.length) {
      return;
    }
    final estrofa = _estrofasValidas[bloque.estrofaRef];

    List<MapEntry<int, String>> secuenciaNotas = [];
    for (int c = 0; c < estrofa.columnas.length; c++) {
      final col = estrofa.columnas[c];
      for (int i = 0; i < col.nota7.trim().length; i++) {
        final char = col.nota7.trim()[i];
        secuenciaNotas.add(
          MapEntry(c, char == '.' ? 'fila7_.' : 'fila7_$char'),
        );
      }
      for (int i = 0; i < col.nota6.trim().length; i++) {
        final char = col.nota6.trim()[i];
        secuenciaNotas.add(
          MapEntry(c, char == '.' ? 'fila6_.' : 'fila6_$char'),
        );
      }
    }

    List<int> timingsToUse = bloque.timingsMs;
    if (timingsToUse.isEmpty) {
      final currentIndex = _bloques.indexOf(bloque);
      for (int i = currentIndex - 1; i >= 0; i--) {
        if (_bloques[i].estrofaRef == bloque.estrofaRef &&
            _bloques[i].timingsMs.isNotEmpty) {
          timingsToUse = _bloques[i].timingsMs;
          break;
        }
      }
    }

    if (timingsToUse.isEmpty) return;

    final offsetGrabacion = timingsToUse[0];

    for (int i = 0; i < secuenciaNotas.length; i++) {
      if (i >= timingsToUse.length) break;
      final inicio = bloque.inicioMs + (timingsToUse[i] - offsetGrabacion);
      final fin = (i + 1 < timingsToUse.length)
          ? bloque.inicioMs + (timingsToUse[i + 1] - offsetGrabacion)
          : inicio + 2000;

      _eventosDelBloque.add(EventoEnsayo(
        columna: secuenciaNotas[i].key,
        esFila7: secuenciaNotas[i].value.startsWith('fila7'),
        idNota: secuenciaNotas[i].value,
        inicioMs: inicio,
        finMs: fin,
      ));
    }
  }

  // ─── Controles públicos ─────────────────────────────────────

  Future<void> play() async {
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
    await _zampona.detener();
  }

  Future<void> stop() async {
    await _player.pause();
    await _player.seek(Duration.zero);
    await _zampona.detener();
  }

  Future<void> toggleBucle() async {
    _bucle = !_bucle;
    notifyListeners();
  }

  Future<void> setVelocidad(double v) async {
    _velocidad = v;
    await _player.setSpeed(v);
    notifyListeners();
  }

  Future<void> seek(double ms) async {
    await _player.seek(Duration(milliseconds: ms.toInt()));
  }

  @override
  void dispose() {
    _disposed = true;
    _subPos?.cancel();
    _subDur?.cancel();
    _subState?.cancel();
    _player.pause();
    _zampona.detener();
    super.dispose();
  }
}