import 'package:flutter/material.dart';

import '../models/numerofonia.dart';
import '../theme/colors.dart';

/// Marca qué carácter de la tabla debe brillar (para el Modo Ensayo).
class CeldaActiva {
  final int estrofa;   // índice entre las estrofas NO vacías
  final int columna;
  final bool esFila7;
  final int notaIndex; // índice del carácter dentro de la celda

  const CeldaActiva({
    required this.estrofa,
    required this.columna,
    required this.esFila7,
    required this.notaIndex,
  });
}

class VisorNumerofonia extends StatelessWidget {
  final List<EstrofaNumerofonia> estrofas;
  final double escala;

  /// Si no es null, se ilumina un carácter específico de la tabla.
  final CeldaActiva? celdaActiva;

  const VisorNumerofonia({
    super.key,
    required this.estrofas,
    this.escala = 1.0,
    this.celdaActiva,
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
                // Solo pasamos la celda activa si pertenece a ESTA estrofa
                celdaActiva: (celdaActiva != null &&
                        celdaActiva!.estrofa == i)
                    ? celdaActiva
                    : null,
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
  final CeldaActiva? celdaActiva;

  const _TablaEstrofa({
    required this.estrofa,
    required this.escala,
    required this.titulo,
    required this.conCabecera,
    this.celdaActiva,
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
          for (int j = 0; j < n; j++)
            _nota(
              columna: j,
              esFila7: true,
              valor: estrofa.columnas[j].nota7,
              e: e,
              color: colorNota,
            ),
        ]),
        TableRow(children: [
          _etiqueta('6', e),
          for (int j = 0; j < n; j++)
            _nota(
              columna: j,
              esFila7: false,
              valor: estrofa.columnas[j].nota6,
              e: e,
              color: colorNota,
            ),
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

  Widget _nota({
    required int columna,
    required bool esFila7,
    required String valor,
    required double e,
    required Color color,
  }) {
    // Si esta celda es la activa, iluminamos el carácter específico.
    final activa = celdaActiva != null &&
        celdaActiva!.columna == columna &&
        celdaActiva!.esFila7 == esFila7;

    if (!activa || valor.trim().isEmpty) {
      return _notaSimple(valor, e, color);
    }

    // Construimos el texto con el carácter activo destacado.
    final textoLimpio = valor.trim();
    final idx = celdaActiva!.notaIndex;
    if (idx < 0 || idx >= textoLimpio.length) {
      return _notaSimple(valor, e, color);
    }

    final antes = textoLimpio.substring(0, idx);
    final letra = textoLimpio.substring(idx, idx + 1);
    final despues = textoLimpio.substring(idx + 1);

    return Container(
      height: 24 * e,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: VisorNumerofonia.padH * e),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            fontSize: 12 * e,
            height: 1.0,
          ),
          children: [
            if (antes.isNotEmpty)
              TextSpan(text: antes, style: TextStyle(color: color)),
            TextSpan(
              text: letra,
              style: TextStyle(
                color: AppColors.dorado,
                shadows: [
                  Shadow(
                    color: AppColors.dorado.withOpacity(0.9),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            if (despues.isNotEmpty)
              TextSpan(text: despues, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _notaSimple(String valor, double e, Color color) => Container(
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