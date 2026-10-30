// lib/widgets/editor_numerofonia.dart
import 'package:flutter/material.dart';

import '../design/design.dart';
import '../models/numerofonia.dart';
import '../features/grabar/screens/herramientas_grabacion_screen.dart';
import '../screens/numerofonia_fullscreen_screen.dart';
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

  Future<void> _abrirHerramientas() async {
    final res = await Navigator.push<List<EstrofaNumerofonia>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            HerramientasGrabacionScreen(estrofas: _estrofas),
      ),
    );
    if (res != null && mounted) {
      setState(() => _estrofas = res);
      _notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sp.md),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'HERRAMIENTAS DE GRABACIÓN',
                  icon: Icons.piano,
                  variant: AppButtonVariant.secondary,
                  onPressed: _abrirHerramientas,
                ),
              ),
            ],
          ),
        ),
        for (int i = 0; i < _estrofas.length; i++) ...[
          EditorEstrofaCard(
            key: ValueKey('est-${identityHashCode(_estrofas[i])}'),
            estrofa: _estrofas[i],
            indice: i,
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
            onVerGlobal: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NumerofoniaFullscreenScreen(
                    estrofas: [_estrofas[i]],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: Sp.lg),
        ],
        AppButton(
          label: 'AGREGAR NUEVA ESTROFA',
          icon: Icons.add,
          variant: AppButtonVariant.secondary,
          onPressed: () => setState(() {
            _estrofas.add(EstrofaNumerofonia.nueva());
            _notify();
          }),
        ),
      ],
    );
  }
}