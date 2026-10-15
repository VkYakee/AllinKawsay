import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evento.dart';
import 'actividad_service.dart';
import 'onesignal_service.dart';

class EventoService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Evento>> listar() {
    return _db
        .collection('eventos')
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(Evento.fromDoc).toList());
  }

  Future<String> agregar(Evento e) async {
    final ref = await _db.collection('eventos').add(e.toMap());
    ActividadService.registrar(
      'crear_evento',
      'Creó el evento "${e.titulo}"',
    );
    // Enviar notificación push a todos (fire-and-forget)
    _notificarEvento(e);
    return ref.id;
  }

  Future<void> actualizar(String id, Map<String, dynamic> cambios) async {
    await _db.collection('eventos').doc(id).update({
      ...cambios,
      'fechaEdicion': FieldValue.serverTimestamp(),
    });
    final titulo = cambios['titulo'] ?? id;
    ActividadService.registrar(
      'editar_evento',
      'Editó el evento "$titulo"',
    );
  }

  Future<void> eliminar(String id) async {
    String titulo = id;
    try {
      final doc = await _db.collection('eventos').doc(id).get();
      if (doc.exists) {
        titulo = (doc.data()?['titulo'] ?? id).toString();
      }
    } catch (_) {}

    await _db.collection('eventos').doc(id).delete();
    ActividadService.registrar(
      'eliminar_evento',
      'Eliminó el evento "$titulo"',
    );
  }

  /// Envía la notificación push silenciosamente.
  void _notificarEvento(Evento e) {
    final fecha = '${e.fecha.day}/${e.fecha.month}/${e.fecha.year}';
    final hora = '${e.fecha.hour.toString().padLeft(2, '0')}:'
        '${e.fecha.minute.toString().padLeft(2, '0')}';
    final mensaje = e.lugar.isEmpty
        ? '📅 $fecha · $hora'
        : '📅 $fecha · $hora · ${e.lugar}';

    OneSignalService.enviarATodos(
      titulo: '🎉 Nuevo evento: ${e.titulo}',
      mensaje: mensaje,
      datos: {
        'tipo': 'evento',
        'eventoId': e.id,
      },
    );
  }
}