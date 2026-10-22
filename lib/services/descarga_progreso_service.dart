// lib/services/descarga_progreso_service.dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class DescargaProgresoService {
  static const _channel = MethodChannel('com.allinkawsay/native');

  static const _userAgent = 'Mozilla/5.0 (Linux; Android 10) AllinKawsay/1.0';

  static Future<String?> descargar(
    String url,
    String nombre,
    String mime, {
    void Function(double progreso, int recibidos, int totales)? onProgreso,
  }) async {
    // Intentamos la descarga hasta 3 veces si falla por conexión
    for (int intento = 1; intento <= 3; intento++) {
      try {
        final request = http.Request('GET', Uri.parse(url));
        request.headers['User-Agent'] = _userAgent;
        request.headers['Accept'] = '*/*';

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30), // Aumentamos el timeout
          onTimeout: () => throw Exception('Tiempo de espera agotado'),
        );

        if (streamedResponse.statusCode != 200) {
          return null;
        }

        final total = streamedResponse.contentLength ?? 0;
        int recibido = 0;

        final chunks = <List<int>>[];
        await for (final chunk in streamedResponse.stream) {
          chunks.add(chunk);
          recibido += chunk.length;
          if (onProgreso != null) {
            final progreso = total > 0 ? (recibido / total) : 0.0;
            onProgreso(progreso, recibido, total);
          }
        }

        final builder = BytesBuilder(copy: false);
        for (final c in chunks) {
          builder.add(c);
        }
        final Uint8List bytes = builder.takeBytes();
        if (bytes.isEmpty) return null;

        final resultado = await _channel.invokeMethod('guardarEnDescargas', {
          'bytes': bytes,
          'nombre': nombre,
          'mime': mime,
        });

        if (resultado != null) return nombre;
        return null;
      } catch (e) {
        // Si es el último intento, devolvemos null
        if (intento == 3) return null;
        // Si no, esperamos 2 segundos y reintentamos
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }

  static Future<Uint8List?> descargarATemp(
    String url, {
    void Function(double progreso, int recibidos, int totales)? onProgreso,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers['User-Agent'] = _userAgent;
      request.headers['Accept'] = '*/*';
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      if (streamedResponse.statusCode != 200) return null;

      final total = streamedResponse.contentLength ?? 0;
      int recibido = 0;

      final builder = BytesBuilder(copy: false);
      await for (final chunk in streamedResponse.stream) {
        builder.add(chunk);
        recibido += chunk.length;
        if (onProgreso != null) {
          final progreso = total > 0 ? (recibido / total) : 0.0;
          onProgreso(progreso, recibido, total);
        }
      }
      return builder.takeBytes();
    } catch (_) {
      return null;
    }
  }

  static String formatearTamano(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / 1048576).toStringAsFixed(2)} MB';
  }
}