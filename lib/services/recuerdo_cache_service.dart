import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cache_manager_service.dart';

class RecuerdoCacheService {
  static final RecuerdoCacheService _instance = RecuerdoCacheService._();
  factory RecuerdoCacheService() => _instance;

  RecuerdoCacheService._();

  final CacheManagerService _cache = CacheManagerService(
    nombreCarpeta: 'recuerdos_cache',
    limiteBytes: 1024 * 1024 * 1024,
  );

  final Set<String> _descargando = {};

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 10) AllinKawsay/1.0';

  String _clave(String recuerdoId, String tipo, int index) =>
      'recuerdo_${recuerdoId}_${tipo}_$index';

  String _extensionDe(String url, String tipo) {
    final lower = url.toLowerCase();
    if (tipo == 'video') {
      if (lower.contains('.mov')) return 'mov';
      if (lower.contains('.webm')) return 'webm';
      return 'mp4';
    }
    if (lower.contains('.png')) return 'png';
    if (lower.contains('.webp')) return 'webp';
    if (lower.contains('.heic')) return 'heic';
    return 'jpg';
  }

  Future<String?> rutaDe(String recuerdoId, String tipo, int index) =>
      _cache.rutaDe(_clave(recuerdoId, tipo, index));

  Future<bool> tiene(String recuerdoId, String tipo, int index) =>
      _cache.tiene(_clave(recuerdoId, tipo, index));

  void marcarAcceso(String recuerdoId, String tipo, int index) {
    _cache.marcarAcceso(_clave(recuerdoId, tipo, index));
  }

  void descargarEnBackground(
      String recuerdoId, String tipo, int index, String url) {
    if (url.isEmpty) return;
    final clave = _clave(recuerdoId, tipo, index);
    if (_descargando.contains(clave)) return;
    _descargando.add(clave);
    _descargar(clave, url, tipo).whenComplete(() {
      _descargando.remove(clave);
    });
  }

  Future<void> _descargar(String clave, String url, String tipo) async {
    try {
      if (await _cache.tiene(clave)) return;

      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = _userAgent;
      request.headers['Accept'] = '*/*';
      final streamed = await request.send().timeout(
            const Duration(minutes: 10),
          );
      if (streamed.statusCode != 200) return;

      final builder = BytesBuilder(copy: false);
      await for (final chunk in streamed.stream) {
        builder.add(chunk);
      }
      final Uint8List bytes = builder.takeBytes();
      if (bytes.isEmpty) return;

      await _cache.guardar(
        clave,
        bytes,
        url: url,
        extension: _extensionDe(url, tipo),
      );
      debugPrint('✅ Cacheado: $clave (${bytes.length} bytes)');
    } catch (e) {
      debugPrint('⚠️ Error descargando a cache: $e');
    }
  }

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
        await _descargar(clave, fotos[i], 'foto');
      }
      completados++;
      onProgreso?.call(completados, total);
    }
    for (int i = 0; i < videos.length; i++) {
      final clave = _clave(recuerdoId, 'video', i);
      if (!await _cache.tiene(clave)) {
        await _descargar(clave, videos[i], 'video');
      }
      completados++;
      onProgreso?.call(completados, total);
    }
    return total;
  }

  Future<void> borrarRecuerdo(
      String recuerdoId, int totalFotos, int totalVideos) async {
    for (int i = 0; i < totalFotos; i++) {
      await _cache.eliminar(_clave(recuerdoId, 'foto', i));
    }
    for (int i = 0; i < totalVideos; i++) {
      await _cache.eliminar(_clave(recuerdoId, 'video', i));
    }
  }

  Future<void> limpiarTodo() => _cache.limpiarTodo();
  Future<int> espacioUsado() => _cache.espacioUsado();
  Future<int> cantidad() => _cache.cantidad();
}