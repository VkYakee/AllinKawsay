// lib/screens/historia_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/historia.dart';
import '../services/historia_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import 'editar_historia_screen.dart';

class HistoriaScreen extends StatefulWidget {
  const HistoriaScreen({super.key});

  @override
  State<HistoriaScreen> createState() => _HistoriaScreenState();
}

class _HistoriaScreenState extends State<HistoriaScreen> {
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    UsuarioService().soyAdmin().then((a) {
      if (mounted) setState(() => _esAdmin = a);
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return AppScaffold(
      title: 'Nuestra Historia',
      actions: [
        if (_esAdmin)
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.dorado),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditarHistoriaScreen())),
          ),
      ],
      body: StreamBuilder<Historia>(
        stream: HistoriaService().stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.granate));
          }
          final h = snap.data;
          if (h == null || h.contenido.isEmpty) {
            return const AppEmptyState(
              icon: Icons.history_edu,
              title: 'Historia vacía',
              subtitle: 'El administrador aún no ha escrito la historia del grupo.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(Sp.lg),
            children: [
              AppCard(
                padding: const EdgeInsets.all(Sp.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(Sp.md),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_stories, color: AppColors.granate, size: 32),
                      ),
                    ),
                    const SizedBox(height: Sp.xl),
                    Text(
                      h.contenido,
                      style: AppType.body.copyWith(
                        fontSize: 16,
                        height: 1.8,
                        color: onSurface.withOpacity(0.9),
                      ),
                    ),
                    if (h.actualizadoPor.isNotEmpty) ...[
                      const SizedBox(height: Sp.xxl),
                      Divider(color: AppColors.dorado.withOpacity(0.2)),
                      const SizedBox(height: Sp.sm),
                      Text(
                        'Última edición por: ${h.actualizadoPor}',
                        style: AppType.captionXs.copyWith(color: onSurface.withOpacity(0.5), fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Sp.xxxl),
            ],
          );
        },
      ),
    );
  }
}