import 'package:firebase_auth/firebase_auth.dart';
import 'cancion_service.dart';

/// Controla el conteo de reproducciones: solo cuenta 1 vez por
/// usuario por canción. Persistente en Firestore (no en el celu).
class ReproduccionService {
  /// Intenta contar la reproducción. Solo incrementa si es la primera
  /// vez que ESTE usuario reproduce ESTA canción.
  ///
  /// Devuelve true si se incrementó, false si ya estaba contada.
  static Future<bool> contarUnaVez(String cancionId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return false;
    return CancionService().incrementarReproduccionUnaVez(cancionId, uid);
  }
}