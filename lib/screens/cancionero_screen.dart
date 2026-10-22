// lib/screens/cancionero_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/cancion.dart';
import '../models/categoria.dart';
import '../models/usuario.dart';
import '../services/cancion_service.dart';
import '../services/categoria_service.dart';
import '../services/player_service.dart';
import '../services/reproduccion_service.dart';
import '../services/usuario_service.dart';
import '../widgets/cancionero/cancionero_busqueda.dart';
import '../widgets/cancionero/cancionero_hero.dart';
import '../widgets/cancionero/cancionero_lista.dart';
import '../widgets/cancionero/filtrar_canciones.dart';
import '../widgets/cancionero/filtros_cancionero.dart';
import '../widgets/cancionero/filtros_sheet.dart';
import '../widgets/cancionero/selector_ensayo.dart';
import 'agregar_cancion_screen.dart';
import 'cancion_detalle_screen.dart';

class CancioneroScreen extends StatefulWidget {
  const CancioneroScreen({super.key});
  @override
  State<CancioneroScreen> createState() => _CancioneroScreenState();
}

class _CancioneroScreenState extends State<CancioneroScreen> {
  final _searchCtrl = TextEditingController();
  final _service = CancionService();
  String _query = '';
  FiltrosCancionero _filtros = const FiltrosCancionero();
  bool _modoIndice = false;
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    UsuarioService().soyAdmin().then((a) {
      if (mounted) setState(() => _esAdmin = a);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(Cancion c) async {
    final yaSonaba = PlayerService().sonando(c.id);
    await PlayerService().toggle(c);
    if (PlayerService().sonando(c.id) && !yaSonaba) {
      await ReproduccionService.contarUnaVez(c.id);
    }
  }

  void _abrir(Cancion c) => Navigator.push(context, MaterialPageRoute(builder: (_) => CancionDetalleScreen(cancion: c)));

  Future<void> _abrirFiltros(List<Categoria> cats, List<String> tags) async {
    final r = await FiltrosSheet.mostrar(context, actual: _filtros, categorias: cats, tags: tags);
    if (r != null) setState(() => _filtros = r);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // MAGIA: Subimos el botón con un Padding
      floatingActionButton: _esAdmin 
        ? Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgregarCancionScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Nueva'),
            ),
          )
        : null,
      body: _streams(),
    );
  }

  Widget _streams() {
    return StreamBuilder<List<Categoria>>(
      stream: CategoriaService().listar(),
      builder: (context, catSnap) {
        final cats = catSnap.data ?? [];
        return StreamBuilder<Usuario?>(
          stream: UsuarioService().miUsuario(),
          builder: (context, uSnap) {
            final favs = uSnap.data?.favoritos ?? <String>[];
            return StreamBuilder<List<Cancion>>(
              stream: _service.listar(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                  return const AppSkeletonList(items: 6);
                }
                final todas = snap.data ?? [];
                final tags = <String>{...todas.expand((c) => c.tags)}.toList()..sort();
                return _cuerpo(todas, favs, cats, tags);
              },
            );
          },
        );
      },
    );
  }

  Widget _cuerpo(List<Cancion> todas, List<String> favs, List<Categoria> cats, List<String> tags) {
    final filtradas = filtrarCanciones(todas, favs, _filtros, _query);
    return ValueListenableBuilder<EstadoPlayer>(
      valueListenable: PlayerService().estado,
      builder: (context, estado, _) => Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CancioneroHero(
                totalCanciones: todas.length,
                filtrosActivos: _filtros.activos,
                modoIndice: _modoIndice,
                onFiltros: () => _abrirFiltros(cats, tags),
                onToggleVista: () => setState(() => _modoIndice = !_modoIndice),
                onPracticar: () => SelectorEnsayo.mostrar(context, todas),
              ),
              Positioned(
                bottom: -24, left: 0, right: 0,
                child: CancioneroBusqueda(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () { _searchCtrl.clear(); setState(() => _query = ''); },
                  hasText: _query.isNotEmpty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: CancioneroLista(
              canciones: filtradas,
              favoritos: favs,
              modoIndice: _modoIndice,
              estado: estado,
              onTap: _abrir,
              onTogglePlay: _togglePlay,
              onToggleFavorito: (c) => UsuarioService().toggleFavorito(c.id),
            ),
          ),
        ],
      ),
    );
  }
}