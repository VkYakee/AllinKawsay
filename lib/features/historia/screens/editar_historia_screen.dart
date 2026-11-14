// lib/features/historia/screens/editar_historia_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/components/allin_loading_siku.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/historia.dart';
import '../../../services/historia_service.dart';

class EditarHistoriaScreen extends StatefulWidget {
  const EditarHistoriaScreen({super.key});

  @override
  State<EditarHistoriaScreen> createState() => _EditarHistoriaScreenState();
}

class _EditarHistoriaScreenState extends State<EditarHistoriaScreen> {
  final _ctrl = TextEditingController();
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    HistoriaService().obtener().then((h) {
      if (mounted) {
        _ctrl.text = h.contenido;
        setState(() => _cargando = false);
      }
    });
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final autor = user?.displayName ?? user?.email ?? 'Admin';
      await HistoriaService().guardar(Historia(
        contenido: _ctrl.text.trim(),
        actualizadoPor: autor,
      ));
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        title: Text(
          'Editar Historia',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        backgroundColor: AppColors.fondoOscuro,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.dorado),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: AppColors.dorado),
            onPressed: _guardando ? null : _guardar,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: AllinLoadingSiku(mensaje: 'Cargando texto...'),
            )
          : ListView(
              padding: const EdgeInsets.all(Sp.lg),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            color: AppColors.dorado,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Contenido de la Historia',
                            style: AppText.h3.copyWith(
                              color: AppColors.dorado,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sp.sm),
                      Text(
                        'Separa los párrafos con una línea en blanco para organizarlos automáticamente en capítulos cronológicos.',
                        style: AppText.caption.copyWith(
                          color: AppColors.onSurfaceVariant(context),
                        ),
                      ),
                      const SizedBox(height: Sp.md),
                      TextField(
                        controller: _ctrl,
                        maxLines: 18,
                        minLines: 12,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppText.body.copyWith(
                          color: AppColors.onSurface(context),
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Escribe aquí los orígenes, fundación, presentaciones en Candelaria y anécdotas...',
                          hintStyle: AppText.caption.copyWith(
                            color: AppColors.onSurfaceVariant(context),
                          ),
                          filled: true,
                          fillColor:
                              AppColors.surfaceVariant(context).withOpacity(0.35),
                          border: OutlineInputBorder(
                            borderRadius: Rad.rMd,
                            borderSide: BorderSide(color: AppColors.border(context)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: Rad.rMd,
                            borderSide: const BorderSide(
                              color: AppColors.dorado,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Sp.xl),
                AllinButton(
                  label: _guardando ? 'GUARDANDO...' : 'GUARDAR HISTORIA',
                  variant: AllinButtonVariant.gold,
                  expand: true,
                  loading: _guardando,
                  icono: Icons.save_rounded,
                  onPressed: _guardar,
                ),
                const SizedBox(height: Sp.xxxl),
              ],
            ),
    );
  }
}
