import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/info_version.dart';
import '../version_build.dart';

class UpdateService {
  static final _db = FirebaseFirestore.instance;

  /// Lee `config/ultimaAprobada` y devuelve la info, o null si
  /// no existe o falla la lectura (por red o reglas).
  static Future<InfoVersion?> ultimaAprobada() async {
    try {
      final doc = await _db
          .collection('config')
          .doc('ultimaAprobada')
          .get();
      if (!doc.exists) return null;
      return InfoVersion.fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  /// Devuelve la info SOLO si hay una versión nueva comparada con
  /// el build actual compilado. Caso contrario null.
  static Future<InfoVersion?> hayActualizacion() async {
    final info = await ultimaAprobada();
    if (info == null) return null;
    if (info.url.isEmpty) return null;
    if (!info.esMasNueva(VersionBuild.build)) return null;
    return info;
  }

  /// Compara el build actual con [otroBuild].
  static bool esMasNuevaQue(int otroBuild) => VersionBuild.build < otroBuild;
}