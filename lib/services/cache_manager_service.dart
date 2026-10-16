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
  String? url; // opcional, para saber de dónde vino

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

/// Gestor genérico de cache con política LRU (Least Recently Used).
///
/// Uso:
/// ```dart
/// final cache = CacheManagerService(
///   nombreCarpeta: 'audio_cache',
///   limiteBytes: 1024 * 1024 * 1024, // 1 GB
/// );
/// await cache.init();
/// ```
class CacheManagerService {
  final String nombreCarpeta;
  final int limiteBytes;

  late Directory _carpeta;
  final Map<String, CacheItem> _items = {};
  bool _inicializado = false;

  CacheManagerService({
    required this.nombreCarpeta,
    this.limiteBytes = 1024 * 1024 * 1024, // 1 GB por defecto
  });

  /// Inicializa el cache: crea la carpeta y carga metadata.
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
        // Verificar que el archivo físico todavía exista
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

  /// ¿Existe este ID en el cache?
  Future<bool> tiene(String id) async {
    await init();
    final item = _items[id];
    if (item == null) return false;
    final f = File('${_carpeta.path}/${item.archivo}');
    return await f.exists();
  }

  /// Devuelve la ruta local del archivo o null si no está.
  Future<String?> rutaDe(String id) async {
    await init();
    final item = _items[id];
    if (item == null) return null;
    final path = '${_carpeta.path}/${item.archivo}';
    final f = File(path);
    if (!await f.exists()) {
      _items.remove(id);
      return null;
    }
    return path;
  }

  /// Guarda un archivo (bytes) en el cache con el ID dado.
  /// Actualiza LRU y limpia si es necesario.
  Future<bool> guardar(String id, List<int> bytes, {String? url}) async {
    await init();
    try {
      // Nombre de archivo: hash-ish único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final archivo = '${id}_$timestamp.cache';
      final f = File('${_carpeta.path}/$archivo');
      await f.writeAsBytes(bytes);

      // Si ya existía un archivo para este ID, lo borramos
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

  /// Marca un item como recién usado (actualiza su timestamp).
  /// No hace IO de escritura del archivo, solo metadata.
  Future<void> marcarAcceso(String id) async {
    await init();
    final item = _items[id];
    if (item == null) return;
    item.ultimoAcceso = DateTime.now();
    // Guardado diferido: no bloqueamos al llamador
    _guardarMetadata();
  }

  /// Elimina un item específico.
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

  /// Borra TODO el cache.
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

  /// Aplica política LRU: si el tamaño total supera [limiteBytes],
  /// borra los archivos más viejos hasta estar por debajo.
  Future<void> _limpiarLRU() async {
    int totalBytes = _items.values.fold(0, (s, i) => s + i.bytes);
    if (totalBytes <= limiteBytes) return;

    // Ordenar por último acceso (más viejo primero)
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

  /// Espacio total usado en bytes.
  Future<int> espacioUsado() async {
    await init();
    return _items.values.fold(0, (s, i) => s + i.bytes);
  }

  /// Cantidad de items cacheados.
  Future<int> cantidad() async {
    await init();
    return _items.length;
  }

  /// Lista de IDs cacheados.
  Future<List<String>> ids() async {
    await init();
    return _items.keys.toList();
  }
}