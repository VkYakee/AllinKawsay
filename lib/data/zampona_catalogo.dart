import '../models/zampona_nota.dart';

/// Las 13 cañas de la zampoña, según la afinación del grupo.
/// Ordenadas por fila y por posición (1 = más pequeña = más aguda).
///
/// Fila 7 (arriba) → Do, Lab, Fa, Reb, Sib, Sol, Mib
/// Fila 6 (abajo)  → Sib, Sol, Mib, Do, Lab, Fa
const List<ZamponaNota> zamponaNotas = [
  // ═══════════════════════════════════════════════════════════
  // FILA 7 (ARRIBA) — 7 cañas
  // ═══════════════════════════════════════════════════════════
  ZamponaNota(
    id: 'fila7_1',
    nota: 'Do',
    fila: 7,
    posicion: 1,
    assetPath: 'assets/zampona/fila7_1.ogg',
  ),
  ZamponaNota(
    id: 'fila7_2',
    nota: 'Lab',
    fila: 7,
    posicion: 2,
    assetPath: 'assets/zampona/fila7_2.ogg',
  ),
  ZamponaNota(
    id: 'fila7_3',
    nota: 'Fa',
    fila: 7,
    posicion: 3,
    assetPath: 'assets/zampona/fila7_3.ogg',
  ),
  ZamponaNota(
    id: 'fila7_4',
    nota: 'Reb',
    fila: 7,
    posicion: 4,
    assetPath: 'assets/zampona/fila7_4.ogg',
  ),
  ZamponaNota(
    id: 'fila7_5',
    nota: 'Sib',
    fila: 7,
    posicion: 5,
    assetPath: 'assets/zampona/fila7_5.ogg',
  ),
  ZamponaNota(
    id: 'fila7_6',
    nota: 'Sol',
    fila: 7,
    posicion: 6,
    assetPath: 'assets/zampona/fila7_6.ogg',
  ),
  ZamponaNota(
    id: 'fila7_7',
    nota: 'Mib',
    fila: 7,
    posicion: 7,
    assetPath: 'assets/zampona/fila7_7.ogg',
  ),

  // ═══════════════════════════════════════════════════════════
  // FILA 6 (ABAJO) — 6 cañas
  // ═══════════════════════════════════════════════════════════
  ZamponaNota(
    id: 'fila6_1',
    nota: 'Sib',
    fila: 6,
    posicion: 1,
    assetPath: 'assets/zampona/fila6_1.ogg',
  ),
  ZamponaNota(
    id: 'fila6_2',
    nota: 'Sol',
    fila: 6,
    posicion: 2,
    assetPath: 'assets/zampona/fila6_2.ogg',
  ),
  ZamponaNota(
    id: 'fila6_3',
    nota: 'Mib',
    fila: 6,
    posicion: 3,
    assetPath: 'assets/zampona/fila6_3.ogg',
  ),
  ZamponaNota(
    id: 'fila6_4',
    nota: 'Do',
    fila: 6,
    posicion: 4,
    assetPath: 'assets/zampona/fila6_4.ogg',
  ),
  ZamponaNota(
    id: 'fila6_5',
    nota: 'Lab',
    fila: 6,
    posicion: 5,
    assetPath: 'assets/zampona/fila6_5.ogg',
  ),
  ZamponaNota(
    id: 'fila6_6',
    nota: 'Fa',
    fila: 6,
    posicion: 6,
    assetPath: 'assets/zampona/fila6_6.ogg',
  ),
];

/// Devuelve solo las notas de la fila 7.
List<ZamponaNota> get notasFila7 =>
    zamponaNotas.where((n) => n.fila == 7).toList();

/// Devuelve solo las notas de la fila 6.
List<ZamponaNota> get notasFila6 =>
    zamponaNotas.where((n) => n.fila == 6).toList();