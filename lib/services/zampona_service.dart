import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../data/zampona_catalogo.dart';
import '../models/zampona_nota.dart';

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

  /// Reproduce una nota. FIX del pop:
  /// - El setVolume(1.0) va DESPUÉS del stop(), así el volumen se ajusta
  ///   mientras el player está detenido y no en pleno sonido.
  Future<void> tocar(String notaId) async {
    final player = _players[notaId];
    if (player == null) return;

    try {
      _fadeTimers[notaId]?.cancel();
      _fadeTimers[notaId] = null;

      await player.stop();
      await player.setVolume(1.0);
      await player.resume();
    } catch (e) {
      debugPrint('⚠️ Error al tocar $notaId: $e');
    }
  }

  /// Fade-out corto (45ms). Se usa al final de una estrofa para no
  /// dejar la última nota sonando largo.
  Future<void> fadeOutNota(String notaId) async {
    final player = _players[notaId];
    if (player == null) return;

    _fadeTimers[notaId]?.cancel();
    _fadeTimers[notaId] = null;

    const pasos = 3;
    const intervaloMs = 15;

    for (int i = 1; i <= pasos; i++) {
      final vol = (1.0 - i / pasos).clamp(0.0, 1.0);
      try {
        await player.setVolume(vol);
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: intervaloMs));
    }
    try {
      await player.stop();
      await player.setVolume(1.0);
    } catch (_) {}
  }

  /// Stop instantáneo SIN resume. Se usa entre notas consecutivas
  /// en el ensayo para cortar la anterior antes de la siguiente.
  Future<void> detenerNota(String notaId) async {
    final player = _players[notaId];
    if (player == null) return;

    _fadeTimers[notaId]?.cancel();
    _fadeTimers[notaId] = null;

    try {
      await player.stop();
      await player.setVolume(1.0);
    } catch (_) {}
  }

  Future<void> soltar(String notaId) async {
    if (_modo != ZamponaModo.pulsado) return;
    final player = _players[notaId];
    if (player == null) return;

    _fadeTimers[notaId]?.cancel();

    const pasos = 8;
    const intervaloMs = 18;
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