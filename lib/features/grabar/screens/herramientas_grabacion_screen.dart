// lib/features/grabar/screens/herramientas_grabacion_screen.dart
import 'package:flutter/material.dart';

import '../../../core/components/allin_button.dart';
import '../../../core/components/allin_dialog.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/numerofonia.dart';
import 'grabar_partitura_screen.dart';
import 'grabar_timing_screen.dart';

class HerramientasGrabacionScreen extends StatefulWidget {
  final List<EstrofaNumerofonia> estrofas;
  const HerramientasGrabacionScreen({super.key, required this.estrofas});

  @override
  State<HerramientasGrabacionScreen> createState() =>
      _HerramientasGrabacionScreenState();
}

class _HerramientasGrabacionScreenState
    extends State<HerramientasGrabacionScreen> {
  late List<EstrofaNumerofonia> _estrofas;

  @override
  void initState() {
    super.initState();
    _estrofas = widget.estrofas.map((e) => e.copy()).toList();
  }

  Future<void> _grabarPartitura(int index) async {
    final res = await Navigator.push<EstrofaNumerofonia>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GrabarPartituraScreen(estrofaInicial: _estrofas[index].copy()),
      ),
    );
    if (res != null && mounted) {
      setState(() => _estrofas[index] = res);
    }
  }

  Future<void> _grabarTiming(int index) async {
    final tieneTimings = _estrofas[index].columnas.any(
      (c) => c.timings7.isNotEmpty || c.timings6.isNotEmpty,
    );
    if (tieneTimings) {
      final ok = await AllinDialog.confirm(
        context: context,
        titulo: 'Sobrescribir timing',
        mensaje:
            'Esta estrofa ya tiene un timing grabado. ¿Deseas reemplazarlo?',
        confirmLabel: 'Continuar',
        cancelLabel: 'Cancelar',
        icono: Icons.timer_outlined,
      );
      if (ok != true) return;
    }
    if (!mounted) return;

    final res = await Navigator.push<EstrofaNumerofonia>(
      context,
      MaterialPageRoute(
        builder: (_) => GrabarTimingScreen(estrofa: _estrofas[index].copy()),
      ),
    );
    if (res != null && mounted) {
      setState(() => _estrofas[index] = res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        title: Text(
          'Herramientas de Grabación',
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
            onPressed: () => Navigator.pop(context, _estrofas),
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(Sp.lg),
        itemCount: _estrofas.length,
        itemBuilder: (context, i) {
          final estrofa = _estrofas[i];
          final tieneNotas = estrofa.columnas.isNotEmpty;
          final tieneTiming = estrofa.columnas.any(
            (c) => c.timings7.isNotEmpty || c.timings6.isNotEmpty,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: Sp.md),
            child: AppCard(
              glass: true,
              padding: const EdgeInsets.all(Sp.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.granateProfundo,
                              AppColors.granateOscuro,
                            ],
                          ),
                          borderRadius: Rad.rSm,
                          border: Border.all(
                            color: AppColors.dorado.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'E${i + 1}',
                          style: const TextStyle(
                            color: AppColors.dorado,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: Sp.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estrofa ${i + 1}',
                              style: AppText.subtitle.copyWith(
                                color: AppColors.onSurface(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${estrofa.columnas.length} compases · ${tieneTiming ? "Timing grabado" : "Sin timing"}',
                              style: AppText.caption.copyWith(
                                color: AppColors.onSurfaceVariant(context),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (tieneNotas)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.dorado,
                          size: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: Sp.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AllinButton(
                          label: 'PARTITURA',
                          icono: Icons.music_note_rounded,
                          variant: AllinButtonVariant.glass,
                          expand: true,
                          onPressed: () => _grabarPartitura(i),
                        ),
                      ),
                      const SizedBox(width: Sp.sm),
                      Expanded(
                        child: AllinButton(
                          label: 'TIMING',
                          icono: Icons.timer_rounded,
                          variant: AllinButtonVariant.gold,
                          expand: true,
                          onPressed: () => _grabarTiming(i),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
