import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Servicio que gestiona OneSignal: registrar usuarios y enviar
/// notificaciones push.
class OneSignalService {
  /// App ID viene del build (--dart-define=ONESIGNAL_APP_ID=...).
  static const String _appId =
      String.fromEnvironment('ONESIGNAL_APP_ID', defaultValue: '');

  static const String _apiUrl =
      'https://onesignal.com/api/v1/notifications';

  static bool get estaConfigurado => _appId.isNotEmpty;

  /// Inicializa OneSignal. Llamar una vez al abrir la app.
  static Future<void> init() async {
    if (!estaConfigurado) {
      debugPrint('⚠️ OneSignal: falta ONESIGNAL_APP_ID');
      return;
    }
    try {
      OneSignal.initialize(_appId);

      // Pedir permiso de notificaciones (Android 13+)
      await OneSignal.Notifications.requestPermission(true);

      debugPrint('✅ OneSignal inicializado');
    } catch (e) {
      debugPrint('⚠️ Error al inicializar OneSignal: $e');
    }
  }

  /// Asocia el dispositivo del usuario logueado con su UID de Firebase.
  /// Llamar cuando el usuario entra a la app.
  static Future<void> login(String uid) async {
    if (!estaConfigurado) return;
    try {
      OneSignal.login(uid);
      debugPrint('✅ OneSignal: login $uid');
    } catch (e) {
      debugPrint('⚠️ OneSignal login error: $e');
    }
  }

  /// Desasocia el dispositivo cuando el usuario cierra sesión.
  static Future<void> logout() async {
    if (!estaConfigurado) return;
    try {
      OneSignal.logout();
      debugPrint('✅ OneSignal: logout');
    } catch (e) {
      debugPrint('⚠️ OneSignal logout error: $e');
    }
  }

  /// Lee la REST API Key desde Firestore (solo admins pueden).
  static Future<String?> _leerRestApiKey() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('onesignal')
          .get();
      if (!doc.exists) return null;
      final key = (doc.data()?['restApiKey'] ?? '').toString().trim();
      return key.isEmpty ? null : key;
    } catch (_) {
      return null;
    }
  }

  /// Envía una notificación push a TODOS los usuarios registrados.
  /// Solo funciona si el usuario logueado es admin (reglas Firestore).
  ///
  /// Devuelve true si se envió, false si falló.
  static Future<bool> enviarATodos({
    required String titulo,
    required String mensaje,
    Map<String, dynamic>? datos,
  }) async {
    if (!estaConfigurado) return false;

    final restKey = await _leerRestApiKey();
    if (restKey == null) {
      debugPrint('⚠️ OneSignal: falta restApiKey en config/onesignal');
      return false;
    }

    try {
      final body = {
        'app_id': _appId,
        'included_segments': ['All'],
        'headings': {'en': titulo, 'es': titulo},
        'contents': {'en': mensaje, 'es': mensaje},
        'priority': 10,
        'android_sound': 'default',
        if (datos != null) 'data': datos,
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $restKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Notificación enviada');
        return true;
      }

      debugPrint(
          '⚠️ OneSignal response ${response.statusCode}: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('⚠️ Error al enviar notificación: $e');
      return false;
    }
  }
}