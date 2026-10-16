import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../data/zampona_catalogo.dart';
import '../models/zampona_nota.dart';

/// Modo de reproducción de la zampoña.
///
/// - sostenido: la nota suena hasta el final sola. Tocar otra corta la anterior.
/// - pulsado: la nota suena mientras tengas el dedo apoyado. Al soltar, fade-out suave.
enum ZamponaModo { sostenido, pulsado }

class ZamponaService {
  static final ZamponaService _instance = ZamponaService._();
  factory ZamponaService() => _instance;

  ZamponaService._();

  final Map<String, AudioPlayer> _players = {};
  final Map<String, Timer?> _fadeTimers = {};

  bool _inicializado = false;

  ZamponaModo _modo = ZamponaModo.sostenido;
  ZamponaModo get modo => _modo;

  void setModo(ZamponaModo m) {
    _modo = m;

    // Si volvemos a sostenido, restaurar volumen de todos los players
    // (por si alguno quedó a medio fade).
    if (m == ZamponaModo.sostenido) {
      for (final p in _players.values) {
        try {
          p.setVolume(1.0);
        } catch (_) {}
      }
      for (final e in _fadeTimers.entries) {
        e.value?.cancel();
        _fadeTimers[e.key] = null;
      }
    }
  }

  Future<void> init() async {
    if (_inicializado) return;
    _inicializado = true;

    for (final nota in zamponaNotas) {
      try {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource(
          nota.assetPath.replaceFirst('assets/', ''),
        ));
        _players[nota.id] = player;
        _fadeTimers[nota.id] = null;
      } catch (e) {
        debugPrint('⚠️ Error al inicializar player ${nota.id}: $e');
      }
    }

    debugPrint('✅ ZamponaService inicializado: ${_players.length} notas');
  }

  /// Reproduce una nota por su ID.
  /// Si ya estaba sonando, la reinicia desde el principio.
  Future<void> tocar(String notaId) async {
    final player = _players[notaId];
    if (player == null) return;

    try {
      // Cancelar fade pendiente (por si venía de un "soltar")
      _fadeTimers[notaId]?.cancel();
      _fadeTimers[notaId] = null;

      // Volumen al máximo (por si quedó a medio fade)
      await player.setVolume(1.0);

      // Fix del "pop": stop + seek(0) + resume en ese orden.
      await player.stop();
      await player.seek(Duration.zero);
      await player.resume();
    } catch (e) {
      debugPrint('⚠️ Error al tocar $notaId: $e');
    }
  }

  /// Suelta una nota (solo en modo PULSADO). Aplica fade-out suave.
  Future<void> soltar(String notaId) async {
    if (_modo != ZamponaModo.pulsado) return;
    final player = _players[notaId];
    if (player == null) return;

    // Cancelar cualquier fade pendiente
    _fadeTimers[notaId]?.cancel();

    const pasos = 8;
    const duracionMs = 140;
    const intervaloMs = duracionMs ~/ pasos;
    int paso = 0;

    _fadeTimers[notaId] = Timer.periodic(
      const Duration(milliseconds: intervaloMs),
      (t) async {
        paso++;
        final vol = (1.0 - paso / pasos).clamp(0.0, 1.0);
        try {
          await player.setVolume(vol);
          if (paso >= pasos) {
            t.cancel();
            _fadeTimers[notaId] = null;
            await player.stop();
            await player.setVolume(1.0);
          }
        } catch (_) {
          t.cancel();
          _fadeTimers[notaId] = null;
        }
      },
    );
  }

  Future<void> tocarNota(ZamponaNota nota) => tocar(nota.id);

  /// Detiene todas las reproducciones en curso.
  Future<void> detener() async {
    for (final e in _fadeTimers.entries) {
      e.value?.cancel();
      _fadeTimers[e.key] = null;
    }
    for (final p in _players.values) {
      try {
        await p.stop();
        await p.setVolume(1.0);
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    for (final e in _fadeTimers.entries) {
      e.value?.cancel();
    }
    for (final p in _players.values) {
      try {
        await p.dispose();
      } catch (_) {}
    }
    _players.clear();
    _fadeTimers.clear();
    _inicializado = false;
  }
}