// lib/widgets/editor_numerofonia.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/numerofonia.dart';
import '../screens/grabar_partitura_screen.dart';
import '../screens/grabar_timing_screen.dart';
import 'editor/editor_estrofa_card.dart';

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
      MaterialPageRoute(builder: (_) => GrabarPartituraScreen(estrofaInicial: _estrofas[i].copy())),
    );
    if (resultado == null) return;
    var estrofa = resultado;
    if (estrofa.columnas.isEmpty) estrofa = EstrofaNumerofonia.nueva();
    setState(() { _estrofas[i] = estrofa; _notify(); });
  }

  Future<void> _abrirGrabarTiming(int i) async {
    final tieneTimings = _estrofas[i].columnas.any((c) => c.timings7.isNotEmpty || c.timings6.isNotEmpty);
    if (tieneTimings) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Sobrescribir timing'),
          content: const Text('Esta estrofa ya tiene un timing. ¿Deseas reemplazarlo?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continuar')),
          ],
        ),
      );
      if (ok != true) return;
    }
    final resultado = await Navigator.push<EstrofaNumerofonia>(
      context,
      MaterialPageRoute(builder: (_) => GrabarTimingScreen(estrofa: _estrofas[i].copy())),
    );
    if (resultado != null && mounted) { setState(() { _estrofas[i] = resultado; _notify(); }); }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < _estrofas.length; i++) ...[
          EditorEstrofaCard(
            key: ValueKey('est-${identityHashCode(_estrofas[i])}'),
            estrofa: _estrofas[i],
            indice: i,
            onCelda: _notify,
            onToggleBis: () => setState(() { _estrofas[i].bis = !_estrofas[i].bis; _notify(); }),
            onAgregarColumna: () => setState(() { _estrofas[i].columnas.add(ColumnaNumerofonia()); _notify(); }),
            onQuitarColumna: () => setState(() { if (_estrofas[i].columnas.isNotEmpty) { _estrofas[i].columnas.removeLast(); _notify(); } }),
            onEliminar: () => setState(() { _estrofas.removeAt(i); _notify(); }),
            onGrabar: () => _abrirGrabador(i),
            onGrabarTiming: () => _abrirGrabarTiming(i),
          ),
          const SizedBox(height: Sp.lg),
        ],
        AppButton(
          label: 'AGREGAR NUEVA ESTROFA',
          icon: Icons.add,
          variant: AppButtonVariant.secondary,
          onPressed: () => setState(() { _estrofas.add(EstrofaNumerofonia.nueva()); _notify(); }),
        ),
      ],
    );
  }
}