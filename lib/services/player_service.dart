// lib/services/player_service.dart
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/cancion.dart';
import 'audio_cache_service.dart';

class EstadoPlayer {
  final String? cancionId;
  final String? cancionTitulo;
  final bool playing;
  final bool cargando;
  final bool modoBucle;
  final double velocidad;
  final Duration? puntoA;
  final Duration? puntoB;

  const EstadoPlayer({
    this.cancionId,
    this.cancionTitulo,
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
  final ValueNotifier<EstadoPlayer> estado = ValueNotifier(const EstadoPlayer());

  String? _cancionId;
  String? _cancionTitulo;
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
      _cargando = s.processingState == ProcessingState.loading || s.processingState == ProcessingState.buffering;
      _notificar();
    });

    player.positionStream.listen((pos) {
      if (_seekingLoop) return;
      if (_puntoA == null || _puntoB == null) return;
      if (pos < _puntoB!) return;
      _seekingLoop = true;
      player.seek(_puntoA!).then((_) => _seekingLoop = false).catchError((_) => _seekingLoop = false);
    });
  }

  void _notificar() {
    estado.value = EstadoPlayer(
      cancionId: _cancionId,
      cancionTitulo: _cancionTitulo,
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
      if (_playing) await player.pause(); else await player.play();
      return;
    }

    try {
      _cancionId = c.id;
      _cancionTitulo = c.titulo;
      _cargando = true;
      _notificar();

      _velocidad = 1.0;
      _puntoA = null;
      _puntoB = null;
      _bucle = false;

      // 🚀 NOTIFICACIÓN PREMIUM: Usa la foto de la canción o el logo de la app
      final artUri = c.imagenUrl.isNotEmpty 
          ? Uri.parse(c.imagenUrl) 
          : Uri.parse('https://raw.githubusercontent.com/VkYakee/AllinKawsay/main/assets/logo.png'); // Fallback al logo de GitHub

      final tag = MediaItem(
        id: c.id,
        album: 'Allin Kawsay',
        title: c.titulo,
        artist: c.autor.isNotEmpty ? c.autor : 'Anónimo',
        artUri: artUri,
      );

      final rutaCache = await AudioCacheService().rutaDe(c.id);

      if (rutaCache != null) {
        await player.setAudioSource(AudioSource.file(rutaCache, tag: tag));
        await player.setSpeed(1.0);
        await player.setLoopMode(LoopMode.off);
        await player.play();
        AudioCacheService().marcarAcceso(c.id);
      } else {
        await player.setAudioSource(AudioSource.uri(Uri.parse(c.audioUrl), tag: tag));
        await player.setSpeed(1.0);
        await player.setLoopMode(LoopMode.off);
        await player.play();
        AudioCacheService().descargarEnBackground(c.id, c.audioUrl);
      }
    } catch (e) {
      debugPrint('⚠️ Error al reproducir: $e');
      _cancionId = null;
      _cancionTitulo = null;
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
    if (_puntoB != null && _puntoB! <= pos) _puntoB = null;
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
    _cancionTitulo = null;
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