import 'version_build.dart';

class AppVersion {
  // ⚠️ EDITAR MANUALMENTE cuando haya actualizaciones importantes
  //
  // MAJOR: cambios mega grandes (raro).
  // MINOR: nuevas funcionalidades grandes.
  // PATCH: correcciones o cambios chicos.
  // RELEASE: contador de lanzamientos del mismo patch.

  static const String major = '2';
  static const String minor = '0'; // Subido por el setlist/timing
  static const String patch = '0';
  static const String release = '0';

  static const int build = VersionBuild.build;

  /// Lo que ve el usuario: 1.2.0.1
  static String get display => '$major.$minor.$patch.$release';

  /// Uso interno: 1.2.0.1.826
  static String get full => '$major.$minor.$patch.$release.$build';

  /// Versión corta sin build ni release: 1.2.0
  static String get short => '$major.$minor.$patch';
}