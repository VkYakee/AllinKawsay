import 'package:shared_preferences/shared_preferences.dart';
import 'cancion_service.dart';

/// Controla el conteo de reproducciones: solo cuenta 1 vez por
/// usuario por canción, aunque el usuario le dé play 100 veces.
class ReproduccionService {
  static const _key = 'reproducciones_contadas';

  /// Verifica si ya contamos esta canción antes para este usuario.
  static Future<bool> yaContada(String cancionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lista = prefs.getStringList(_key) ?? [];
      return lista.contains(cancionId);
    } catch (_) {
      return false;
    }
  }

  /// Marca la canción como ya contada (sin incrementar).
  static Future<void> _marcarContada(String cancionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lista = prefs.getStringList(_key) ?? [];
      if (!lista.contains(cancionId)) {
        lista.add(cancionId);
        await prefs.setStringList(_key, lista);
      }
    } catch (_) {}
  }

  /// Si es la primera vez que este usuario reproduce esta canción,
  /// incrementa el contador en Firestore. Si no, no hace nada.
  ///
  /// Devuelve true si se incrementó, false si ya estaba contada.
  static Future<bool> contarUnaVez(String cancionId) async {
    final yaEsta = await yaContada(cancionId);
    if (yaEsta) return false;
    try {
      await CancionService().incrementarReproduccion(cancionId);
      await _marcarContada(cancionId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Limpia el historial (por si querés resetear).
  static Future<void> limpiarHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}