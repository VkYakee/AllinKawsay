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
class _EditorEstrofa extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final int indice;
  final double escala;
  final VoidCallback onCelda;
  final VoidCallback onToggleBis;
  final VoidCallback onAgregarColumna;
  final VoidCallback onQuitarColumna;
  final VoidCallback onEliminar;
  final VoidCallback onGrabar;
  final VoidCallback onGrabarTiming;

  const _EditorEstrofa({
    super.key,
    required this.estrofa,
    required this.indice,
    required this.escala,
    required this.onCelda,
    required this.onToggleBis,
    required this.onAgregarColumna,
    required this.onQuitarColumna,
    required this.onEliminar,
    required this.onGrabar,
    required this.onGrabarTiming,
  });

  static const double charW = 7.5;
  static const double padH = 3.0;

  static double anchoCol(ColumnaNumerofonia c, double e) =>
      ((c.maxLen.clamp(1, 99) * charW + padH * 2 + 1) * e)
          .clamp(28 * e, 999.0);

  static double baseDe(EstrofaNumerofonia e) =>
      18 + e.columnas.fold<double>(0, (s, c) => s + anchoCol(c, 1.0));

  bool get _tieneTimings =>
      estrofa.columnas.any((c) => c.timings7.isNotEmpty || c.timings6.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final e = escala;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final colorNota = oscuro ? const Color(0xFFE8E8E8) : AppColors.negro;

    final n = estrofa.columnas.length;
    final tabla = Table(
      columnWidths: {
        0: FixedColumnWidth(18 * e),
        for (int j = 0; j < n; j++)
          j + 1: FixedColumnWidth(anchoCol(estrofa.columnas[j], e)),
      },
      border: TableBorder.all(
        color: AppColors.granate.withOpacity(0.25),
        width: 1,
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          _etiqueta('7', e),
          for (int j = 0; j < n; j++)
            _celda(j, true, estrofa.columnas[j].nota7, e, colorNota),
        ]),
        TableRow(children: [
          _etiqueta('6', e),
          for (int j = 0; j < n; j++)
            _celda(j, false, estrofa.columnas[j].nota6, e, colorNota),
        ]),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ESTROFA ${romanoNumerofonia(indice + 1)}',
              style: const TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
            if (_tieneTimings) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.green.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 9, color: Colors.green),
                    SizedBox(width: 3),
                    Text(
                      'TIMING',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            _botonGrabar(),
            const SizedBox(width: 6),
            _botonTiming(),
            const SizedBox(width: 6),
            _chipBis(),
            const SizedBox(width: 6),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onEliminar,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.granate.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: tabla),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _botonColumna(
              icono: Icons.remove,
              onTap: estrofa.columnas.isEmpty ? null : onQuitarColumna,
            ),
            const SizedBox(width: 6),
            _botonColumna(
              icono: Icons.add,
              onTap: onAgregarColumna,
            ),
          ],
        ),
      ],
    );
  }

  Widget _botonGrabar() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onGrabar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: AppColors.gradienteDorado,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.dorado.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.piano, size: 11, color: AppColors.granate),
            SizedBox(width: 4),
            Text(
              'GRABAR',
              style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón "TIMING": abre el grabador de timing sin tocar los números.
  Widget _botonTiming() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onGrabarTiming,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade700,
              Colors.green.shade900,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.timer, size: 11, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'TIMING',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botonColumna({
    required IconData icono,
    required VoidCallback? onTap,
  }) {
    final habilitado = onTap != null;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(
        icono,
        size: 14,
        color: habilitado
            ? AppColors.granate
            : AppColors.granate.withOpacity(0.3),
      ),
      label: const Text(
        'COLUMNA',
        style: TextStyle(
          color: AppColors.granate,
          fontWeight: FontWeight.bold,
          fontSize: 9,
          letterSpacing: 1,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          color: AppColors.granate
              .withOpacity(habilitado ? 0.4 : 0.15),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _etiqueta(String t, double e) => Container(
        height: 30 * e,
        color: AppColors.granate,
        alignment: Alignment.center,
        child: Text(
          t,
          style: TextStyle(
            color: AppColors.dorado,
            fontWeight: FontWeight.bold,
            fontSize: 10 * e,
            height: 1.0,
          ),
        ),
      );

  Widget _celda(int j, bool es7, String valor, double e, Color color) =>
      SizedBox(
        height: 30 * e,
        child: TextFormField(
          key: ValueKey('cif-${identityHashCode(estrofa)}-$j-${es7 ? 7 : 6}'),
          initialValue: valor,
          onChanged: (v) {
            if (es7) {
              estrofa.columnas[j].nota7 = v;
            } else {
              estrofa.columnas[j].nota6 = v;
            }
            onCelda();
          },
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            fontSize: 12 * e,
            height: 1.0,
          ),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.symmetric(horizontal: 2),
          ),
        ),
      );

  Widget _chipBis() => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onToggleBis,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: estrofa.bis
                ? AppColors.dorado.withOpacity(0.20)
                : Colors.transparent,
            border: Border.all(
              color: estrofa.bis
                  ? AppColors.dorado
                  : AppColors.granate.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.repeat,
                size: 10,
                color: estrofa.bis
                    ? AppColors.granate
                    : AppColors.granate.withOpacity(0.4),
              ),
              const SizedBox(width: 3),
              Text(
                'BIS',
                style: TextStyle(
                  color: estrofa.bis
                      ? AppColors.granate
                      : AppColors.granate.withOpacity(0.4),
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );
}