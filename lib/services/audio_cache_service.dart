import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cache_manager_service.dart';

/// Cache de audios de canciones. 1 GB máximo.
/// Los archivos se guardan con extensión .mp3 pero dentro de la
/// carpeta interna de la app (invisible al usuario).
class AudioCacheService {
  static final AudioCacheService _instance = AudioCacheService._();
  factory AudioCacheService() => _instance;

  AudioCacheService._();

  final CacheManagerService _cache = CacheManagerService(
    nombreCarpeta: 'audio_cache',
    limiteBytes: 1024 * 1024 * 1024,
  );

  final Set<String> _descargando = {};

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

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(minutes: 5),
      );
      if (response.statusCode != 200) return;

      final Uint8List bytes = response.bodyBytes;
      if (bytes.isEmpty) return;

      await _cache.guardar(
        cancionId,
        bytes,
        url: url,
        extension: 'mp3',
      );
      debugPrint('✅ Audio cacheado: $cancionId (${bytes.length} bytes)');
    } catch (e) {
      debugPrint('⚠️ Error descargando audio a cache: $e');
    }
  }

  Future<bool> descargarAhora(String cancionId, String url) async {
    if (url.isEmpty) return false;
    if (await _cache.tiene(cancionId)) return true;
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(minutes: 5),
      );
      if (response.statusCode != 200) return false;
      final Uint8List bytes = response.bodyBytes;
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