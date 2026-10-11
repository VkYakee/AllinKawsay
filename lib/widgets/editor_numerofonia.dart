import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/numerofonia.dart';
import '../theme/colors.dart';

/// Editor de numerofonía tipo Excel/PowerPoint: tabla de 2 hileras
/// (7 arriba, 6 abajo) con celdas editables y anchos auto-ajustables.
class EditorNumerofonia extends StatefulWidget {
  final List<EstrofaNumerofonia> estrofas;
  final VoidCallback? onChanged;

  const EditorNumerofonia({
    super.key,
    required this.estrofas,
    this.onChanged,
  });

  @override
  State<EditorNumerofonia> createState() => _EditorNumerofoniaState();
}

class _EditorNumerofoniaState extends State<EditorNumerofonia> {
  @override
  void initState() {
    super.initState();
    // Canción nueva: 3 partes vacías por defecto, como el cancionero.
    if (widget.estrofas.every((e) => e.vacia)) {
      while (widget.estrofas.length < 3) {
        widget.estrofas.add(EstrofaNumerofonia.nueva());
      }
    }
  }

  void _notify() => widget.onChanged?.call();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, cons) {
        final double disponible = cons.hasBoundedWidth
            ? cons.maxWidth
            : MediaQuery.of(context).size.width - 64;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < widget.estrofas.length; i++) ...[
              _EditorEstrofa(
                key: ValueKey('est-$i-${widget.estrofas[i].hashCode}'),
                estrofa: widget.estrofas[i],
                indice: i,
                disponible: disponible,
                onCelda: _notify,
                onToggleBis: () => setState(() {
                  widget.estrofas[i].bis = !widget.estrofas[i].bis;
                  _notify();
                }),
                onAgregarColumna: () => setState(() {
                  widget.estrofas[i].columnas.add(ColumnaNumerofonia());
                  _notify();
                }),
                onEliminar: () => setState(() {
                  widget.estrofas.removeAt(i);
                  _notify();
                }),
              ),
              const SizedBox(height: 18),
            ],
            _botonAgregarTabla(),
          ],
        );
      },
    );
  }

  Widget _botonAgregarTabla() => SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () => setState(() {
            widget.estrofas.add(EstrofaNumerofonia.nueva());
            _notify();
          }),
          icon: const Icon(Icons.add, color: AppColors.granate),
          label: const Text(
            'AGREGAR NUEVA PARTE (TABLA)',
            style: TextStyle(
              color: AppColors.granate,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.granate.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
}

class _EditorEstrofa extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final int indice;
  final double disponible;
  final VoidCallback onCelda;
  final VoidCallback onToggleBis;
  final VoidCallback onAgregarColumna;
  final VoidCallback onEliminar;

  const _EditorEstrofa({
    super.key,
    required this.estrofa,
    required this.indice,
    required this.disponible,
    required this.onCelda,
    required this.onToggleBis,
    required this.onAgregarColumna,
    required this.onEliminar,
  });

  static const double _charW = 9.9;
  static const double _padH = 4.0;

  double _anchoCol(ColumnaNumerofonia c, double e) =>
      ((c.maxLen.clamp(1, 99) * _charW + _padH * 2 + 2) * e).clamp(36 * e, 999.0);

  double _anchoBase() =>
      24 + estrofa.columnas.fold<double>(0, (s, c) => s + _anchoCol(c, 1.0));

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final colorNota = oscuro ? const Color(0xFFE8E8E8) : AppColors.negro;

    double e = 1.0;
    final base = _anchoBase();
    if (base > 0 && disponible > 0 && base > disponible) {
      e = (disponible / base).clamp(0.7, 1.0);
    }

    final n = estrofa.columnas.length;
    final tabla = Table(
      columnWidths: {
        0: FixedColumnWidth(24 * e),
        for (int j = 0; j < n; j++)
          j + 1: FixedColumnWidth(_anchoCol(estrofa.columnas[j], e)),
      },
      border: TableBorder.all(
        color: AppColors.granate.withOpacity(0.30),
        width: 1,
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          _etiqueta('7', e),
          for (int j = 0; j < n; j++)
            _celda(indice, j, true, estrofa.columnas[j].nota7, e, colorNota),
        ]),
        TableRow(children: [
          _etiqueta('6', e),
          for (int j = 0; j < n; j++)
            _celda(indice, j, false, estrofa.columnas[j].nota6, e, colorNota),
        ]),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera: PARTE n + BIS + eliminar
        Row(
          children: [
            Text(
              'PARTE ${romanoNumerofonia(indice + 1)}',
              style: const TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            _chipBis(e),
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
        const SizedBox(height: 6),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: tabla),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onAgregarColumna,
            icon: const Icon(Icons.add, size: 15, color: AppColors.granate),
            label: const Text(
              'COLUMNA',
              style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: AppColors.granate.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _etiqueta(String t, double e) => Container(
        height: 36 * e,
        color: AppColors.granate,
        alignment: Alignment.center,
        child: Text(
          t,
          style: TextStyle(
            color: AppColors.dorado,
            fontWeight: FontWeight.bold,
            fontSize: 12 * e,
            height: 1.0,
          ),
        ),
      );

  Widget _celda(
    int i,
    int j,
    bool es7,
    String valor,
    double e,
    Color color,
  ) =>
      SizedBox(
        height: 36 * e,
        child: TextFormField(
          key: ValueKey('cif-$i-$j-${es7 ? 7 : 6}'),
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
            fontSize: 15 * e,
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

  Widget _chipBis(double e) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onToggleBis,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                size: 12,
                color: estrofa.bis
                    ? AppColors.granate
                    : AppColors.granate.withOpacity(0.4),
              ),
              const SizedBox(width: 4),
              Text(
                'BIS',
                style: TextStyle(
                  color: estrofa.bis
                      ? AppColors.granate
                      : AppColors.granate.withOpacity(0.4),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );
}