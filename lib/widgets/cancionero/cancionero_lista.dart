// lib/widgets/cancionero/cancionero_lista.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/cancion.dart';
import '../../services/player_service.dart';
import 'fila_indice.dart';
import 'tarjeta_cancion.dart';

class CancioneroLista extends StatelessWidget {
  final List<Cancion> canciones;
  final List<String> favoritos;
  final bool esAdmin;
  final bool modoIndice;
  final EstadoPlayer estado;
  final void Function(Cancion) onTap;
  final void Function(Cancion) onTogglePlay;
  final void Function(Cancion) onToggleFavorito;
  final void Function(Cancion) onEditar;
  final void Function(Cancion) onEliminar;

  const CancioneroLista({
    super.key,
    required this.canciones,
    required this.favoritos,
    required this.esAdmin,
    required this.modoIndice,
    required this.estado,
    required this.onTap,
    required this.onTogglePlay,
    required this.onToggleFavorito,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (canciones.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: 'Sin resultados',
        subtitle:
            'Prueba con otros filtros o términos de búsqueda',
      );
    }
    if (modoIndice) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: Sp.sm, bottom: 100),
        itemCount: canciones.length,
        itemBuilder: (context, i) {
          final c = canciones[i];
          return FilaIndice(cancion: c, onTap: () => onTap(c));
        },
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: Sp.sm, bottom: 100),
      itemCount: canciones.length,
      itemBuilder: (context, i) {
        final c = canciones[i];
        return TarjetaCancion(
          cancion: c,
          esFavorito: favoritos.contains(c.id),
          esAdmin: esAdmin,
          estado: estado,
          onTap: () => onTap(c),
          onTogglePlay: () => onTogglePlay(c),
          onToggleFavorito: () => onToggleFavorito(c),
          onEditar: () => onEditar(c),
          onEliminar: () => onEliminar(c),
        );
      },
    );
  }
}