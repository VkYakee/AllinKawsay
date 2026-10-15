import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recuerdo.dart';
import 'actividad_service.dart';
import 'onesignal_service.dart';

class RecuerdoService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Recuerdo>> listar() {
    return _db
        .collection('recuerdos')
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Recuerdo.fromDoc).toList());
  }

  Future<String> agregar(Recuerdo r) async {
    final ref = await _db.collection('recuerdos').add(r.toMapCrear());
    ActividadService.registrar(
      'crear_recuerdo',
      'Subió el recuerdo "${r.titulo}" (${r.fotos.length} fotos, ${r.videos.length} videos)',
    );
    // Notificación push a todos
    _notificarRecuerdo(r);
    return ref.id;
  }

  Future<void> actualizar(String id, Recuerdo r) async {
    await _db.collection('recuerdos').doc(id).update(r.toMapEditar());
    ActividadService.registrar(
      'editar_recuerdo',
      'Editó el recuerdo "${r.titulo}"',
    );
  }

  Future<void> eliminar(String id) async {
    String titulo = id;
    try {
      final doc = await _db.collection('recuerdos').doc(id).get();
      if (doc.exists) {
        titulo = (doc.data()?['titulo'] ?? id).toString();
      }
    } catch (_) {}
    await _db.collection('recuerdos').doc(id).delete();
    ActividadService.registrar(
      'eliminar_recuerdo',
      'Eliminó el recuerdo "$titulo"',
    );
  }

  /// Envía la notificación push silenciosamente (fire-and-forget).
  void _notificarRecuerdo(Recuerdo r) {
    final total = r.fotos.length + r.videos.length;
    final detalle = <String>[];
    if (r.fotos.isNotEmpty) {
      detalle.add('${r.fotos.length} foto${r.fotos.length == 1 ? '' : 's'}');
    }
    if (r.videos.isNotEmpty) {
      detalle.add('${r.videos.length} video${r.videos.length == 1 ? '' : 's'}');
    }
    final mensaje = detalle.isEmpty
        ? 'Tocá para verlo'
        : '${detalle.join(' · ')} · Tocá para ver';

    OneSignalService.enviarATodos(
      titulo: '📸 Nuevo recuerdo: ${r.titulo}',
      mensaje: mensaje,
      datos: {
        'tipo': 'recuerdo',
        'recuerdoId': r.id,
        'totalMedia': total,
      },
    );
  }
}