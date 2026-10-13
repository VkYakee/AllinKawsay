import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cancion.dart';
import 'actividad_service.dart';

class CancionService {
  final _db = FirebaseFirestore.instance;

  /// Lista todas las canciones ordenadas por fecha de creación DESC
  /// (las más nuevas primero). Ordenamos en Dart para no perder
  /// documentos viejos que no tengan el campo `fechaCreacion`.
  Stream<List<Cancion>> listar() {
    return _db.collection('canciones').snapshots().map((snap) {
      final lista = snap.docs.map(Cancion.fromDoc).toList();
      lista.sort((a, b) {
        final fa = a.fechaCreacion ?? DateTime(2000);
        final fb = b.fechaCreacion ?? DateTime(2000);
        return fb.compareTo(fa);
      });
      return lista;
    });
  }

  Future<String> agregar(Cancion c) async {
    final ref = await _db.collection('canciones').add(c.toMapCrear());
    ActividadService.registrar(
      'crear_cancion',
      'Subió la canción "${c.titulo}"',
    );
    return ref.id;
  }

  Future<void> actualizar(String id, Map<String, dynamic> cambios) async {
    await _db.collection('canciones').doc(id).update(cambios);
    final titulo = cambios['titulo'] ?? id;
    ActividadService.registrar(
      'editar_cancion',
      'Editó la canción "$titulo"',
    );
  }

  Future<void> eliminar(String id) async {
    String titulo = id;
    try {
      final doc = await _db.collection('canciones').doc(id).get();
      if (doc.exists) {
        titulo = (doc.data()?['titulo'] ?? id).toString();
      }
    } catch (_) {}

    await _db.collection('canciones').doc(id).delete();
    ActividadService.registrar(
      'eliminar_cancion',
      'Eliminó la canción "$titulo"',
    );
  }

  /// Incrementa reproducciones de forma ATÓMICA (evita race conditions).
  Future<void> incrementarReproduccion(String id) async {
    try {
      await _db.collection('canciones').doc(id).update({
        'reproducciones': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  /// Cuenta cuántas canciones subió el usuario.
  /// Traemos TODAS y filtramos en Dart, porque muchas canciones viejas
  /// tienen `creadoPor` guardado con distintos formatos o vacío.
  Future<int> contarPorUsuario(String uid) async {
    if (uid.isEmpty) return 0;
    try {
      final snap = await _db.collection('canciones').get();
      int total = 0;
      for (final doc in snap.docs) {
        final d = doc.data();
        final creadoPor = (d['creadoPor'] ?? '').toString().trim();
        if (creadoPor == uid) total++;
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Suma todas las reproducciones de las canciones subidas por el usuario.
  /// Mismo criterio que `contarPorUsuario` (filtramos en Dart).
  Future<int> totalReproduccionesDeUsuario(String uid) async {
    if (uid.isEmpty) return 0;
    try {
      final snap = await _db.collection('canciones').get();
      int total = 0;
      for (final doc in snap.docs) {
        final d = doc.data();
        final creadoPor = (d['creadoPor'] ?? '').toString().trim();
        if (creadoPor == uid) {
          final r = d['reproducciones'];
          if (r is int) total += r;
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}