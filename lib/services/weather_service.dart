// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final double temp;
  final int code;

  WeatherInfo({required this.temp, required this.code});

  String get descripcion {
    if (code == 0) return 'Despejado';
    if (code >= 1 && code <= 3) return 'Parcialmente nublado';
    if (code >= 45 && code <= 48) return 'Niebla';
    if (code >= 51 && code <= 67) return 'Lluvia';
    if (code >= 71 && code <= 77) return 'Nieve';
    if (code >= 80 && code <= 82) return 'Chubascos';
    if (code >= 95) return 'Tormenta';
    return 'Desconocido';
  }

  String get icono {
    if (code == 0) return '☀️';
    if (code >= 1 && code <= 3) return '⛅';
    if (code >= 45 && code <= 48) return '🌫️';
    if (code >= 51 && code <= 67) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌦️';
    if (code >= 95) return '⛈️';
    return '🌡️';
  }
}

class WeatherService {
  static Future<WeatherInfo?> obtenerClima(double lat, double lng, DateTime fecha) async {
    try {
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final current = data['current_weather'];
        return WeatherInfo(
          temp: (current['temperature'] as num).toDouble(),
          code: current['weathercode'] as int,
        );
      }
      return null;
    } catch (_) {
      return null; // Si falla, no mostramos clima (ej. si no hay red)
    }
  }
}