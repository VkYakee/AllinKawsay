import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id;
  final String titulo;
  final String descripcion;
  final String lugar;
  final DateTime fecha;
  final String creadoPor;
  final String creadorNombre;
  final DateTime? fechaCreacion;
  final DateTime? fechaEdicion;

  Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.lugar,
    required this.fecha,
    required this.creadoPor,
    required this.creadorNombre,
    this.fechaCreacion,
    this.fechaEdicion,
  });

  bool get esFuturo => fecha.isAfter(DateTime.now());

  /// Última modificación conocida del evento. Se usa para saber si
  /// es "nuevo" desde la última visita del usuario.
  DateTime get ultimaModificacion =>
      fechaEdicion ?? fechaCreacion ?? DateTime(2000);

  factory Evento.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Evento(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      descripcion: d['descripcion'] ?? '',
      lugar: d['lugar'] ?? '',
      fecha: (d['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      creadoPor: d['creadoPor'] ?? '',
      creadorNombre: d['creadorNombre'] ?? '',
      fechaCreacion: (d['fechaCreacion'] as Timestamp?)?.toDate(),
      fechaEdicion: (d['fechaEdicion'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'lugar': lugar,
        'fecha': Timestamp.fromDate(fecha),
        'creadoPor': creadoPor,
        'creadorNombre': creadorNombre,
        'fechaCreacion': FieldValue.serverTimestamp(),
      };
}