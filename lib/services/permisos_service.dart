import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/dialogo_permiso.dart';

/// Servicio centralizado de permisos. Pide al usuario con explicación
/// y, si denegó permanentemente, ofrece abrir los ajustes del sistema.
class PermisosService {
  /// Pide permiso de cámara.
  static Future<bool> pedirCamara(BuildContext context) {
    return _pedir(
      context,
      permiso: Permission.camera,
      titulo: 'Permiso de cámara',
      mensaje: 'Necesitamos acceso a la cámara para que puedas '
          'tomar fotos de las partituras o grabar videos.',
    );
  }

  /// Pide permiso de fotos/galería.
  static Future<bool> pedirGaleria(BuildContext context) {
    return _pedir(
      context,
      permiso: Permission.photos,
      titulo: 'Permiso de galería',
      mensaje: 'Necesitamos acceso a tus fotos para que puedas '
          'elegir imágenes desde la galería.',
    );
  }

  /// Pide permiso de videos.
  static Future<bool> pedirVideos(BuildContext context) {
    return _pedir(
      context,
      permiso: Permission.videos,
      titulo: 'Permiso de videos',
      mensaje: 'Necesitamos acceso a tus videos para adjuntarlos '
          'a los recuerdos del grupo.',
    );
  }

  /// Pide permiso de audio.
  static Future<bool> pedirAudio(BuildContext context) {
    return _pedir(
      context,
      permiso: Permission.audio,
      titulo: 'Permiso de audio',
      mensaje: 'Necesitamos acceso a tus archivos de audio para '
          'que puedas subir las pistas de las canciones.',
    );
  }

  /// Pide permiso de notificaciones.
  static Future<bool> pedirNotificaciones(BuildContext context) {
    return _pedir(
      context,
      permiso: Permission.notification,
      titulo: 'Permiso de notificaciones',
      mensaje: 'Necesitamos permiso para mostrarte cuándo hay '
          'nuevas canciones, eventos o actualizaciones.',
    );
  }

  /// Alias para galería + videos juntos (útil en recuerdos).
  static Future<bool> pedirGaleriaYVideos(BuildContext context) async {
    final fotos = await pedirGaleria(context);
    if (!context.mounted) return false;
    final videos = await pedirVideos(context);
    return fotos && videos;
  }

  /// Implementación interna.
  static Future<bool> _pedir(
    BuildContext context, {
    required Permission permiso,
    required String titulo,
    required String mensaje,
  }) async {
    // 1) Ver si ya está concedido
    var status = await permiso.status;
    if (status.isGranted || status.isLimited) return true;

    // 2) Si el usuario denegó permanentemente, ofrecer ajustes
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await DialogoPermiso.mostrar(
          context,
          titulo: titulo,
          mensaje: '$mensaje\n\n'
              'Parece que denegaste este permiso anteriormente. '
              'Podés habilitarlo manualmente desde los ajustes '
              'del sistema.',
        );
      }
      return false;
    }

    // 3) Pedirlo
    status = await permiso.request();
    return status.isGranted || status.isLimited;
  }
}