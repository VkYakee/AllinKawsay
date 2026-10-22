// lib/widgets/dialogo_permiso.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../design/design.dart';
import '../theme/colors.dart';

class DialogoPermiso {
  static Future<void> mostrar(BuildContext context, {required String titulo, required String mensaje}) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Rad.rXl),
        title: Row(
          children: [
            Container(padding: const EdgeInsets.all(Sp.sm), decoration: const BoxDecoration(gradient: AppColors.gradienteGranate, shape: BoxShape.circle), child: const Icon(Icons.lock, color: AppColors.dorado, size: 18)),
            const SizedBox(width: Sp.sm),
            Expanded(child: Text(titulo, style: AppType.h3.copyWith(color: AppColors.granate))),
          ],
        ),
        content: Text(mensaje, style: AppType.bodySm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('AHORA NO')),
          TextButton(onPressed: () { Navigator.pop(context); openAppSettings(); }, child: const Text('ABRIR AJUSTES')),
        ],
      ),
    );
  }
}