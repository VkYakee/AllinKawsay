import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../data/zampona_catalogo.dart';
import '../models/zampona_nota.dart';

/// Servicio que reproduce los sonidos de la zampoña.
///
/// Usa `audioplayers` con modo `lowLatency` para que el sonido salga
/// casi instantáneamente al toque.
class ZamponaService {
  static final ZamponaService _instance = ZamponaService._();
  factory ZamponaService() => _instance;

  ZamponaService._();

  /// Cache de players, uno por nota (así no se reinicia la carga).
  final Map<String, AudioPlayer> _players = {};

  bool _inicializado = false;

  /// Inicializa los 13 players en paralelo.
  Future<void> init() async {
    if (_inicializado) return;
    _inicializado = true;

    for (final nota in zamponaNotas) {
      try {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource(nota.assetPath
            .replaceFirst('assets/', '')));
        _players[nota.id] = player;
      } catch (e) {
        debugPrint('⚠️ Error al inicializar player ${nota.id}: $e');
      }
    }

    debugPrint('✅ ZamponaService inicializado: ${_players.length} notas');
  }

  /// Reproduce una nota por su ID.
  /// Si ya estaba sonando la misma, la reinicia.
  Future<void> tocar(String notaId) async {
    final player = _players[notaId];
    if (player == null) {
      debugPrint('⚠️ Nota no encontrada: $notaId');
      return;
    }
    try {
      await player.stop();
      await player.resume();
    } catch (e) {
      debugPrint('⚠️ Error al tocar $notaId: $e');
    }
  }

  /// Reproduce una nota por su objeto [ZamponaNota].
  Future<void> tocarNota(ZamponaNota nota) => tocar(nota.id);

  /// Detiene todas las reproducciones en curso.
  Future<void> detener() async {
    for (final p in _players.values) {
      try {
        await p.stop();
      } catch (_) {}
    }
  }

  /// Libera todos los players.
  Future<void> dispose() async {
    for (final p in _players.values) {
      try {
        await p.dispose();
      } catch (_) {}
    }
    _players.clear();
    _inicializado = false;
  }
}