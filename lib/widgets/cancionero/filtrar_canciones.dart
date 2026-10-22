// lib/widgets/cancionero/filtrar_canciones.dart
import '../../models/cancion.dart';
import 'filtros_cancionero.dart';

List<Cancion> filtrarCanciones(
  List<Cancion> todas,
  List<String> favoritos,
  FiltrosCancionero f,
  String query,
) {
  var r = todas;
  if (f.soloFavoritos) {
    r = r.where((c) => favoritos.contains(c.id)).toList();
  }
  if (f.categoriaId != null) {
    r = r.where((c) => c.categoriaId == f.categoriaId).toList();
  }
  if (f.tag != null) {
    r = r.where((c) => c.tags.contains(f.tag)).toList();
  }
  if (query.isNotEmpty) {
    final q = query.toLowerCase();
    r = r
        .where((c) =>
            c.titulo.toLowerCase().contains(q) ||
            c.autor.toLowerCase().contains(q) ||
            c.ritmo.toLowerCase().contains(q) ||
            c.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }
  r = List<Cancion>.from(r);
  r.sort((a, b) {
    int cmp;
    switch (f.orden) {
      case OrdenCancion.titulo:
        cmp = a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
        break;
      case OrdenCancion.autor:
        cmp = a.autor.toLowerCase().compareTo(b.autor.toLowerCase());
        break;
      case OrdenCancion.reproducciones:
        cmp = a.reproducciones.compareTo(b.reproducciones);
        break;
      case OrdenCancion.recientes:
        final fa = a.fechaCreacion ?? DateTime(2000);
        final fb = b.fechaCreacion ?? DateTime(2000);
        cmp = fa.compareTo(fb);
        break;
    }
    return f.ascendente ? cmp : -cmp;
  });
  return r;
}