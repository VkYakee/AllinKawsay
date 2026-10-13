import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/info_version.dart';
import '../version_build.dart';

class UpdateService {
  static final _db = FirebaseFirestore.instance;
  static const _docId = 'ultimaAprobada';

  /// Lee el doc crudo `config/ultimaAprobada` (sin filtros).
  static Future<InfoVersion?> actual() async {
    try {
      final doc =
          await _db.collection('config').doc(_docId).get();
      if (!doc.exists) return null;
      return InfoVersion.fromDoc(doc);
    } catch (_) {
      return null;
    }
  }

  /// Devuelve info SOLO si hay una versión más nueva que la instalada
  /// y tiene URL de APK. Caso contrario null.
  static Future<InfoVersion?> hayActualizacion() async {
    final info = await actual();
    if (info == null) return null;
    if (info.url.isEmpty) return null;
    if (!info.esMasNueva(VersionBuild.build)) return null;
    return info;
  }

  static bool esMasNuevaQue(int otroBuild) =>
      VersionBuild.build < otroBuild;

  static int get buildInstalado => VersionBuild.build;
  /// Escribe `config/ultimaAprobada` con los datos de [info].
  /// Solo funciona si el usuario autenticado es admin (regla Firestore).
  static Future<void> aprobar(InfoVersion info) async {
    await _db
        .collection('config')
        .doc(_docId)
        .set(info.toMap(), SetOptions(merge: false));
  }

  /// Borra el doc `config/ultimaAprobada`.
  /// Después de esto, nadie verá aviso de actualización.
  static Future<void> desactivar() async {
    await _db.collection('config').doc(_docId).delete();
  }
}