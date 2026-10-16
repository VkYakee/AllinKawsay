import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/cancion.dart';
import 'audio_cache_service.dart';

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

  /// Reproduce o pausa. Usa el cache local si está disponible,
  /// si no, hace streaming y descarga en paralelo.
  Future<void> toggle(Cancion c) async {
    if (c.audioUrl.isEmpty) return;

    // Misma canción → solo play/pausa
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

      // Preparar tag de la notificación
      final tag = MediaItem(
        id: c.id,
        album: 'Allin Kawsay',
        title: c.titulo,
        artist: c.autor.isNotEmpty ? c.autor : 'Anónimo',
        artUri: c.imagenUrl.isNotEmpty ? Uri.parse(c.imagenUrl) : null,
      );

      // 1) Ver si está en cache
      final rutaCache = await AudioCacheService().rutaDe(c.id);

      if (rutaCache != null) {
        // ✅ Reproducir del archivo local (instantáneo)
        debugPrint('▶️ Reproduciendo del cache: ${c.id}');
        await player.setAudioSource(
          AudioSource.file(rutaCache, tag: tag),
        );
        await player.setSpeed(1.0);
        await player.setLoopMode(LoopMode.off);
        await player.play();
        // Marcar como accedido (LRU)
        AudioCacheService().marcarAcceso(c.id);
      } else {
        // 🔄 Streaming + descarga en paralelo
        debugPrint('🌐 Streaming: ${c.id}');
        await player.setAudioSource(
          AudioSource.uri(Uri.parse(c.audioUrl), tag: tag),
        );
        await player.setSpeed(1.0);
        await player.setLoopMode(LoopMode.off);
        await player.play();
        // Descargar al cache en background (no bloquea)
        AudioCacheService().descargarEnBackground(c.id, c.audioUrl);
      }
    } catch (e) {
      debugPrint('⚠️ Error al reproducir: $e');
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

  Future<void> cambiarVelocidad(double v) async {
    _velocidad = v;
    await player.setSpeed(v);
    _notificar();
  }

  Future<void> saltar(Duration delta) async {
    final pos = player.position;
    final total = player.duration ?? Duration.zero;
    var nueva = pos + delta;
    if (nueva < Duration.zero) nueva = Duration.zero;
    if (total > Duration.zero && nueva > total) nueva = total;
    await player.seek(nueva);
  }

  void marcarA() {
    final pos = player.position;
    _puntoA = pos;
    if (_puntoB != null && _puntoB! <= pos) {
      _puntoB = null;
    }
    _notificar();
  }

  void marcarB() {
    final pos = player.position;
    if (_puntoA == null) return;
    if (pos <= _puntoA!) return;
    _puntoB = pos;
    _notificar();
  }

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