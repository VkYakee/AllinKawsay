import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/cancion.dart';

class EstadoPlayer {
  final String? cancionId;
  final bool playing;
  final bool cargando;
  final bool modoBucle;
  final double velocidad;
  final Duration? puntoA;
  final Duration? puntoB;

  const EstadoPlayer({
    this.cancionId,
    this.playing = false,
    this.cargando = false,
    this.modoBucle = false,
    this.velocidad = 1.0,
    this.puntoA,
    this.puntoB,
  });

  bool get abActivo => puntoA != null && puntoB != null;
}

class PlayerService {
  static final PlayerService _instance = PlayerService._();
  factory PlayerService() => _instance;

  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<EstadoPlayer> estado =
      ValueNotifier(const EstadoPlayer());

  String? _cancionId;
  bool _playing = false;
  bool _cargando = false;
  bool _bucle = false;
  double _velocidad = 1.0;
  Duration? _puntoA;
  Duration? _puntoB;
  bool _seekingLoop = false;

  PlayerService._() {
    player.playerStateStream.listen((s) {
      _playing = s.playing;
      _cargando = s.processingState == ProcessingState.loading ||
          s.processingState == ProcessingState.buffering;
      _notificar();
    });

    // Bucle A-B manual: si la posición supera el punto B, vuelve al A.
    player.positionStream.listen((pos) {
      if (_seekingLoop) return;
      if (_puntoA == null || _puntoB == null) return;
      if (pos < _puntoB!) return;
      _seekingLoop = true;
      player.seek(_puntoA!).then((_) {
        _seekingLoop = false;
      }).catchError((_) {
        _seekingLoop = false;
      });
    });
  }

  void _notificar() {
    estado.value = EstadoPlayer(
      cancionId: _cancionId,
      playing: _playing,
      cargando: _cargando,
      modoBucle: _bucle,
      velocidad: _velocidad,
      puntoA: _puntoA,
      puntoB: _puntoB,
    );
  }

  Future<void> toggle(Cancion c) async {
    if (c.audioUrl.isEmpty) return;

    if (_cancionId == c.id) {
      if (_playing) {
        await player.pause();
      } else {
        await player.play();
      }
      return;
    }

    try {
      _cancionId = c.id;
      _cargando = true;
      _notificar();

      // Resetear ajustes al cambiar de canción
      _velocidad = 1.0;
      _puntoA = null;
      _puntoB = null;
      _bucle = false;

      await player.setAudioSource(AudioSource.uri(
        Uri.parse(c.audioUrl),
        tag: MediaItem(
          id: c.id,
          album: 'Allin Kawsay',
          title: c.titulo,
          artist: c.autor.isNotEmpty ? c.autor : 'Anónimo',
          artUri: c.imagenUrl.isNotEmpty ? Uri.parse(c.imagenUrl) : null,
        ),
      ));
      await player.setSpeed(1.0);
      await player.setLoopMode(LoopMode.off);
      await player.play();
    } catch (e) {
      _cancionId = null;
      _cargando = false;
      _notificar();
    }
  }

  Future<void> toggleBucle() async {
    _bucle = !_bucle;
    await player.setLoopMode(_bucle ? LoopMode.one : LoopMode.off);
    _notificar();
  }

  /// Cambia la velocidad de reproducción (0.5x a 1.5x).
  Future<void> cambiarVelocidad(double v) async {
    _velocidad = v;
    await player.setSpeed(v);
    _notificar();
  }

  /// Salta hacia adelante o atrás [delta] desde la posición actual.
  Future<void> saltar(Duration delta) async {
    final pos = player.position;
    final total = player.duration ?? Duration.zero;
    var nueva = pos + delta;
    if (nueva < Duration.zero) nueva = Duration.zero;
    if (total > Duration.zero && nueva > total) nueva = total;
    await player.seek(nueva);
  }

  /// Marca el punto A (inicio del bucle) en la posición actual.
  void marcarA() {
    final pos = player.position;
    _puntoA = pos;
    // Si B ya existía y quedaba antes de A, lo borramos.
    if (_puntoB != null && _puntoB! <= pos) {
      _puntoB = null;
    }
    _notificar();
  }

  /// Marca el punto B (fin del bucle) en la posición actual.
  /// Solo si hay punto A y B > A.
  void marcarB() {
    final pos = player.position;
    if (_puntoA == null) return;
    if (pos <= _puntoA!) return;
    _puntoB = pos;
    _notificar();
  }

  /// Limpia los puntos A y B.
  void limpiarAB() {
    _puntoA = null;
    _puntoB = null;
    _notificar();
  }

  Future<void> detener() async {
    await player.stop();
    _cancionId = null;
    _playing = false;
    _cargando = false;
    _bucle = false;
    _velocidad = 1.0;
    _puntoA = null;
    _puntoB = null;
    _notificar();
  }

  bool sonando(String cancionId) => _cancionId == cancionId && _playing;
  String? get cancionActualId => _cancionId;
}