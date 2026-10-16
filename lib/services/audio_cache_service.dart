import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cache_manager_service.dart';

/// Cache de audios de canciones. 1 GB máximo.
/// Los archivos se guardan con extensión `.cache` para que no los
/// reconozca ningún reproductor externo.
class AudioCacheService {
  static final AudioCacheService _instance = AudioCacheService._();
  factory AudioCacheService() => _instance;

  AudioCacheService._();

  final CacheManagerService _cache = CacheManagerService(
    nombreCarpeta: 'audio_cache',
    limiteBytes: 1024 * 1024 * 1024, // 1 GB
  );

  /// Descargas activas en este momento (para no duplicar).
  final Set<String> _descargando = {};

  /// Devuelve la ruta local del audio si está cacheado.
  Future<String?> rutaDe(String cancionId) => _cache.rutaDe(cancionId);

  /// ¿Está cacheado?
  Future<bool> tiene(String cancionId) => _cache.tiene(cancionId);

  /// Marca el audio como recién usado (LRU).
  void marcarAcceso(String cancionId) {
    _cache.marcarAcceso(cancionId);
  }

  /// Descarga el audio en background y lo guarda en cache.
  /// No bloquea. Si ya está descargando o ya está, no hace nada.
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
      // Ya existe → no descargamos
      if (await _cache.tiene(cancionId)) return;

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(minutes: 5),
      );
      if (response.statusCode != 200) return;

      final Uint8List bytes = response.bodyBytes;
      if (bytes.isEmpty) return;

      await _cache.guardar(cancionId, bytes, url: url);
      debugPrint('✅ Audio cacheado: $cancionId (${bytes.length} bytes)');
    } catch (e) {
      debugPrint('⚠️ Error descargando audio a cache: $e');
    }
  }

  /// Fuerza la descarga (espera a que termine).
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
      return await _cache.guardar(cancionId, bytes, url: url);
    } catch (e) {
      debugPrint('⚠️ Error descargando audio: $e');
      return false;
    }
  }

  /// Borra un audio cacheado.
  Future<void> borrar(String cancionId) => _cache.eliminar(cancionId);

  /// Borra TODO el cache de audios.
  Future<void> limpiarTodo() => _cache.limpiarTodo();

  /// Espacio usado en bytes.
  Future<int> espacioUsado() => _cache.espacioUsado();

  /// Cantidad de audios cacheados.
  Future<int> cantidad() => _cache.cantidad();

  /// Lista de IDs cacheados.
  Future<List<String>> ids() => _cache.ids();
}