import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa la versión aprobada por el admin, guardada en
/// `config/ultimaAprobada` en Firestore.
class InfoVersion {
  final int build;
  final String version;
  final String url;
  final bool critica;
  final String notas;
  final String aprobadaPor;
  final DateTime? fecha;

  InfoVersion({
    required this.build,
    required this.version,
    required this.url,
    this.critica = false,
    this.notas = '',
    this.aprobadaPor = '',
    this.fecha,
  });

  bool esMasNueva(int buildActual) => build > buildActual;

  /// Devuelve la versión sin el build interno.
  /// Ej: "1.2.0.1.826" -> "1.2.0.1"
  String get displayVersion {
    final partes = version.split('.');
    if (partes.length >= 4) {
      return partes.sublist(0, 4).join('.');
    }
    return version;
  }

  factory InfoVersion.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>?;
    if (d == null) {
      return InfoVersion(build: 0, version: '', url: '');
    }
    return InfoVersion(
      build: (d['build'] is int) ? d['build'] : 0,
      version: (d['version'] ?? '').toString(),
      url: (d['url'] ?? '').toString(),
      critica: d['critica'] == true,
      notas: (d['notas'] ?? '').toString(),
      aprobadaPor: (d['aprobadaPor'] ?? '').toString(),
      fecha: (d['fecha'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'build': build,
        'version': version,
        'url': url,
        'critica': critica,
        'notas': notas,
        'aprobadaPor': aprobadaPor,
        'fecha': FieldValue.serverTimestamp(),
      };
}