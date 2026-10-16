import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cancion.dart';
import 'actividad_service.dart';

class CancionService {
  final _db = FirebaseFirestore.instance;

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
    await _incrementarContadorCanciones();
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

  /// Incrementa reproducciones SOLO si [uid] no está en la lista
  /// `usuariosQueReprodujeron` de la canción. Atómico y persistente.
  Future<bool> incrementarReproduccionUnaVez(
      String cancionId, String uid) async {
    if (cancionId.isEmpty || uid.isEmpty) return false;
    try {
      final ref = _db.collection('canciones').doc(cancionId);
      final doc = await ref.get();
      if (!doc.exists) return false;

      final lista = List<String>.from(
          doc.data()?['usuariosQueReprodujeron'] ?? <String>[]);
      if (lista.contains(uid)) return false;

      await ref.update({
        'reproducciones': FieldValue.increment(1),
        'usuariosQueReprodujeron': FieldValue.arrayUnion([uid]),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Compatibilidad: cuenta por usuario si se pasa uid, sino incrementa
  /// directo (para compatibilidad con código viejo).
  Future<void> incrementarReproduccion(String id, {String? uid}) async {
    if (uid != null && uid.isNotEmpty) {
      await incrementarReproduccionUnaVez(id, uid);
    } else {
      try {
        await _db.collection('canciones').doc(id).update({
          'reproducciones': FieldValue.increment(1),
        });
      } catch (_) {}
    }
  }

  Future<int> contarPorUsuario(String uid, {String? nombre}) async {
    if (uid.isEmpty) return 0;
    try {
      final snap = await _db.collection('canciones').get();
      int total = 0;
      final nombreLower = (nombre ?? '').trim().toLowerCase();
      for (final doc in snap.docs) {
        final d = doc.data();
        final creadoPor = (d['creadoPor'] ?? '').toString().trim();
        final creadorNombre =
            (d['creadorNombre'] ?? '').toString().trim().toLowerCase();
        // Cuenta si coincide el UID
        if (creadoPor == uid) {
          total++;
          continue;
        }
        // Fallback: si no hay UID pero el nombre coincide
        if (creadoPor.isEmpty &&
            nombreLower.isNotEmpty &&
            creadorNombre == nombreLower) {
          total++;
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<int> totalReproduccionesDeUsuario(String uid,
      {String? nombre}) async {
    if (uid.isEmpty) return 0;
    try {
      final snap = await _db.collection('canciones').get();
      int total = 0;
      final nombreLower = (nombre ?? '').trim().toLowerCase();
      for (final doc in snap.docs) {
        final d = doc.data();
        final creadoPor = (d['creadoPor'] ?? '').toString().trim();
        final creadorNombre =
            (d['creadorNombre'] ?? '').toString().trim().toLowerCase();
        final esMia = creadoPor == uid ||
            (creadoPor.isEmpty &&
                nombreLower.isNotEmpty &&
                creadorNombre == nombreLower);
        if (esMia) {
          final r = d['reproducciones'];
          if (r is int) total += r;
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Reasigna el `creadoPor`/`creadorNombre` de todas las canciones
  /// que coincidan con [nombre] pero tengan `creadoPor` vacío.
  /// Devuelve la cantidad de canciones actualizadas.
  Future<int> reasignarMisCanciones(String uid, String nombre) async {
    if (uid.isEmpty || nombre.isEmpty) return 0;
    final nombreLower = nombre.trim().toLowerCase();
    try {
      final snap = await _db.collection('canciones').get();
      int actualizadas = 0;
      for (final doc in snap.docs) {
        final d = doc.data();
        final creadoPor = (d['creadoPor'] ?? '').toString().trim();
        final creadorNombre =
            (d['creadorNombre'] ?? '').toString().trim().toLowerCase();
        if (creadoPor.isEmpty && creadorNombre == nombreLower) {
          await doc.reference.update({
            'creadoPor': uid,
            'creadorNombre': nombre,
          });
          actualizadas++;
        }
      }
      return actualizadas;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _incrementarContadorCanciones() async {
    try {
      final ref = _db.collection('config').doc('notificaciones');
      await ref.set({
        'cancionesPendientes': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<int> contarCancionesPendientes() async {
    try {
      final doc =
          await _db.collection('config').doc('notificaciones').get();
      if (!doc.exists) return 0;
      final n = doc.data()?['cancionesPendientes'];
      return (n is int) ? n : 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> resetearContadorCanciones() async {
    try {
      await _db
          .collection('config')
          .doc('notificaciones')
          .set({'cancionesPendientes': 0}, SetOptions(merge: true));
    } catch (_) {}
  }
}