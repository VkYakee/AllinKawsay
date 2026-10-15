import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evento.dart';
import 'evento_service.dart';

/// Servicio que lleva el control de "qué hay nuevo" desde la última
/// visita del usuario a cada sección. Usa SharedPreferences.
class NovedadesService {
  // Claves para guardar la última visita
  static const _keyEventos = 'ultima_visita_eventos';
  static const _keyInicio = 'ultima_visita_inicio';

  /// Contador reactivo de eventos nuevos (para el badge en Home).
  static final ValueNotifier<int> eventosNuevos = ValueNotifier<int>(0);

  /// Devuelve la fecha de la última visita a [seccion].
  /// Si nunca visitó, devuelve DateTime(2000) → no cuenta eventos viejos.
  static Future<DateTime> _ultimaVisita(String seccion) async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(seccion);
    if (iso == null) return DateTime(2000);
    return DateTime.tryParse(iso) ?? DateTime(2000);
  }

  /// Marca la sección como visitada (guarda la fecha actual).
  static Future<void> _marcarVisitado(String seccion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(seccion, DateTime.now().toIso8601String());
  }

  /// Devuelve el evento más nuevo no visto, o null si no hay.
  /// Solo considera eventos futuros (que no pasaron su fecha).
  static Future<Evento?> eventoNuevoNoVisto() async {
    try {
      final ultima = await _ultimaVisita(_keyEventos);
      final eventos = await EventoService().listar().first;
      final ahora = DateTime.now();

      final nuevos = eventos.where((e) {
        // Solo eventos futuros
        if (e.fecha.isBefore(ahora)) return false;
        // Creados o editados después de la última visita
        return e.ultimaModificacion.isAfter(ultima);
      }).toList();

      if (nuevos.isEmpty) return null;

      // El más reciente primero
      nuevos.sort(
          (a, b) => b.ultimaModificacion.compareTo(a.ultimaModificacion));
      return nuevos.first;
    } catch (_) {
      return null;
    }
  }

  /// Cuenta cuántos eventos nuevos hay desde la última visita.
  static Future<int> contarEventosNuevos() async {
    try {
      final ultima = await _ultimaVisita(_keyEventos);
      final eventos = await EventoService().listar().first;
      final ahora = DateTime.now();

      return eventos.where((e) {
        if (e.fecha.isBefore(ahora)) return false;
        return e.ultimaModificacion.isAfter(ultima);
      }).length;
    } catch (_) {
      return 0;
    }
  }

  /// Marca los eventos como vistos y actualiza el badge.
  static Future<void> marcarEventosVistos() async {
    await _marcarVisitado(_keyEventos);
    eventosNuevos.value = 0;
  }

  /// Marca el inicio como visitado (no se usa todavía, pero queda
  /// por si querés trackear otras novedades a futuro).
  static Future<void> marcarInicioVisto() async {
    await _marcarVisitado(_keyInicio);
  }

  /// Refresca el contador de eventos nuevos (para el badge).
  static Future<void> refrescar() async {
    eventosNuevos.value = await contarEventosNuevos();
  }
}