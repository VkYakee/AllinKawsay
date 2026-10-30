// lib/features/cancion_detalle/screens/cancion_detalle_screen.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/cancion.dart';
import '../../../models/usuario.dart';
import '../../../services/player_service.dart';
import '../../../services/reproduccion_service.dart';
import '../../../services/usuario_service.dart';
import '../../../screens/modo_ensayo_screen.dart'; // Se migrará después
import '../../../widgets/cancion_detalle/cancion_partitura_fija.dart'; // Usamos el visor viejo por ahora
import '../../../widgets/cancion_detalle/cancion_tab_comentarios.dart'; // Usamos el viejo por ahora
import '../../../widgets/cancion_detalle/cancion_tab_info.dart'; // Usamos el viejo por ahora
import '../widgets/cancion_hero.dart';
import '../widgets/cancion_tab_letra.dart';

class CancionDetalleScreen extends StatefulWidget {
  final Cancion cancion;
  const CancionDetalleScreen({super.key, required this.cancion});

  @override
  State<CancionDetalleScreen> createState() => _CancionDetalleScreenState();
}

class _CancionDetalleScreenState extends State<CancionDetalleScreen> {
  final _player = PlayerService();
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  Future<void> _togglePlay() async {
    final yaSonaba = _player.sonando(widget.cancion.id);
    await _player.toggle(widget.cancion);
    if (_player.sonando(widget.cancion.id) && !yaSonaba) {
      await ReproduccionService.contarUnaVez(widget.cancion.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    final esFavorito = _usuario?.esFavorito(c.id) ?? false;
    final puedeComentar = _usuario?.puedeComentar ?? false;

    return DefaultTabController(
      length: 3,
      child: ValueListenableBuilder<EstadoPlayer>(
        valueListenable: _player.estado,
        builder: (context, estado, _) {
          final sonando = estado.cancionId == c.id;
          final reproduciendo = sonando && estado.playing;
          final cargando = sonando && estado.cargando;

          return Scaffold(
            backgroundColor: AppColors.fondoOscuro,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: AppColors.fondoOscuro,
                    elevation: 0,
                    pinned: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share, color: AppColors.dorado),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compartir en construcción')));
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppColors.dorado),
                        onSelected: (v) {
                          // Acciones pendientes de migrar
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'presentacion', child: Text('Modo Presentación')),
                          PopupMenuItem(value: 'imagen', child: Text('Compartir Imagen')),
                          PopupMenuItem(value: 'cache', child: Text('Borrar caché')),
                        ],
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: CancionHero(
                      cancion: c,
                      esFavorito: esFavorito,
                      reproduciendo: reproduciendo,
                      cargando: cargando,
                      onToggleFavorito: () async {
                        await UsuarioService().toggleFavorito(c.id);
                        await _cargarUsuario();
                      },
                      onTogglePlay: _togglePlay,
                      onPracticar: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ModoEnsayoScreen(cancion: c)));
                      },
                    ),
                  ),
                  SliverToBoxAdapter(child: CancionPartituraFija(cancion: c)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        indicatorColor: AppColors.dorado,
                        labelColor: AppColors.dorado,
                        unselectedLabelColor: Colors.white54,
                        labelStyle: AppText.label.copyWith(letterSpacing: 1),
                        tabs: const [
                          Tab(text: 'LETRA'),
                          Tab(text: 'INFO'),
                          Tab(text: 'COMENTARIOS'),
                        ],
                      ),
                      AppColors.fondoOscuro,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  CancionTabLetra(cancion: c),
                  CancionTabInfo(cancion: c, usuario: _usuario),
                  CancionTabComentarios(cancion: c, puedeComentar: puedeComentar),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _TabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}