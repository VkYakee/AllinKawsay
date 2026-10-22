// lib/widgets/cancionero/filtros_cancionero.dart

enum OrdenCancion { recientes, titulo, autor, reproducciones }

class FiltrosCancionero {
  final String? categoriaId;
  final String? tag;
  final bool soloFavoritos;
  final OrdenCancion orden;
  final bool ascendente;

  const FiltrosCancionero({
    this.categoriaId,
    this.tag,
    this.soloFavoritos = false,
    this.orden = OrdenCancion.titulo,
    this.ascendente = true,
  });

  int get activos {
    int n = 0;
    if (categoriaId != null) n++;
    if (tag != null) n++;
    if (soloFavoritos) n++;
    if (orden != OrdenCancion.titulo) n++;
    return n;
  }

  FiltrosCancionero copyWith({
    String? categoriaId,
    String? tag,
    bool? soloFavoritos,
    OrdenCancion? orden,
    bool? ascendente,
    bool limpiarCategoria = false,
    bool limpiarTag = false,
  }) {
    return FiltrosCancionero(
      categoriaId:
          limpiarCategoria ? null : (categoriaId ?? this.categoriaId),
      tag: limpiarTag ? null : (tag ?? this.tag),
      soloFavoritos: soloFavoritos ?? this.soloFavoritos,
      orden: orden ?? this.orden,
      ascendente: ascendente ?? this.ascendente,
    );
  }
}