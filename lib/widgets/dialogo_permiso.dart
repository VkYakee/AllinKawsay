// lib/widgets/dialogo_permiso.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/components/allin_dialog.dart';

class DialogoPermiso {
  static Future<void> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
  }) async {
    final ok = await AllinDialog.confirm(
      context,
      title: titulo,
      message: mensaje,
      confirmText: 'Abrir Ajustes',
      cancelText: 'Ahora no',
      icon: Icons.security_rounded,
    );

    if (ok == true) {
      openAppSettings();
    }
  }
}
