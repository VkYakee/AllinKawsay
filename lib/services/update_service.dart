import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/info_version.dart';
import '../version_build.dart';
import 'onesignal_service.dart';

class UpdateService {
  static final _db = FirebaseFirestore.instance;
  static const _docId = 'ultimaAprobada';

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

  static Future<void> aprobar(InfoVersion info) async {
    await _db
        .collection('config')
        .doc(_docId)
        .set(info.toMap(), SetOptions(merge: false));

    // Enviar notificación push a todos
    final mensaje = info.critica
        ? '⚠️ Actualización obligatoria. Actualizá para seguir usando la app.'
        : '📲 Hay una nueva versión disponible. Tocá para actualizar.';
    OneSignalService.enviarATodos(
      titulo: '🚀 Nueva versión v${info.version}.${info.build}',
      mensaje: mensaje,
      datos: {
        'tipo': 'actualizacion',
        'build': info.build,
        'version': info.version,
      },
    );
  }

  static Future<void> desactivar() async {
    await _db.collection('config').doc(_docId).delete();
  }
}