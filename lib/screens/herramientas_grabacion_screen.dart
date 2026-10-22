// lib/screens/herramientas_grabacion_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';
import 'grabar_partitura_screen.dart';
import 'grabar_timing_screen.dart';

class HerramientasGrabacionScreen extends StatefulWidget {
  final List<EstrofaNumerofonia> estrofas;
  const HerramientasGrabacionScreen({super.key, required this.estrofas});

  @override
  State<HerramientasGrabacionScreen> createState() => _HerramientasGrabacionScreenState();
}

class _HerramientasGrabacionScreenState extends State<HerramientasGrabacionScreen> {
  late List<EstrofaNumerofonia> _estrofas;

  @override
  void initState() {
    super.initState();
    _estrofas = widget.estrofas.map((e) => e.copy()).toList();
  }

  Future<void> _grabarPartitura(int index) async {
    final res = await Navigator.push<EstrofaNumerofonia>(
      context,
      MaterialPageRoute(builder: (_) => GrabarPartituraScreen(estrofaInicial: _estrofas[index].copy())),
    );
    if (res != null && mounted) {
      setState(() => _estrofas[index] = res);
    }
  }

  Future<void> _grabarTiming(int index) async {
    final tieneTimings = _estrofas[index].columnas.any((c) => c.timings7.isNotEmpty || c.timings6.isNotEmpty);
    if (tieneTimings) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Sobrescribir timing'),
          content: const Text('Esta estrofa ya tiene un timing grabado. ¿Deseas reemplazarlo?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continuar')),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (!mounted) return;
    
    final res = await Navigator.push<EstrofaNumerofonia>(
      context,
      MaterialPageRoute(builder: (_) => GrabarTimingScreen(estrofa: _estrofas[index].copy())),
    );
    if (res != null && mounted) {
      setState(() => _estrofas[index] = res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Herramientas de Grabación',
      subtitle: 'Selecciona una estrofa',
      actions: [
        IconButton(
          icon: const Icon(Icons.check, color: AppColors.dorado),
          onPressed: () => Navigator.pop(context, _estrofas),
          tooltip: 'Guardar cambios',
        ),
      ],
      body: ListView.builder(
        padding: const EdgeInsets.all(Sp.lg),
        itemCount: _estrofas.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Sp.md),
            child: AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Sp.sm),
                        decoration: BoxDecoration(color: AppColors.granate.withOpacity(0.1), borderRadius: Rad.rMd),
                        child: Text('E${i + 1}', style: AppType.subtitle.copyWith(color: AppColors.granate)),
                      ),
                      const SizedBox(width: Sp.md),
                      Expanded(
                        child: Text(
                          'Estrofa ${i + 1}',
                          style: AppType.subtitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'GRABAR PARTITURA',
                          icon: Icons.piano,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => _grabarPartitura(i),
                        ),
                      ),
                      const SizedBox(width: Sp.sm),
                      Expanded(
                        child: AppButton(
                          label: 'GRABAR TIMING',
                          icon: Icons.timer,
                          variant: AppButtonVariant.secondary,
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