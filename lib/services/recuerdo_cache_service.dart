import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cache_manager_service.dart';

/// Cache de fotos y videos de recuerdos. 1 GB máximo.
///
/// Los archivos se identifican por el hash de su URL (para no
/// depender del recuerdoId) pero se agrupan con prefijo
/// `recuerdo_{id}_foto_{n}` o `recuerdo_{id}_video_{n}`.
class RecuerdoCacheService {
  static final RecuerdoCacheService _instance = RecuerdoCacheService._();
  factory RecuerdoCacheService() => _instance;

  RecuerdoCacheService._();

  final CacheManagerService _cache = CacheManagerService(
    nombreCarpeta: 'recuerdos_cache',
    limiteBytes: 1024 * 1024 * 1024, // 1 GB
  );

  final Set<String> _descargando = {};

  /// Genera la clave de cache para una foto o video.
  /// Ej: `recuerdo_abc123_foto_0`
  String _clave(String recuerdoId, String tipo, int index) =>
      'recuerdo_${recuerdoId}_${tipo}_$index';

  /// Devuelve la ruta local si existe.
  Future<String?> rutaDe(String recuerdoId, String tipo, int index) =>
      _cache.rutaDe(_clave(recuerdoId, tipo, index));

  /// ¿Está cacheado?
  Future<bool> tiene(String recuerdoId, String tipo, int index) =>
      _cache.tiene(_clave(recuerdoId, tipo, index));

  /// Marca como usado (LRU).
  void marcarAcceso(String recuerdoId, String tipo, int index) {
    _cache.marcarAcceso(_clave(recuerdoId, tipo, index));
  }

  /// Descarga una foto o video en background.
  void descargarEnBackground(
      String recuerdoId, String tipo, int index, String url) {
    if (url.isEmpty) return;
    final clave = _clave(recuerdoId, tipo, index);
    if (_descargando.contains(clave)) return;
    _descargando.add(clave);
    _descargar(clave, url).whenComplete(() {
      _descargando.remove(clave);
    });
  }

  Future<void> _descargar(String clave, String url) async {
    try {
      if (await _cache.tiene(clave)) return;
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(minutes: 10),
      );
      if (response.statusCode != 200) return;
      final Uint8List bytes = response.bodyBytes;
      if (bytes.isEmpty) return;
      await _cache.guardar(clave, bytes, url: url);
      debugPrint('✅ Cacheado: $clave (${bytes.length} bytes)');
    } catch (e) {
      debugPrint('⚠️ Error descargando a cache: $e');
    }
  }

  /// Descarga todas las fotos y videos de un recuerdo.
  /// Devuelve la cantidad de archivos descargados.
  Future<int> descargarRecuerdoCompleto(
    String recuerdoId, {
    required List<String> fotos,
    required List<String> videos,
    void Function(int completados, int total)? onProgreso,
  }) async {
    final total = fotos.length + videos.length;
    if (total == 0) return 0;
    int completados = 0;

    for (int i = 0; i < fotos.length; i++) {
      final clave = _clave(recuerdoId, 'foto', i);
      if (!await _cache.tiene(clave)) {
        await _descargar(clave, fotos[i]);
      }
      completados++;
      onProgreso?.call(completados, total);
    }
    for (int i = 0; i < videos.length; i++) {
      final clave = _clave(recuerdoId, 'video', i);
      if (!await _cache.tiene(clave)) {
        await _descargar(clave, videos[i]);
      }
      completados++;
      onProgreso?.call(completados, total);
    }
    return total;
  }

  /// Borra todos los archivos cacheados de un recuerdo.
  Future<void> borrarRecuerdo(
      String recuerdoId, int totalFotos, int totalVideos) async {
    for (int i = 0; i < totalFotos; i++) {
      await _cache.eliminar(_clave(recuerdoId, 'foto', i));
    }
    for (int i = 0; i < totalVideos; i++) {
      await _cache.eliminar(_clave(recuerdoId, 'video', i));
    }
  }

  /// Borra TODO el cache de recuerdos.
  Future<void> limpiarTodo() => _cache.limpiarTodo();

  /// Espacio usado en bytes.
  Future<int> espacioUsado() => _cache.espacioUsado();

  /// Cantidad de archivos cacheados.
  Future<int> cantidad() => _cache.cantidad();
}