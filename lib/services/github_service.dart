import 'dart:convert';
import 'package:http/http.dart' as http;

/// Representa un release público del repo de GitHub.
class ReleaseInfo {
  final String tag;
  final String nombre;
  final String notas;
  final DateTime? fecha;
  final bool prerelease;
  final String urlApk;
  final int tamanoBytes;

  /// Build number extraído del tag, ej: "v1.1.2.520" → 520.
  /// Si no se puede, queda en 0.
  final int build;

  ReleaseInfo({
    required this.tag,
    required this.nombre,
    required this.notas,
    this.fecha,
    required this.prerelease,
    required this.urlApk,
    required this.tamanoBytes,
    required this.build,
  });

  bool get tieneApk => urlApk.isNotEmpty;

  String get tamanoMb => (tamanoBytes / 1048576).toStringAsFixed(2);

  String get versionLegible =>
      tag.startsWith('v') ? tag.substring(1) : tag;

  factory ReleaseInfo.fromJson(Map<String, dynamic> j) {
    final tag = (j['tag_name'] ?? '').toString();
    final assets = (j['assets'] as List?) ?? [];

    String urlApk = '';
    int tamano = 0;
    for (final a in assets) {
      final n = (a['name'] ?? '').toString().toLowerCase();
      if (n.endsWith('.apk')) {
        urlApk = (a['browser_download_url'] ?? '').toString();
        tamano = (a['size'] is int) ? a['size'] as int : 0;
        break;
      }
    }

    int build = 0;
    final sinV = tag.replaceFirst('v', '');
    final partes = sinV.split('.');
    if (partes.isNotEmpty) {
      build = int.tryParse(partes.last) ?? 0;
    }

    return ReleaseInfo(
      tag: tag,
      nombre: (j['name'] ?? tag).toString(),
      notas: (j['body'] ?? '').toString(),
      fecha: DateTime.tryParse((j['published_at'] ?? '').toString()),
      prerelease: j['prerelease'] == true,
      urlApk: urlApk,
      tamanoBytes: tamano,
      build: build,
    );
  }
}
class GithubService {
  static const _repo = 'yeo-drake/AllinKawsay';

  /// Lista releases públicos del repo (más reciente primero).
  /// No requiere auth (repo público, rate limit 60/hora).
  static Future<List<ReleaseInfo>> listarReleases({int limite = 20}) async {
    final url =
        'https://api.github.com/repos/$_repo/releases?per_page=$limite';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'AllinKawsay-App',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'GitHub respondió ${response.statusCode}. Intentá más tarde.');
    }

    final data = jsonDecode(response.body) as List;
    return data
        .map((r) => ReleaseInfo.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Devuelve solo las releases que tengan un APK adjunto.
  static Future<List<ReleaseInfo>> listarConApk({int limite = 20}) async {
    final todas = await listarReleases(limite: limite);
    return todas.where((r) => r.tieneApk).toList();
  }
}