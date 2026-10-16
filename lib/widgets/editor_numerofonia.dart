import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/numerofonia.dart';
import '../screens/grabar_partitura_screen.dart';
import '../screens/grabar_timing_screen.dart';
import '../theme/colors.dart';

class EditorNumerofonia extends StatefulWidget {
  final List<EstrofaNumerofonia>? estrofas;
  final List<EstrofaNumerofonia>? inicial;
  final ValueChanged<List<EstrofaNumerofonia>>? onChanged;

  const EditorNumerofonia({
    super.key,
    this.estrofas,
    this.inicial,
    this.onChanged,
  });

  @override
  State<EditorNumerofonia> createState() => _EditorNumerofoniaState();
}

class _EditorNumerofoniaState extends State<EditorNumerofonia> {
  late List<EstrofaNumerofonia> _estrofas;

  @override
  void initState() {
    super.initState();
    _estrofas = widget.estrofas ?? widget.inicial ?? <EstrofaNumerofonia>[];
    if (_estrofas.isEmpty || _estrofas.every((e) => e.vacia)) {
      _estrofas.clear();
      while (_estrofas.length < 3) {
        _estrofas.add(EstrofaNumerofonia.nueva());
      }
    }
  }

  void _notify() => widget.onChanged?.call(_estrofas);

  Future<void> _abrirGrabador(int i) async {
    final resultado = await Navigator.push<EstrofaNumerofonia>(
      context,
      MaterialPageRoute(
        builder: (_) => GrabarPartituraScreen(
          estrofaInicial: _estrofas[i].copy(),
        ),
      ),
    );
    if (resultado == null) return;

    var estrofa = resultado;
    if (estrofa.columnas.isEmpty) {
      estrofa = EstrofaNumerofonia.nueva();
    }

    setState(() {
      _estrofas[i] = estrofa;
      _notify();
    });
  }

  /// Abre el grabador de TIMING (NO toca los números).
  /// Solo captura los ms entre toques y los guarda en timings7/timings6.
  Future<void> _abrirGrabarTiming(int i) async {
    // Si ya hay timings grabados, avisar.
    final tieneTimings = _estrofas[i].columnas.any(
          (c) => c.timings7.isNotEmpty || c.timings6.isNotEmpty,
        );

    if (tieneTimings) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Sobrescribir timing',
              style: TextStyle(
                  color: AppColors.granate,
                  fontWeight: FontWeight.bold)),
          content: const Text(
              'Esta estrofa ya tiene un timing grabado. Al grabar '
              'de nuevo, se reemplazará por completo.\n\n'
              '¿Continuar?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continuar')),
          ],
        ),
      );
      if (ok != true) return;
    }

    final resultado = await Navigator.push<EstrofaNumerofonia>(
      context,
      MaterialPageRoute(
        builder: (_) => GrabarTimingScreen(
          estrofa: _estrofas[i].copy(),
        ),
      ),
    );
    if (resultado == null) return;

    setState(() {
      _estrofas[i] = resultado;
      _notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) {
        final double disponible = cons.hasBoundedWidth
            ? cons.maxWidth
            : MediaQuery.of(context).size.width - 64;

        double maxBase = 0;
        for (final e in _estrofas) {
          final b = _EditorEstrofa.baseDe(e);
          if (b > maxBase) maxBase = b;
        }
        double esc = 1.0;
        if (maxBase > 0 && disponible > 0 && maxBase > disponible) {
          esc = (disponible / maxBase).clamp(0.6, 1.0);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < _estrofas.length; i++) ...[
              _EditorEstrofa(
                key: ValueKey('est-${identityHashCode(_estrofas[i])}'),
                estrofa: _estrofas[i],
                indice: i,
                escala: esc,
                onCelda: _notify,
                onToggleBis: () => setState(() {
                  _estrofas[i].bis = !_estrofas[i].bis;
                  _notify();
                }),
                onAgregarColumna: () => setState(() {
                  _estrofas[i].columnas.add(ColumnaNumerofonia());
                  _notify();
                }),
                onQuitarColumna: () => setState(() {
                  if (_estrofas[i].columnas.isNotEmpty) {
                    _estrofas[i].columnas.removeLast();
                    _notify();
                  }
                }),
                onEliminar: () => setState(() {
                  _estrofas.removeAt(i);
                  _notify();
                }),
                onGrabar: () => _abrirGrabador(i),
                onGrabarTiming: () => _abrirGrabarTiming(i),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => setState(() {
                  _estrofas.add(EstrofaNumerofonia.nueva());
                  _notify();
                }),
                icon: const Icon(Icons.add, color: AppColors.granate, size: 18),
                label: const Text(
                  'AGREGAR NUEVA ESTROFA',
                  style: TextStyle(
                    color: AppColors.granate,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 11,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.granate.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}