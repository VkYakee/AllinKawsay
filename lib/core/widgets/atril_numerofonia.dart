// lib/core/widgets/atril_numerofonia.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/tokens.dart';
import '../../models/numerofonia.dart';
import '../../widgets/visor_numerofonia.dart'; // Para CeldaActiva

/// Visor de Numerofonía "Atril Fijo" (Responsive Music Grid).
///
/// Resuelve el problema del scroll horizontal:
/// Un músico de sikuris no puede deslizar la pantalla con los dedos mientras toca.
/// Este widget divide automáticamente la numerofonía en SISTEMAS RÍTMICOS
/// con salto de línea continuo (igual que un pentagrama o cancionero impreso).
class AtrilNumerofonia extends StatelessWidget {
  final List<EstrofaNumerofonia> estrofas;
  final CeldaActiva? celdaActiva;
  final bool fondoOscuro;
  final double fontSize;
  final bool mostrarTituloEstrofa;

  const AtrilNumerofonia({
    super.key,
    required this.estrofas,
    this.celdaActiva,
    this.fondoOscuro = true,
    this.fontSize = 17.0,
    this.mostrarTituloEstrofa = true,
  });

  @override
  Widget build(BuildContext context) {
    final validas = estrofas.where((e) => !e.vacia).toList();
    if (validas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.xl),
          child: Text(
            'Sin numerofonía registrada',
            style: TextStyle(
              color: AppColors.oroSolar.withOpacity(0.4),
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double disponible = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int eIdx = 0; eIdx < validas.length; eIdx++) ...[
              _EstrofaAtril(
                estrofa: validas[eIdx],
                indiceEstrofa: eIdx,
                anchoTotal: disponible,
                celdaActiva: celdaActiva,
                fondoOscuro: fondoOscuro,
                fontSize: fontSize,
                mostrarTitulo: mostrarTituloEstrofa,
              ),
              if (eIdx < validas.length - 1)
                const SizedBox(height: Sp.xl),
            ],
          ],
        );
      },
    );
  }
}

class _EstrofaAtril extends StatelessWidget {
  final EstrofaNumerofonia estrofa;
  final int indiceEstrofa;
  final double anchoTotal;
  final CeldaActiva? celdaActiva;
  final bool fondoOscuro;
  final double fontSize;
  final bool mostrarTitulo;

  const _EstrofaAtril({
    required this.estrofa,
    required this.indiceEstrofa,
    required this.anchoTotal,
    required this.celdaActiva,
    required this.fondoOscuro,
    required this.fontSize,
    required this.mostrarTitulo,
  });

  @override
  Widget build(BuildContext context) {
    final columnas = estrofa.columnas;
    if (columnas.isEmpty) return const SizedBox.shrink();

    // Medidas base de diseño
    const double anchoCabecera = 34.0;
    const double margenLateral = 8.0;
    final double anchoUtil = math.max(100.0, anchoTotal - (margenLateral * 2));

    // Ancho promedio requerido por compás (mínimo 44px para legibilidad de hasta 4 dígitos)
    final double anchoCompasEstimado = math.max(48.0, fontSize * 2.8);
    final int maxColsPorFila = math.max(
      1,
      ((anchoUtil - anchoCabecera) / anchoCompasEstimado).floor(),
    );

    // Dividimos las columnas en sistemas (renglones)
    final List<List<int>> sistemas = [];
    for (int i = 0; i < columnas.length; i += maxColsPorFila) {
      final fin = math.min(i + maxColsPorFila, columnas.length);
      sistemas.add(List.generate(fin - i, (k) => i + k));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mostrarTitulo) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: Sp.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.granateSagrado,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.oroSolar.withOpacity(0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'ESTROFA ${romanoNumerofonia(indiceEstrofa + 1)}',
                    style: TextStyle(
                      color: AppColors.oroReflejo,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (estrofa.bis) ...[
                  const SizedBox(width: Sp.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.oroSolar.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.oroSolar.withOpacity(0.6),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.repeat,
                          size: 11,
                          color: AppColors.oroSolar,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'BIS',
                          style: TextStyle(
                            color: AppColors.oroSolar,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        // Renglones de sistemas musicales continuos
        for (int sIdx = 0; sIdx < sistemas.length; sIdx++) ...[
          _SistemaMusicalRenglon(
            indicesColumnas: sistemas[sIdx],
            todasColumnas: columnas,
            anchoCabecera: anchoCabecera,
            indiceEstrofa: indiceEstrofa,
            celdaActiva: celdaActiva,
            fontSize: fontSize,
            esUltimoSistema: sIdx == sistemas.length - 1,
            conBis: sIdx == sistemas.length - 1 && estrofa.bis,
          ),
          if (sIdx < sistemas.length - 1)
            const SizedBox(height: 8.0),
        ],
      ],
    );
  }
}

class _SistemaMusicalRenglon extends StatelessWidget {
  final List<int> indicesColumnas;
  final List<ColumnaNumerofonia> todasColumnas;
  final double anchoCabecera;
  final int indiceEstrofa;
  final CeldaActiva? celdaActiva;
  final double fontSize;
  final bool esUltimoSistema;
  final bool conBis;

  const _SistemaMusicalRenglon({
    required this.indicesColumnas,
    required this.todasColumnas,
    required this.anchoCabecera,
    required this.indiceEstrofa,
    required this.celdaActiva,
    required this.fontSize,
    required this.esUltimoSistema,
    required this.conBis,
  });

  @override
  Widget build(BuildContext context) {
    final double altoFila = fontSize * 1.9;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera Fila 7 (Arca) y Fila 6 (Ira)
              SizedBox(
                width: anchoCabecera,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: AppColors.granateSagrado,
                        alignment: Alignment.center,
                        child: Text(
                          '7',
                          style: TextStyle(
                            color: AppColors.oroSolar,
                            fontSize: fontSize * 0.8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Container(height: 0.8, color: Colors.white24),
                    Expanded(
                      child: Container(
                        color: AppColors.granateOscuro,
                        alignment: Alignment.center,
                        child: Text(
                          '6',
                          style: TextStyle(
                            color: AppColors.oroSolar,
                            fontSize: fontSize * 0.8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divisor vertical
              Container(width: 1.0, color: AppColors.oroSolar.withOpacity(0.35)),

              // Compases distribuidos uniformemente en este renglón
              Expanded(
                child: Row(
                  children: List.generate(indicesColumnas.length, (k) {
                    final int colIdx = indicesColumnas[k];
                    final col = todasColumnas[colIdx];
                    final bool tieneDivisorDerecha = k < indicesColumnas.length - 1;

                    final bool activa7 = celdaActiva != null &&
                        celdaActiva!.estrofa == indiceEstrofa &&
                        celdaActiva!.columna == colIdx &&
                        celdaActiva!.esFila7;

                    final bool activa6 = celdaActiva != null &&
                        celdaActiva!.estrofa == indiceEstrofa &&
                        celdaActiva!.columna == colIdx &&
                        !celdaActiva!.esFila7;

                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: tieneDivisorDerecha
                                ? BorderSide(
                                    color: Colors.white.withOpacity(0.12),
                                    width: 0.8,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Nota Fila 7
                            Expanded(
                              child: _CeldaNota(
                                valor: col.nota7,
                                activa: activa7,
                                alto: altoFila,
                                fontSize: fontSize,
                                esFila7: true,
                              ),
                            ),
                            Container(
                              height: 0.8,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            // Nota Fila 6
                            Expanded(
                              child: _CeldaNota(
                                valor: col.nota6,
                                activa: activa6,
                                alto: altoFila,
                                fontSize: fontSize,
                                esFila7: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Barra de repetición final si es BIS
              if (conBis)
                Container(
                  width: 14,
                  decoration: BoxDecoration(
                    color: AppColors.oroSolar.withOpacity(0.15),
                    border: const Border(
                      left: BorderSide(color: AppColors.oroSolar, width: 2.5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 3.5, color: AppColors.oroSolar),
                      SizedBox(height: 6),
                      Icon(Icons.circle, size: 3.5, color: AppColors.oroSolar),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CeldaNota extends StatelessWidget {
  final String valor;
  final bool activa;
  final double alto;
  final double fontSize;
  final bool esFila7;

  const _CeldaNota({
    required this.valor,
    required this.activa,
    required this.alto,
    required this.fontSize,
    required this.esFila7,
  });

  @override
  Widget build(BuildContext context) {
    final clean = valor.trim();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      color: activa
          ? AppColors.oroSolar.withOpacity(0.25)
          : Colors.transparent,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          clean.isEmpty ? '·' : clean,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: activa
                ? AppColors.oroReflejo
                : clean.isEmpty
                    ? Colors.white.withOpacity(0.14)
                    : Colors.white.withOpacity(0.92),
            shadows: activa
                ? [
                    const Shadow(
                      color: AppColors.oroSolar,
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
