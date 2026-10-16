import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cache_manager_service.dart';

class AudioCacheService {
  static final AudioCacheService _instance = AudioCacheService._();
  factory AudioCacheService() => _instance;

  AudioCacheService._();

  final CacheManagerService _cache = CacheManagerService(
    nombreCarpeta: 'audio_cache',
    limiteBytes: 1024 * 1024 * 1024,
  );

  final Set<String> _descargando = {};

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 10) AllinKawsay/1.0';

  Future<String?> rutaDe(String cancionId) => _cache.rutaDe(cancionId);

  Future<bool> tiene(String cancionId) => _cache.tiene(cancionId);

  void marcarAcceso(String cancionId) {
    _cache.marcarAcceso(cancionId);
  }

  void descargarEnBackground(String cancionId, String url) {
    if (url.isEmpty) return;
    if (_descargando.contains(cancionId)) return;

    _descargando.add(cancionId);
    _descargar(cancionId, url).whenComplete(() {
      _descargando.remove(cancionId);
    });
  }

  Future<void> _descargar(String cancionId, String url) async {
    try {
      if (await _cache.tiene(cancionId)) return;

      // Esperar 2 segundos antes de descargar para no chocar con
      // el streaming inicial del player.
      await Future.delayed(const Duration(seconds: 2));
      if (await _cache.tiene(cancionId)) return;

      debugPrint('⬇️ Descargando audio a cache: $cancionId');

      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = _userAgent;
      request.headers['Accept'] = '*/*';
      final streamed = await request.send().timeout(
            const Duration(minutes: 5),
          );

      if (streamed.statusCode != 200) {
        debugPrint(
            '⚠️ Cache HTTP ${streamed.statusCode} para $cancionId');
        return;
      }

      final builder = BytesBuilder(copy: false);
      await for (final chunk in streamed.stream) {
        builder.add(chunk);
      }
      final Uint8List bytes = builder.takeBytes();
      if (bytes.isEmpty) {
        debugPrint('⚠️ Bytes vacíos para $cancionId');
        return;
      }

      final ok = await _cache.guardar(
        cancionId,
        bytes,
        url: url,
        extension: 'mp3',
      );
      if (ok) {
        debugPrint('✅ Audio cacheado: $cancionId (${bytes.length} bytes)');
      }
    } catch (e) {
      debugPrint('⚠️ Error descargando audio a cache: $e');
    }
  }

  Future<bool> descargarAhora(String cancionId, String url) async {
    if (url.isEmpty) return false;
    if (await _cache.tiene(cancionId)) return true;
    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = _userAgent;
      request.headers['Accept'] = '*/*';
      final streamed = await request.send().timeout(
            const Duration(minutes: 5),
          );
      if (streamed.statusCode != 200) return false;
      final builder = BytesBuilder(copy: false);
      await for (final chunk in streamed.stream) {
        builder.add(chunk);
      }
      final bytes = builder.takeBytes();
      if (bytes.isEmpty) return false;
      return await _cache.guardar(
        cancionId,
        bytes,
        url: url,
        extension: 'mp3',
      );
    } catch (e) {
      debugPrint('⚠️ Error descargando audio: $e');
      return false;
    }
  }

  Future<void> borrar(String cancionId) => _cache.eliminar(cancionId);
  Future<void> limpiarTodo() => _cache.limpiarTodo();
  Future<int> espacioUsado() => _cache.espacioUsado();
  Future<int> cantidad() => _cache.cantidad();
  Future<List<String>> ids() => _cache.ids();
}