/// Representa una caña de la zampoña.
class ZamponaNota {
  /// ID único: "fila7_1" ... "fila6_6"
  final String id;

  /// Nombre corto de la nota: "Do", "Sib", "Fa"
  final String nota;

  /// Fila: 7 (arriba) o 6 (abajo)
  final int fila;

  /// Posición: 1 = más pequeña (aguda), N = más grande (grave)
  final int posicion;

  /// Ruta al asset de audio
  final String assetPath;

  const ZamponaNota({
    required this.id,
    required this.nota,
    required this.fila,
    required this.posicion,
    required this.assetPath,
  });

  /// Nombre largo para mostrar en la UI
  String get nombreLargo => '$nota ${fila == 7 ? '↑' : '↓'}';
}