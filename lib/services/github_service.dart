// lib/services/github_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class ReleaseInfo {
  final int id;
  final String tag;
  final String nombre;
  final String notas;
  final DateTime? fecha;
  final bool prerelease;
  final String urlApk;
  final int tamanoBytes;
  final int build;

  ReleaseInfo({
    required this.id,
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
  String get versionLegible => tag.startsWith('v') ? tag.substring(1) : tag;

  factory ReleaseInfo.fromJson(Map<String, dynamic> j) {
    final tag = (j['tag_name'] ?? '').toString();
    final assets = (j['assets'] as List?) ?? [];
    String urlApk = '';
    int tamano = 0;
    for (final a in assets) {
      if ((a['name'] ?? '').toString().toLowerCase().endsWith('.apk')) {
        urlApk = (a['browser_download_url'] ?? '').toString();
        tamano = (a['size'] is int) ? a['size'] as int : 0;
        break;
      }
    }
    int build = 0;
    final partes = tag.replaceFirst('v', '').split('.');
    if (partes.isNotEmpty) build = int.tryParse(partes.last) ?? 0;

    return ReleaseInfo(
      id: j['id'] as int? ?? 0,
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

  // Lee el token de Firestore para evitar el límite de peticiones de GitHub
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Accept': 'application/vnd.github+json',
      'User-Agent': 'AllinKawsay-App',
    };
    try {
      final doc = await FirebaseFirestore.instance.collection('config').doc('github').get();
      final token = doc.data()?['token'] as String?;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    return headers;
  }

  static Future<List<ReleaseInfo>> listarReleases({int limite = 20}) async {
    final url = 'https://api.github.com/repos/$_repo/releases?per_page=$limite';
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());
    
    if (response.statusCode != 200) {
      if (response.statusCode == 403) {
        throw Exception('Límite de peticiones a GitHub alcanzado. Intenta más tarde.');
      }
      throw Exception('GitHub Error: ${response.statusCode}');
    }
    
    final data = jsonDecode(response.body) as List;
    return data.map((r) => ReleaseInfo.fromJson(r as Map<String, dynamic>)).toList();
  }

  static Future<List<ReleaseInfo>> listarEstables({int limite = 20}) async {
    final todas = await listarReleases(limite: limite);
    return todas.where((r) => !r.prerelease).toList();
  }

  static Future<List<ReleaseInfo>> listarTodas({int limite = 30}) async {
    final todas = await listarReleases(limite: limite);
    return todas; // Devuelve todas, tengan APK o no
  }

  static Future<bool> promoverAEstable(int releaseId) async {
    try {
      final headers = await _getHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception('Falta el token de GitHub en Firestore');
      }

      final url = 'https://api.github.com/repos/$_repo/releases/$releaseId';
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'prerelease': false,
          'make_latest': 'true',
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}