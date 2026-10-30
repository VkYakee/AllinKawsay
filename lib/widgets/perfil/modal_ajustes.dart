// lib/widgets/perfil/modal_ajustes.dart
import 'package:flutter/material.dart';

import '../../design/design.dart';
import '../../features/perfil/screens/gestion_cache_screen.dart';
import '../../theme/colors.dart';
import '../../theme/theme_provider.dart';

class ModalAjustes {
  static void mostrar(BuildContext context, VoidCallback onReasignar) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: Sp.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.3),
                  borderRadius: Rad.rPill,
                ),
              ),
              const SizedBox(height: Sp.lg),
              Text('Ajustes', style: AppType.h3),
              const Divider(),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeProvider.mode,
                builder: (context, modo, _) {
                  return Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: modo,
                        title: const Text('Claro'),
                        activeColor: AppColors.granate,
                        onChanged: (v) =>
                            ThemeProvider.cambiar(ThemeMode.light),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: modo,
                        title: const Text('Oscuro'),
                        activeColor: AppColors.granate,
                        onChanged: (v) =>
                            ThemeProvider.cambiar(ThemeMode.dark),
                      ),
                      RadioListTile<ThemeMode>(
                        value: ThemeMode.system,
                        groupValue: modo,
                        title: const Text('Automático'),
                        activeColor: AppColors.granate,
                        onChanged: (v) =>
                            ThemeProvider.cambiar(ThemeMode.system),
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.storage, color: AppColors.granate),
                title: const Text('Almacenamiento'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const GestionCacheScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.assignment_ind,
                    color: AppColors.granate),
                title: const Text('Reasignar mis subidas'),
                onTap: () {
                  Navigator.pop(context);
                  onReasignar();
                },
              ),
              const SizedBox(height: Sp.xl),
            ],
          ),
        ),
      ),
    );
  }
}