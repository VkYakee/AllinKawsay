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
              if (i < validas.length - 1) SizedBox(height: 12 * escala),
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

  // Tamaño base más pequeño para que entre más partitura
  static const double _charW = 7.5; 
  static const double _padH = 3.0;

  double _anchoCol(ColumnaNumerofonia c, double e) =>
      (c.maxLen.clamp(1, 99) * _charW + _padH * 2 + 1) * e;

  double _anchoBase() =>
      18 + estrofa.columnas.fold<double>(0, (s, c) => s + _anchoCol(c, 1.0));

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    // FIX PANTALLA COMPLETA: Colores adaptables al tema
    final colorNota = oscuro ? const Color(0xFFE8E8E8) : AppColors.negro;
    final colorLinea = oscuro 
        ? AppColors.dorado.withOpacity(0.25) 
        : AppColors.granate.withOpacity(0.20);

    // Auto-escala agresiva: SIEMPRE entra en pantalla sin scroll
    double e = escala;
    final base = _anchoBase();
    if (base > 0 && disponible > 0 && base * e > disponible) {
      e = disponible / base;
      if (e < 0.4) e = 0.4; // Límite mínimo para que sea legible
    }

    final n = estrofa.columnas.length;
    final tabla = Table(
      columnWidths: {
        0: FixedColumnWidth(18 * e),
        for (int j = 0; j < n; j++) j + 1: FixedColumnWidth(_anchoCol(estrofa.columnas[j], e)),
      },
      border: TableBorder.all(color: colorLinea, width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          _etiqueta('7', e, oscuro),
          for (final c in estrofa.columnas) _nota(c.nota7, e, colorNota),
        ]),
        TableRow(children: [
          _etiqueta('6', e, oscuro),
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
                  'ESTROFA $titulo', // CAMBIO: PARTE -> ESTROFA
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
        // SIN SingleChildScrollView: La tabla se encoge para entrar completa
        tabla,
      ],
    );
  }

  Widget _etiqueta(String t, double e, bool oscuro) => Container(
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
        padding: EdgeInsets.symmetric(horizontal: _padH * e),
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
            Icon(Icons.repeat, size: 9 * e, color: oscuro ? AppColors.dorado : AppColors.granate),
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