import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Item dentro del cache (con metadata LRU).
class CacheItem {
  final String id;
  String archivo;
  int bytes;
  DateTime ultimoAcceso;
  String? url;

  CacheItem({
    required this.id,
    required this.archivo,
    required this.bytes,
    required this.ultimoAcceso,
    this.url,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'archivo': archivo,
        'bytes': bytes,
        'ultimoAcceso': ultimoAcceso.toIso8601String(),
        if (url != null) 'url': url,
      };

  factory CacheItem.fromMap(Map<String, dynamic> m) => CacheItem(
        id: m['id'] as String,
        archivo: m['archivo'] as String,
        bytes: (m['bytes'] as num).toInt(),
        ultimoAcceso:
            DateTime.tryParse(m['ultimoAcceso'] ?? '') ?? DateTime(2000),
        url: m['url'] as String?,
      );
}

/// Gestor genérico de cache con política LRU.
class CacheManagerService {
  final String nombreCarpeta;
  final int limiteBytes;

  late Directory _carpeta;
  final Map<String, CacheItem> _items = {};
  bool _inicializado = false;

  CacheManagerService({
    required this.nombreCarpeta,
    this.limiteBytes = 1024 * 1024 * 1024,
  });

  Future<void> init() async {
    if (_inicializado) return;
    final baseDir = await getApplicationSupportDirectory();
    _carpeta = Directory('${baseDir.path}/$nombreCarpeta');
    if (!await _carpeta.exists()) {
      await _carpeta.create(recursive: true);
    }
    await _cargarMetadata();
    _inicializado = true;
  }

  Future<void> _cargarMetadata() async {
    try {
      final f = File('${_carpeta.path}/metadata.json');
      if (!await f.exists()) return;
      final raw = await f.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final lista = data['items'] as List?;
      if (lista == null) return;
      _items.clear();
      for (final item in lista) {
        final c = CacheItem.fromMap(Map<String, dynamic>.from(item));
        if (await File('${_carpeta.path}/${c.archivo}').exists()) {
          _items[c.id] = c;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error al cargar metadata de $nombreCarpeta: $e');
    }
  }

  Future<void> _guardarMetadata() async {
    try {
      final f = File('${_carpeta.path}/metadata.json');
      final data = {
        'items': _items.values.map((c) => c.toMap()).toList(),
      };
      await f.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('⚠️ Error al guardar metadata de $nombreCarpeta: $e');
    }
  }

  Future<bool> tiene(String id) async {
    await init();
    final item = _items[id];
    if (item == null) return false;
    return await File('${_carpeta.path}/${item.archivo}').exists();
  }

  Future<String?> rutaDe(String id) async {
    await init();
    final item = _items[id];
    if (item == null) return null;
    final path = '${_carpeta.path}/${item.archivo}';
    if (!await File(path).exists()) {
      _items.remove(id);
      return null;
    }
    return path;
  }

  /// Guarda un archivo. [extension] sin punto (ej: "mp4", "jpg", "cache").
  Future<bool> guardar(
    String id,
    List<int> bytes, {
    String? url,
    String extension = 'cache',
  }) async {
    await init();
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final archivo = '${id}_$timestamp.$extension';
      final f = File('${_carpeta.path}/$archivo');
      await f.writeAsBytes(bytes);

      final anterior = _items[id];
      if (anterior != null && anterior.archivo != archivo) {
        try {
          final viejo = File('${_carpeta.path}/${anterior.archivo}');
          if (await viejo.exists()) await viejo.delete();
        } catch (_) {}
      }

      _items[id] = CacheItem(
        id: id,
        archivo: archivo,
        bytes: bytes.length,
        ultimoAcceso: DateTime.now(),
        url: url,
      );

      await _guardarMetadata();
      await _limpiarLRU();
      return true;
    } catch (e) {
      debugPrint('⚠️ Error guardando en $nombreCarpeta: $e');
      return false;
    }
  }

  Future<void> marcarAcceso(String id) async {
    await init();
    final item = _items[id];
    if (item == null) return;
    item.ultimoAcceso = DateTime.now();
    _guardarMetadata();
  }

  Future<void> eliminar(String id) async {
    await init();
    final item = _items[id];
    if (item == null) return;
    try {
      final f = File('${_carpeta.path}/${item.archivo}');
      if (await f.exists()) await f.delete();
    } catch (_) {}
    _items.remove(id);
    await _guardarMetadata();
  }

  Future<void> limpiarTodo() async {
    await init();
    try {
      if (await _carpeta.exists()) {
        await _carpeta.delete(recursive: true);
      }
      await _carpeta.create(recursive: true);
    } catch (_) {}
    _items.clear();
    await _guardarMetadata();
  }

  Future<void> _limpiarLRU() async {
    int totalBytes = _items.values.fold(0, (s, i) => s + i.bytes);
    if (totalBytes <= limiteBytes) return;

    final ordenados = _items.values.toList()
      ..sort((a, b) => a.ultimoAcceso.compareTo(b.ultimoAcceso));

    for (final item in ordenados) {
      if (totalBytes <= limiteBytes) break;
      try {
        final f = File('${_carpeta.path}/${item.archivo}');
        if (await f.exists()) await f.delete();
        totalBytes -= item.bytes;
        _items.remove(item.id);
      } catch (_) {}
    }
    await _guardarMetadata();
  }

  Future<int> espacioUsado() async {
    await init();
    return _items.values.fold(0, (s, i) => s + i.bytes);
  }

  Future<int> cantidad() async {
    await init();
    return _items.length;
  }

  Future<List<String>> ids() async {
    await init();
    return _items.keys.toList();
  }

  /// Lista con más info (útil para el panel de gestión).
  Future<List<CacheItem>> items() async {
    await init();
    final lista = _items.values.toList()
      ..sort((a, b) => b.ultimoAcceso.compareTo(a.ultimoAcceso));
    return lista;
  }
}