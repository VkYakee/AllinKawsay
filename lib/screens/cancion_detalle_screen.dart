// lib/screens/cancion_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../design/design.dart';
import '../models/cancion.dart';
import '../models/usuario.dart';
import '../services/audio_cache_service.dart';
import '../services/player_service.dart';
import '../services/reproduccion_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/cancion_detalle/cancion_hero.dart';
import '../widgets/cancion_detalle/cancion_partitura_fija.dart';
import '../widgets/cancion_detalle/cancion_tab_comentarios.dart';
import '../widgets/cancion_detalle/cancion_tab_info.dart';
import '../widgets/cancion_detalle/cancion_tab_letra.dart';
import 'compartir_imagen_screen.dart';
import 'modo_ensayo_screen.dart';
import 'presentacion_screen.dart';

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

  Future<void> _compartir() async {
    final c = widget.cancion;
    final sb = StringBuffer();
    sb.writeln('🎵 *${c.titulo}*');
    if (c.autor.isNotEmpty) sb.writeln('✍️ Autor: ${c.autor}');
    if (c.ritmo.isNotEmpty) sb.writeln('🎶 Ritmo: ${c.ritmo}');
    sb.writeln('\n— Enviado desde Allin Kawsay');

    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(sb.toString())}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _borrarCache() async {
    await AudioCacheService().borrar(widget.cancion.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caché borrado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    final esFavorito = _usuario?.esFavorito(c.id) ?? false;
    final puedeComentar = _usuario?.puedeComentar ?? false;
    final puedeDescargar = _usuario?.puedeDescargar ?? false;

    return DefaultTabController(
      length: 3,
      child: ValueListenableBuilder<EstadoPlayer>(
        valueListenable: _player.estado,
        builder: (context, estado, _) {
          final sonando = estado.cancionId == c.id;
          final reproduciendo = sonando && estado.playing;
          final cargando = sonando && estado.cargando;

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 0,
                    pinned: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: _compartir,
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (v) {
                          if (v == 'presentacion') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => PresentacionScreen(cancion: c)));
                          } else if (v == 'imagen') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => CompartirImagenScreen(cancion: c)));
                          } else if (v == 'cache') {
                            _borrarCache();
                          }
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
                  SliverToBoxAdapter(
                    child: CancionPartituraFija(cancion: c),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        indicatorColor: AppColors.dorado,
                        labelColor: AppColors.granate,
                        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        labelStyle: AppType.label.copyWith(letterSpacing: 1),
                        tabs: const [
                          Tab(text: 'LETRA'),
                          Tab(text: 'INFO'),
                          Tab(text: 'COMENTARIOS'),
                        ],
                      ),
                      Theme.of(context).scaffoldBackgroundColor,
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
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}