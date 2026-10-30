// lib/features/historia/screens/editar_historia_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../models/historia.dart';
import '../../../services/historia_service.dart';
import '../../../theme/colors.dart';

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
      final user = FirebaseAuth.instance.currentUser!;
      await HistoriaService().guardar(Historia(
        contenido: _ctrl.text.trim(),
        actualizadoPor: user.displayName ?? user.email ?? 'Admin',
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
    return AppScaffold(
      title: 'Editar Historia',
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: _guardando ? null : _guardar,
        ),
      ],
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.granate),
            )
          : ListView(
              padding: const EdgeInsets.all(Sp.lg),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(Sp.lg),
                  child: Column(
                    children: [
                      const SeccionHeader(
                        title: 'Contenido de la Historia',
                        icon: Icons.edit_note,
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: Sp.md),
                      AppInput(
                        controller: _ctrl,
                        label: 'Historia del grupo',
                        hint:
                            'Escribe aquí los orígenes, logros y anécdotas del grupo...',
                        maxLines: 20,
                        minLines: 15,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Sp.xl),
                AppButton(
                  label: _guardando ? 'GUARDANDO...' : 'GUARDAR HISTORIA',
                  fullWidth: true,
                  loading: _guardando,
                  onPressed: _guardar,
                ),
                const SizedBox(height: Sp.xxxl),
              ],
            ),
    );
  }
}