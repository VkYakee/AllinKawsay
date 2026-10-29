// lib/models/evento.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id;
  final String titulo;
  final String descripcion;
  final String lugar;
  final DateTime fecha;
  final double? lat; // <-- NUEVO
  final double? lng; // <-- NUEVO
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
    this.lat,
    this.lng,
    required this.creadoPor,
    required this.creadorNombre,
    this.fechaCreacion,
    this.fechaEdicion,
  });

  bool get esFuturo => fecha.isAfter(DateTime.now());

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
      lat: (d['lat'] as num?)?.toDouble(),
      lng: (d['lng'] as num?)?.toDouble(),
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
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'creadoPor': creadoPor,
        'creadorNombre': creadorNombre,
        'fechaCreacion': FieldValue.serverTimestamp(),
      };
}