// lib/widgets/admin/categoria_modal.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/categoria.dart';
import '../../services/categoria_service.dart';
import '../../theme/colors.dart';

class CategoriaModal {
  static void mostrar(BuildContext context, {Categoria? categoria}) {
    final nombreCtrl = TextEditingController(text: categoria?.nombre ?? '');
    final emojiCtrl = TextEditingController(text: categoria?.emoji ?? '📁');
    final ordenCtrl = TextEditingController(text: (categoria?.orden ?? 0).toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(Sp.xl),
              decoration: BoxDecoration(
                color: AppColors.cardColor(ctx).withOpacity(0.9),
                border: Border(top: BorderSide(color: AppColors.dorado.withOpacity(0.3), width: 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: AppColors.granate.withOpacity(0.3), borderRadius: Rad.rPill),
                    ),
                  ),
                  const SizedBox(height: Sp.lg),
                  Text(categoria == null ? 'Nueva Categoría' : 'Editar Categoría', style: AppType.h3, textAlign: TextAlign.center),
                  const SizedBox(height: Sp.xl),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: AppInput(controller: emojiCtrl, label: 'Emoji', hint: '📁'),
                      ),
                      const SizedBox(width: Sp.md),
                      Expanded(
                        child: AppInput(controller: nombreCtrl, label: 'Nombre', hint: 'Ej: Carnaval'),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.md),
                  AppInput(controller: ordenCtrl, label: 'Orden (0 = primero)', keyboardType: TextInputType.number),
                  const SizedBox(height: Sp.xl),
                  AppButton(
                    label: categoria == null ? 'CREAR' : 'GUARDAR',
                    fullWidth: true,
                    onPressed: () async {
                      final nombre = nombreCtrl.text.trim();
                      if (nombre.isEmpty) return;
                      final emoji = emojiCtrl.text.trim().isEmpty ? '📁' : emojiCtrl.text.trim();
                      final orden = int.tryParse(ordenCtrl.text.trim()) ?? 0;

                      if (categoria == null) {
                        await CategoriaService().agregar(Categoria(id: '', nombre: nombre, emoji: emoji, orden: orden));
                      } else {
                        await CategoriaService().actualizar(categoria.id, {'nombre': nombre, 'emoji': emoji, 'orden': orden});
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: Sp.sm),
                  AppButton(
                    label: 'CANCELAR',
                    variant: AppButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}