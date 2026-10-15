import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Servicio de descarga con progreso en tiempo real.
///
/// Emite el progreso a través del callback [onProgreso] con:
///   - `progreso`: 0.0 a 1.0
///   - `bytesRecibidos`: bytes descargados hasta ahora
///   - `bytesTotales`: bytes totales (0 si el servidor no lo informa)
class DescargaProgresoService {
  static const _channel = MethodChannel('com.sikuris/screen_security');

  /// Descarga [url] con progreso, la guarda en la carpeta Descargas con
  /// el nombre [nombre] y mime [mime]. Devuelve el nombre guardado o
  /// null si falló.
  static Future<String?> descargar(
    String url,
    String nombre,
    String mime, {
    void Function(double progreso, int recibidos, int totales)? onProgreso,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Error HTTP: ${response.statusCode}');
      }

      final total = response.contentLength ?? 0;
      int recibido = 0;

      final chunks = <List<int>>[];
      await for (final chunk in response.stream) {
        chunks.add(chunk);
        recibido += chunk.length;
        if (onProgreso != null) {
          final progreso = total > 0 ? (recibido / total) : 0.0;
          onProgreso(progreso, recibido, total);
        }
      }

      // Armar el buffer final
      final builder = BytesBuilder(copy: false);
      for (final c in chunks) {
        builder.add(c);
      }
      final Uint8List bytes = builder.takeBytes();

      // Guardar vía método nativo (va a Descargas)
      final resultado = await _channel.invokeMethod('guardarEnDescargas', {
        'bytes': bytes,
        'nombre': nombre,
        'mime': mime,
      });

      if (resultado != null) {
        return nombre;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Descarga un archivo a un path temporal SIN guardarlo en Descargas.
  /// Útil para el APK antes de instalarlo.
  static Future<Uint8List?> descargarATemp(
    String url, {
    void Function(double progreso, int recibidos, int totales)? onProgreso,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Error HTTP: ${response.statusCode}');
      }

      final total = response.contentLength ?? 0;
      int recibido = 0;

      final builder = BytesBuilder(copy: false);
      await for (final chunk in response.stream) {
        builder.add(chunk);
        recibido += chunk.length;
        if (onProgreso != null) {
          final progreso = total > 0 ? (recibido / total) : 0.0;
          onProgreso(progreso, recibido, total);
        }
      }

      return builder.takeBytes();
    } catch (e) {
      return null;
    }
  }

  /// Formatea un tamaño en bytes a algo legible: "1.4 MB", "320 KB", etc.
  static String formatearTamano(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / 1048576).toStringAsFixed(2)} MB';
  }
}