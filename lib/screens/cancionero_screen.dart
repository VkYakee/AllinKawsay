import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../models/categoria.dart';
import '../models/usuario.dart';
import '../services/cancion_service.dart';
import '../services/categoria_service.dart';
import '../services/player_service.dart';
import '../services/reproduccion_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/comunes/empty_state.dart';
import '../widgets/comunes/error_state.dart';
import '../widgets/watermark_overlay.dart';
import 'agregar_cancion_screen.dart';
import 'cancion_detalle_screen.dart';
import 'modo_ensayo_screen.dart';

enum _OrdenCancion { fecha, titulo, autor, reproducciones }

enum _ModoVista { tarjetas, indice }

class CancioneroScreen extends StatefulWidget {
  const CancioneroScreen({super.key});

  @override
  State<CancioneroScreen> createState() => _CancioneroScreenState();
}

class _CancioneroScreenState extends State<CancioneroScreen> {
  final _service = CancionService();
  final _searchCtrl = TextEditingController();
  bool _esAdmin = false;
  String _query = '';
  String? _tagFiltro;
  String? _categoriaFiltro;
  bool _soloFavoritos = false;
  _OrdenCancion _orden = _OrdenCancion.titulo;
  bool _ascendente = true;
  _ModoVista _modoVista = _ModoVista.tarjetas;

  @override
  void initState() {
    super.initState();
    _chequearAdmin();
  }

  Future<void> _chequearAdmin() async {
    final a = await UsuarioService().soyAdmin();
    if (mounted) setState(() => _esAdmin = a);
  }

  Future<void> _onRefresh() async {
    await _chequearAdmin();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _togglePlayReproduccion(Cancion c) async {
    final estabaSonando = PlayerService().sonando(c.id);
    await PlayerService().toggle(c);
    final sonandoAhora = PlayerService().sonando(c.id);
    if (sonandoAhora && !estabaSonando) {
      await ReproduccionService.contarUnaVez(c.id);
    }
  }

  void _abrirCancion(Cancion c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CancionDetalleScreen(cancion: c),
      ),
    );
  }

  void _toggleModoVista() {
    setState(() {
      _modoVista = _modoVista == _ModoVista.tarjetas
          ? _ModoVista.indice
          : _ModoVista.tarjetas;
    });
  }

  /// Abre un selector para elegir qué canción practicar.
  /// Solo muestra canciones que tienen numerofonía cargada.
  Future<void> _abrirSelectorEnsayo() async {
    final canciones = await _service.listar().first;
    final conNumerofonia =
        canciones.where((c) => c.tieneNumerofonia).toList();

    if (!mounted) return;

    if (conNumerofonia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No hay canciones con numerofonía para practicar todavía'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollCtrl) {
          final onSurface = Theme.of(context).colorScheme.onSurface;
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dorado,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¿QUÉ QUERÉS PRACTICAR?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${conNumerofonia.length} canciones disponibles',
                style: TextStyle(
                  fontSize: 11,
                  color: onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: conNumerofonia.length,
                  itemBuilder: (context, i) {
                    final c = conNumerofonia[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ModoEnsayoScreen(cancion: c),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardColor(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.dorado
                                      .withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient:
                                        AppColors.gradienteGranate,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    color: AppColors.dorado,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.titulo,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${c.estrofas.where((e) => !e.vacia).length} estrofa(s)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: onSurface
                                              .withOpacity(0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.play_circle_outline,
                                  color: AppColors.dorado
                                      .withOpacity(0.7),
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _eliminar(Cancion c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar canción',
            style: TextStyle(
                color: AppColors.granate, fontWeight: FontWeight.bold)),
        content: Text(
            '¿Eliminar "${c.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.eliminar(c.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Canción "${c.titulo}" eliminada')),
        );
      }
    }
  }

  void _editar(Cancion c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgregarCancionScreen(cancion: c)),
    );
  }

  void _abrirMenuOrden() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dorado,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ordenar por',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _itemOrden('Título (A-Z)', _OrdenCancion.titulo),
            _itemOrden('Autor (A-Z)', _OrdenCancion.autor),
            _itemOrden('Más reproducidas', _OrdenCancion.reproducciones),
            _itemOrden('Fecha de subida', _OrdenCancion.fecha),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _itemOrden(String label, _OrdenCancion valor) {
    final selected = _orden == valor;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.granate
              : AppColors.granate.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.dorado : AppColors.granate,
          size: 20,
        ),
      ),
      title: Text(label,
          style: TextStyle(
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal)),
      trailing: selected
          ? IconButton(
              icon: Icon(
                _ascendente
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: AppColors.granate,
              ),
              onPressed: () {
                setState(() => _ascendente = !_ascendente);
                Navigator.pop(context);
              },
            )
          : null,
      onTap: () {
        setState(() {
          _orden = valor;
          if (valor == _OrdenCancion.fecha ||
              valor == _OrdenCancion.reproducciones) {
            _ascendente = false;
          } else {
            _ascendente = true;
          }
        });
        Navigator.pop(context);
      },
    );
  }

  List<Cancion> _filtrar(List<Cancion> lista, List<String> favoritos) {
    var r = lista;

    if (_soloFavoritos) {
      r = r.where((c) => favoritos.contains(c.id)).toList();
    }

    if (_categoriaFiltro != null && _categoriaFiltro!.isNotEmpty) {
      r = r.where((c) => c.categoriaId == _categoriaFiltro).toList();
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      r = r.where((c) =>
          c.titulo.toLowerCase().contains(q) ||
          c.autor.toLowerCase().contains(q) ||
          c.ritmo.toLowerCase().contains(q) ||
          c.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }

    if (_tagFiltro != null) {
      r = r.where((c) => c.tags.contains(_tagFiltro)).toList();
    }

    r.sort((a, b) {
      int cmp;
      switch (_orden) {
        case _OrdenCancion.titulo:
          cmp =
              a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
          break;
        case _OrdenCancion.autor:
          cmp = a.autor.toLowerCase().compareTo(b.autor.toLowerCase());
          break;
        case _OrdenCancion.reproducciones:
          cmp = a.reproducciones.compareTo(b.reproducciones);
          break;
        case _OrdenCancion.fecha:
        default:
          final fa = a.fechaCreacion ?? DateTime(2000);
          final fb = b.fechaCreacion ?? DateTime(2000);
          cmp = fa.compareTo(fb);
          break;
      }
      return _ascendente ? cmp : -cmp;
    });

    return r;
  }

  List<Cancion> _ordenarAlfabetico(List<Cancion> lista) {
    final copia = List<Cancion>.from(lista);
    copia.sort((a, b) =>
        a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
    return copia;
  }

  List<String> _todosLosTags(List<Cancion> lista) {
    final set = <String>{};
    for (final c in lista) {
      set.addAll(c.tags);
    }
    final l = set.toList()..sort();
    return l;
  }

  String _nombreOrden() {
    switch (_orden) {
      case _OrdenCancion.titulo:
        return 'Título';
      case _OrdenCancion.autor:
        return 'Autor';
      case _OrdenCancion.reproducciones:
        return 'Reproducciones';
      case _OrdenCancion.fecha:
      default:
        return 'Fecha';
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    floatingActionButton: _esAdmin
        ? FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AgregarCancionScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('NUEVA'),
          )
        : null,
    body: WatermarkOverlay(
      opacity: 0.04,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.dorado,
        child: StreamBuilder<Usuario?>(
          stream: UsuarioService().miUsuario(),
          builder: (context, userSnap) {
            final favs = userSnap.data?.favoritos ?? <String>[];
            return ValueListenableBuilder<EstadoPlayer>(
              valueListenable: PlayerService().estado,
              builder: (context, estado, _) {
                return Column(
                  children: [
                    _buildBarraBusqueda(),
                    _buildInfoOrden(),
                    Expanded(
                      child: StreamBuilder<List<Cancion>>(
                        stream: _service.listar(),
                        builder: (context, snap) {
                          if (snap.connectionState ==
                                  ConnectionState.waiting &&
                              !snap.hasData) {
                            return const _LoadingSkeleton();
                          }
                          if (snap.hasError) {
                            return ErrorState(
                              titulo: 'Error al cargar canciones',
                              detalle: snap.error.toString(),
                              onRetry: () => setState(() {}),
                            );
                          }
                          final lista = snap.data ?? [];
                          if (lista.isEmpty) {
                            return EmptyState(
                              icono: Icons.library_music,
                              titulo: 'Aún no hay canciones',
                              subtitulo: _esAdmin
                                  ? 'Toca el botón NUEVA para agregar la primera'
                                  : 'El admin aún no ha subido canciones',
                            );
                          }
                          return _buildContenido(
                              lista, favs, estado, context);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    ),
  );
}

PreferredSizeWidget _buildAppBar() {
  return AppBar(
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('CANCIONERO', style: TextStyle(letterSpacing: 2)),
        const SizedBox(width: 8),
        StreamBuilder<List<Cancion>>(
          stream: _service.listar(),
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox.shrink();
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.dorado.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${snap.data!.length}',
                style: const TextStyle(
                  color: AppColors.dorado,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ],
    ),
    actions: [
      // 🏋️ Modo ensayo
      IconButton(
        icon: const Icon(Icons.school),
        tooltip: 'Practicar',
        onPressed: _abrirSelectorEnsayo,
      ),
      // Toggle entre vistas
      IconButton(
        icon: Icon(
          _modoVista == _ModoVista.tarjetas
              ? Icons.view_list_rounded
              : Icons.grid_view_rounded,
        ),
        tooltip: _modoVista == _ModoVista.tarjetas
            ? 'Vista índice'
            : 'Vista tarjetas',
        onPressed: _toggleModoVista,
      ),
      // Menú de orden (solo visible en modo tarjetas)
      if (_modoVista == _ModoVista.tarjetas)
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: 'Ordenar',
          onPressed: _abrirMenuOrden,
        ),
      const SizedBox(width: 4),
    ],
  );
}

Widget _buildBarraBusqueda() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _query = v),
      decoration: InputDecoration(
        hintText: 'Buscar canción, autor, ritmo...',
        prefixIcon: const Icon(Icons.search,
            color: AppColors.granate, size: 22),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              )
            : null,
      ),
    ),
  );
}

Widget _buildInfoOrden() {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  final texto = _modoVista == _ModoVista.indice
      ? 'Ordenado alfabéticamente (A-Z)'
      : 'Ordenado por ${_nombreOrden()} ${_ascendente ? '↑' : '↓'}';
  final icono = _modoVista == _ModoVista.indice
      ? Icons.sort_by_alpha
      : Icons.sort;

  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icono, size: 11, color: AppColors.granate),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(
            fontSize: 11,
            color: onSurface.withOpacity(0.55),
            letterSpacing: 0.3,
          ),
        ),
      ],
    ),
  );
}

Widget _buildContenido(List<Cancion> lista, List<String> favs,
    EstadoPlayer estado, BuildContext context) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  final tags = _todosLosTags(lista);
  final filtradas = _filtrar(lista, favs);
  final hayFavs = favs.isNotEmpty;

  return Column(
    children: [
      StreamBuilder<List<Categoria>>(
        stream: CategoriaService().listar(),
        builder: (context, catSnap) {
          final cats = catSnap.data ?? [];
          return Column(
            children: [
              if (cats.isNotEmpty) _buildChipsCategorias(cats, onSurface),
              _buildChipsTags(tags, onSurface),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
      Expanded(
        child: filtradas.isEmpty
            ? Center(
                child: Text(
                  _soloFavoritos && !hayFavs
                      ? 'Aún no marcaste favoritos'
                      : 'Sin resultados',
                  style: TextStyle(
                      color: onSurface.withOpacity(0.5),
                      fontStyle: FontStyle.italic),
                ),
              )
            : _modoVista == _ModoVista.tarjetas
                ? _buildListaTarjetas(
                    filtradas, favs, estado, onSurface)
                : _buildListaIndice(filtradas, onSurface),
      ),
    ],
  );
}

Widget _buildChipsCategorias(List<Categoria> cats, Color onSurface) {
  return SizedBox(
    height: 38,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final cat in cats)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${cat.emoji} ${cat.nombre}'),
              selected: _categoriaFiltro == cat.id,
              selectedColor: AppColors.granate,
              labelStyle: TextStyle(
                color: _categoriaFiltro == cat.id
                    ? AppColors.dorado
                    : onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (sel) => setState(
                  () => _categoriaFiltro = sel ? cat.id : null),
            ),
          ),
      ],
    ),
  );
}

Widget _buildChipsTags(List<String> tags, Color onSurface) {
  return SizedBox(
    height: 38,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        FilterChip(
          avatar: Icon(
            _soloFavoritos ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: _soloFavoritos
                ? AppColors.granate
                : onSurface.withOpacity(0.5),
          ),
          label: const Text('Favoritos'),
          selected: _soloFavoritos,
          selectedColor: AppColors.dorado.withOpacity(0.4),
          labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: onSurface),
          onSelected: (sel) => setState(() => _soloFavoritos = sel),
        ),
        const SizedBox(width: 8),
        if (_tagFiltro != null) ...[
          ActionChip(
            avatar: const Icon(Icons.close, size: 16),
            label: const Text('Limpiar'),
            onPressed: () => setState(() => _tagFiltro = null),
            backgroundColor: AppColors.granate.withOpacity(0.2),
          ),
          const SizedBox(width: 8),
        ],
        for (final t in tags)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(t),
              selected: _tagFiltro == t,
              selectedColor: AppColors.granate,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _tagFiltro == t ? AppColors.dorado : onSurface,
              ),
              onSelected: (sel) =>
                  setState(() => _tagFiltro = sel ? t : null),
            ),
          ),
      ],
    ),
  );
}
  Widget _buildListaTarjetas(List<Cancion> filtradas,
      List<String> favs, EstadoPlayer estado, Color onSurface) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: filtradas.length,
      itemBuilder: (context, i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (i * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _tarjetaCancion(
              context, filtradas[i], i, favs, estado, onSurface),
        );
      },
    );
  }

  Widget _tarjetaCancion(
    BuildContext context,
    Cancion c,
    int index,
    List<String> favs,
    EstadoPlayer estado,
    Color onSurface,
  ) {
    final esFav = favs.contains(c.id);
    final sonando = estado.cancionId == c.id;
    final reproduciendo = sonando && estado.playing;
    final cargando = sonando && estado.cargando;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _abrirCancion(c),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: sonando
                    ? AppColors.dorado.withOpacity(0.6)
                    : AppColors.dorado.withOpacity(0.2),
                width: sonando ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _togglePlayReproduccion(c),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: reproduciendo
                          ? AppColors.gradienteDorado
                          : AppColors.gradienteGranate,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: (reproduciendo
                                  ? AppColors.dorado
                                  : AppColors.granate)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: cargando
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                                color: AppColors.dorado,
                                strokeWidth: 2.5),
                          )
                        : Icon(
                            reproduciendo
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: reproduciendo
                                ? AppColors.granate
                                : AppColors.dorado,
                            size: 30,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${c.ritmo}${c.autor.isNotEmpty ? ' · ${c.autor}' : ''}',
                        style: TextStyle(
                            fontSize: 12,
                            color: onSurface.withOpacity(0.55)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.granate.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow,
                                    size: 10,
                                    color: AppColors.granate),
                                const SizedBox(width: 2),
                                Text(
                                  '${c.reproducciones}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.granate,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          if (c.tieneCategoria)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.folder_outlined,
                                  size: 12,
                                  color: onSurface.withOpacity(0.35)),
                            ),
                          if (c.tieneNumerofonia)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.grid_on,
                                  size: 12,
                                  color: onSurface.withOpacity(0.35)),
                            ),
                          if (c.audioUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.audiotrack,
                                  size: 12,
                                  color: onSurface.withOpacity(0.35)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    esFav ? Icons.favorite : Icons.favorite_border,
                    color: esFav
                        ? AppColors.granate
                        : onSurface.withOpacity(0.3),
                    size: 22,
                  ),
                  onPressed: () =>
                      UsuarioService().toggleFavorito(c.id),
                ),
                if (_esAdmin)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: onSurface.withOpacity(0.5), size: 22),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onSelected: (v) {
                      if (v == 'editar') {
                        _editar(c);
                      } else if (v == 'eliminar') {
                        _eliminar(c);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                size: 20, color: AppColors.granate),
                            SizedBox(width: 10),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 20, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListaIndice(List<Cancion> filtradas, Color onSurface) {
    final ordenadas = _ordenarAlfabetico(filtradas);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: ordenadas.length,
      itemBuilder: (context, i) {
        final c = ordenadas[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 200 + (i * 20)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _filaIndice(context, c, onSurface),
        );
      },
    );
  }

  Widget _filaIndice(
      BuildContext context, Cancion c, Color onSurface) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirCancion(c),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.dorado.withOpacity(0.15),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  c.titulo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.dorado.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 180,
                          height: 16,
                          color: Colors.grey.withOpacity(0.1)),
                      const SizedBox(height: 6),
                      Container(
                          width: 120,
                          height: 12,
                          color: Colors.grey.withOpacity(0.1)),
                      const SizedBox(height: 8),
                      Container(
                          width: 60,
                          height: 14,
                          color: Colors.grey.withOpacity(0.1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}