import 'package:flutter/material.dart';

import '../models/numerofonia.dart';
import '../theme/colors.dart';

class VisorNumerofonia extends StatelessWidget {
  final List<EstrofaNumerofonia> estrofas;
  final double escala;

  const VisorNumerofonia({
    super.key,
    required this.estrofas,
    this.escala = 1.0,
  });

  static const double charW = 7.5;
  static const double padH = 3.0;

  static double anchoCol(ColumnaNumerofonia c, double e) =>
      (c.maxLen.clamp(1, 99) * charW + padH * 2 + 1) * e;

  static double baseDe(EstrofaNumerofonia estrofa) =>
      18 + estrofa.columnas.fold<double>(0, (s, c) => s + anchoCol(c, 1.0));

  @override
  Widget build(BuildContext context) {
    final validas = estrofas.where((e) => !e.vacia).toList();
    if (validas.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, cons) {
        final double disponible = cons.hasBoundedWidth
            ? cons.maxWidth
            : MediaQuery.of(context).size.width - 32;

        // ESCALA ÚNICA para todas las estrofas (simetría tipo PDF)
        double maxBase = 0;
        for (final e in validas) {
          final b = baseDe(e);
          if (b > maxBase) maxBase = b;
        }
        double e = escala;
        if (maxBase > 0 && disponible > 0 && maxBase * e > disponible) {
          e = (disponible / maxBase).clamp(0.4, escala);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < validas.length; i++) ...[
              _TablaEstrofa(
                estrofa: validas[i],
                escala: e,
                titulo: romanoNumerofonia(i + 1),
                conCabecera: validas.length > 1 || validas[i].bis,
              ),
              if (i < validas.length - 1) SizedBox(height: 12 * e),
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
  final String titulo;
  final bool conCabecera;

  const _TablaEstrofa({
    required this.estrofa,
    required this.escala,
    required this.titulo,
    required this.conCabecera,
  });

  @override
  Widget build(BuildContext context) {
    final e = escala;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final colorNota = oscuro ? const Color(0xFFE8E8E8) : AppColors.negro;
    final colorLinea = oscuro
        ? AppColors.dorado.withOpacity(0.25)
        : AppColors.granate.withOpacity(0.20);

    final n = estrofa.columnas.length;
    final tabla = Table(
      columnWidths: {
        0: FixedColumnWidth(18 * e),
        for (int j = 0; j < n; j++)
          j + 1: FixedColumnWidth(
              VisorNumerofonia.anchoCol(estrofa.columnas[j], e)),
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
            padding: EdgeInsets.only(bottom: 4 * e, left: 2),
            child: Row(
              children: [
                Text(
                  'ESTROFA $titulo',
                  style: TextStyle(
                    color: oscuro ? AppColors.dorado : AppColors.granate,
                    fontWeight: FontWeight.bold,
                    fontSize: 10 * e,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                if (estrofa.bis) _badgeBis(e, oscuro),
              ],
            ),
          ),
        tabla,
      ],
    );
  }

  Widget _etiqueta(String t, double e) => Container(
        height: 24 * e,
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

  Widget _nota(String valor, double e, Color color) => Container(
        height: 24 * e,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: VisorNumerofonia.padH * e),
        child: Text(
          valor,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            fontSize: 12 * e,
            height: 1.0,
          ),
        ),
      );

  Widget _badgeBis(double e, bool oscuro) => Container(
        padding: EdgeInsets.symmetric(horizontal: 6 * e, vertical: 2 * e),
        decoration: BoxDecoration(
          color: AppColors.dorado.withOpacity(0.15),
          border: Border.all(color: AppColors.dorado.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat,
                size: 9 * e,
                color: oscuro ? AppColors.dorado : AppColors.granate),
            SizedBox(width: 3 * e),
            Text(
              'BIS',
              style: TextStyle(
                color: oscuro ? AppColors.dorado : AppColors.granate,
                fontWeight: FontWeight.bold,
                fontSize: 8 * e,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
}