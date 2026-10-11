import 'package:flutter/material.dart';

import '../models/numerofonia.dart';
import '../theme/colors.dart';

/// Visor de numerofonía estilo cancionero: tabla de 2 hileras
/// (7 arriba, 6 abajo) x N columnas. Los anchos de columna se ajustan
/// al contenido (como Excel) y la tabla se auto-escala para que la
/// parte completa quepa en pantalla SIN deslizar.
class VisorNumerofonia extends StatelessWidget {
  final List<EstrofaNumerofonia> estrofas;
  final double escala;

  const VisorNumerofonia({
    super.key,
    required this.estrofas,
    this.escala = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final validas = estrofas.where((e) => !e.vacia).toList();
    if (validas.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, cons) {
        final double disponible = cons.hasBoundedWidth
            ? cons.maxWidth
            : MediaQuery.of(context).size.width - 32;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < validas.length; i++) ...[
              _TablaEstrofa(
                estrofa: validas[i],
                escala: escala,
                disponible: disponible,
                titulo: romanoNumerofonia(i + 1),
                conCabecera: validas.length > 1 || validas[i].bis,
              ),
              if (i < validas.length - 1) SizedBox(height: 16 * escala),
            ],
          ],
        );
      },
    );
  }
}

class _TablaEstrofa extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final double escala;
  final double disponible;
  final String titulo;
  final bool conCabecera;

  const _TablaEstrofa({
    required this.estrofa,
    required this.escala,
    required this.disponible,
    required this.titulo,
    required this.conCabecera,
  });

  // === Geometría tipo Excel ===
  static const double _charW = 9.9; // ancho de carácter monospace
  static const double _padH = 5.0; // padding horizontal mínimo por celda

  double _anchoCol(ColumnaNumerofonia c, double e) =>
      (c.maxLen.clamp(1, 99) * _charW + _padH * 2 + 2) * e;

  double _anchoBase() =>
      22 + estrofa.columnas.fold<double>(0, (s, c) => s + _anchoCol(c, 1.0));

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final colorNota = oscuro ? const Color(0xFFE8E8E8) : AppColors.negro;
    final colorLinea =
        oscuro ? AppColors.dorado.withOpacity(0.35) : AppColors.granate.withOpacity(0.30);

    // Auto-escala: la parte completa entra en pantalla sin deslizar.
    double e = escala;
    final base = _anchoBase();
    if (base > 0 && disponible > 0 && base * e > disponible) {
      e = (disponible / base).clamp(0.55, escala);
    }

    final n = estrofa.columnas.length;
    final tabla = Table(
      columnWidths: {
        0: FixedColumnWidth(22 * e),
        for (int j = 0; j < n; j++) j + 1: FixedColumnWidth(_anchoCol(estrofa.columnas[j], e)),
      },
      border: TableBorder.all(color: colorLinea, width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          _etiqueta('7', e),
          for (final c in estrofa.columnas) _nota(c.nota7, e, colorNota),
        ]),
        TableRow(children: [
          _etiqueta('6', e),
          for (final c in estrofa.columnas) _nota(c.nota6, e, colorNota),
        ]),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (conCabecera)
          Padding(
            padding: EdgeInsets.only(bottom: 6 * e, left: 2),
            child: Row(
              children: [
                Text(
                  'PARTE $titulo',
                  style: TextStyle(
                    color: oscuro ? AppColors.dorado : AppColors.granate,
                    fontWeight: FontWeight.bold,
                    fontSize: 11 * e,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                if (estrofa.bis) _badgeBis(e),
              ],
            ),
          ),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: tabla),
      ],
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
            fontSize: 12 * e,
            height: 1.0,
          ),
        ),
      );

  Widget _nota(String valor, double e, Color color) => Container(
        height: 30 * e,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: _padH * e),
        child: Text(
          valor,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            fontSize: 15.5 * e,
            height: 1.0,
          ),
        ),
      );

  Widget _badgeBis(double e) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * e, vertical: 3 * e),
        decoration: BoxDecoration(
          color: AppColors.dorado.withOpacity(0.18),
          border: Border.all(color: AppColors.dorado.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat, size: 11 * e, color: AppColors.granate),
            SizedBox(width: 4 * e),
            Text(
              'BIS',
              style: TextStyle(
                color: AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 10 * e,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
}