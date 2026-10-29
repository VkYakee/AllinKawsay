// lib/widgets/visor_numerofonia.dart
import 'package:flutter/material.dart';
import '../models/numerofonia.dart';
import '../theme/colors.dart';

class CeldaActiva {
  final int estrofa;
  final int columna;
  final bool esFila7;
  final int notaIndex;

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
  final CeldaActiva? celdaActiva;
  final bool fondoOscuro;

  const VisorNumerofonia({
    super.key,
    required this.estrofas,
    this.escala = 1.0,
    this.celdaActiva,
    this.fondoOscuro = false,
  });

  static const double charW = 8.0; // Un poco más ancho
  static const double padH = 4.0;

  static double anchoCol(ColumnaNumerofonia c, double e) =>
      (c.maxLen.clamp(1, 99) * charW + padH * 2 + 1) * e;

  static double baseDe(EstrofaNumerofonia estrofa) =>
      24 + estrofa.columnas.fold<double>(0, (s, c) => s + anchoCol(c, 1.0));

  @override
  Widget build(BuildContext context) {
    final validas = estrofas.where((e) => !e.vacia).toList();
    if (validas.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, cons) {
        final double disponible = cons.hasBoundedWidth ? cons.maxWidth : MediaQuery.of(context).size.width - 32;
        double maxBase = 0;
        for (final e in validas) {
          final b = baseDe(e);
          if (b > maxBase) maxBase = b;
        }
        
        double e = escala;
        if (maxBase > 0 && disponible > 0 && maxBase * e > disponible) {
          e = (disponible / maxBase).clamp(0.3, escala); // Permite achicar más
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < validas.length; i++) ...[
              _TablaEstrofa(
                estrofa: validas[i],
                escala: e,
                titulo: romanoNumerofonia(i + 1),
                conCabecera: validas.length > 1 || validas[i].bis,
                celdaActiva: (celdaActiva != null && celdaActiva!.estrofa == i) ? celdaActiva : null,
                fondoOscuro: fondoOscuro,
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
  final bool fondoOscuro;

  const _TablaEstrofa({
    required this.estrofa,
    required this.escala,
    required this.titulo,
    required this.conCabecera,
    this.celdaActiva,
    required this.fondoOscuro,
  });

  @override
  Widget build(BuildContext context) {
    final e = escala;
    final oscuro = fondoOscuro || Theme.of(context).brightness == Brightness.dark;
    
    final colorNota = oscuro ? Colors.white : AppColors.negro;
    final colorLinea = oscuro ? Colors.white24 : AppColors.granate.withOpacity(0.2);
    final colorEtiquetaBg = oscuro ? AppColors.granateOscuro : AppColors.granate;

    final n = estrofa.columnas.length;
    final tabla = Table(
      columnWidths: {
        0: FixedColumnWidth(24 * e),
        for (int j = 0; j < n; j++)
          j + 1: FixedColumnWidth(VisorNumerofonia.anchoCol(estrofa.columnas[j], e)),
      },
      border: TableBorder.all(color: colorLinea, width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          _etiqueta('7', e, colorEtiquetaBg),
          for (int j = 0; j < n; j++)
            _nota(columna: j, esFila7: true, valor: estrofa.columnas[j].nota7, e: e, color: colorNota),
        ]),
        TableRow(children: [
          _etiqueta('6', e, colorEtiquetaBg),
          for (int j = 0; j < n; j++)
            _nota(columna: j, esFila7: false, valor: estrofa.columnas[j].nota6, e: e, color: colorNota),
        ]),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (conCabecera)
          Padding(
            padding: EdgeInsets.only(bottom: 6 * e),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ESTROFA $titulo',
                  style: TextStyle(
                    color: oscuro ? AppColors.dorado : AppColors.granate,
                    fontWeight: FontWeight.bold,
                    fontSize: 11 * e,
                    letterSpacing: 1.5,
                  ),
                ),
                if (estrofa.bis) ...[
                  SizedBox(width: 8 * e),
                  Icon(Icons.repeat, size: 12 * e, color: AppColors.dorado),
                ],
              ],
            ),
          ),
        tabla,
      ],
    );
  }

  Widget _etiqueta(String t, double e, Color bg) => Container(
        height: 30 * e,
        color: bg,
        alignment: Alignment.center,
        child: Text(
          t,
          style: TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold, fontSize: 12 * e, height: 1.0),
        ),
      );

  Widget _nota({
    required int columna,
    required bool esFila7,
    required String valor,
    required double e,
    required Color color,
  }) {
    final activa = celdaActiva != null && celdaActiva!.columna == columna && celdaActiva!.esFila7 == esFila7;

    // EL SECRETO PARA QUE NO SE APILEN: FittedBox con maxLines 1
    Widget texto = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        valor,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14 * e, height: 1.0),
      ),
    );

    if (!activa || valor.trim().isEmpty) {
      return Container(height: 30 * e, alignment: Alignment.center, padding: EdgeInsets.symmetric(horizontal: VisorNumerofonia.padH * e), child: texto);
    }

    final textoLimpio = valor.trim();
    final idx = celdaActiva!.notaIndex;
    if (idx < 0 || idx >= textoLimpio.length) {
       return Container(height: 30 * e, alignment: Alignment.center, padding: EdgeInsets.symmetric(horizontal: VisorNumerofonia.padH * e), child: texto);
    }

    final antes = textoLimpio.substring(0, idx);
    final letra = textoLimpio.substring(idx, idx + 1);
    final despues = textoLimpio.substring(idx + 1);

    return Container(
      height: 30 * e,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.dorado.withOpacity(0.1),
        boxShadow: [BoxShadow(color: AppColors.dorado.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: RichText(
          maxLines: 1,
          text: TextSpan(
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14 * e, height: 1.0),
            children: [
              if (antes.isNotEmpty) TextSpan(text: antes, style: TextStyle(color: color)),
              TextSpan(
                text: letra,
                style: TextStyle(
                  color: AppColors.dorado,
                  shadows: [Shadow(color: AppColors.dorado, blurRadius: 10)],
                ),
              ),
              if (despues.isNotEmpty) TextSpan(text: despues, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}