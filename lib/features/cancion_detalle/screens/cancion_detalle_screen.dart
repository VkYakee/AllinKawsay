// lib/features/cancion_detalle/screens/cancion_detalle_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

import '../../../models/cancion.dart';
import '../../../models/usuario.dart';

import '../../../services/audio_cache_service.dart';
import '../../../services/cancion_service.dart';
import '../../../services/player_service.dart';
import '../../../services/reproduccion_service.dart';
import '../../../services/usuario_service.dart';

import '../../cancionero/screens/agregar_cancion_screen.dart';
import '../../ensayo/screens/modo_ensayo_screen.dart';

import '../widgets/cancion_hero_elite.dart';
import '../widgets/cancion_partitura_glow.dart';
import '../widgets/cancion_tab_comentarios.dart';
import '../widgets/cancion_tab_info.dart';
import '../widgets/cancion_tab_letra.dart';

import 'compartir_imagen_screen.dart';
import 'presentacion_screen.dart';

class CancionDetalleScreen extends StatefulWidget {
  final Cancion cancion;
  const CancionDetalleScreen({super.key, required this.cancion});

  @override
  State<CancionDetalleScreen> createState() => _CancionDetalleScreenState();
}

class _CancionDetalleScreenState extends State<CancionDetalleScreen>
    with SingleTickerProviderStateMixin {
  final _player = PlayerService();
  late final TabController _tabCtrl;
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(_onTabChanged);
    _cargarUsuario();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabCtrl.removeListener(_onTabChanged);
    _tabCtrl.dispose();
    super.dispose();
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

  Future<void> _toggleFavorito() async {
    await UsuarioService().toggleFavorito(widget.cancion.id);
    await _cargarUsuario();
  }

  Future<void> _compartir() async {
    final c = widget.cancion;
    final sb = StringBuffer();
    sb.writeln('🎵 *${c.titulo}*');
    if (c.autor.isNotEmpty) sb.writeln('✍️ Autor: ${c.autor}');
    if (c.ritmo.isNotEmpty) sb.writeln('🎶 Ritmo: ${c.ritmo}');
    sb.writeln('\n— Enviado desde Allin Kawsay');

    final url = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(sb.toString())}',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _borrarCache() async {
    await AudioCacheService().borrar(widget.cancion.id);
    if (!mounted) return;
    _snack('Caché borrado');
  }

  Future<void> _editar() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarCancionScreen(cancion: widget.cancion),
      ),
    );
    if (res == true && mounted) Navigator.pop(context);
  }

  Future<void> _eliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Rad.rLg),
        backgroundColor: AppColors.surface(context),
        title: Text(
          'Eliminar canción',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        content: Text(
          '¿Eliminar "${widget.cancion.titulo}"? Esta acción no se puede deshacer.',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: AppText.subtitle.copyWith(
                color: AppColors.onSurfaceVariant(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Eliminar',
              style: AppText.subtitle.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await CancionService().eliminar(widget.cancion.id);
    if (mounted) Navigator.pop(context);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppText.body.copyWith(color: AppColors.dorado),
        ),
        backgroundColor: AppColors.granateOscuro,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    final esFavorito = _usuario?.esFavorito(c.id) ?? false;
    final esAdmin = _usuario?.esAdmin ?? false;
    final puedeComentar = _usuario?.puedeComentar ?? false;

    return ValueListenableBuilder<EstadoPlayer>(
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
                  pinned: true,
                  floating: false,
                  expandedHeight: 380,
                  backgroundColor: AppColors.fondoOscuro,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leading: _CircularBackButton(
                    onTap: () => Navigator.pop(context),
                  ),
                  actions: [
                    _CircularIconButton(
                      icon: Icons.share_outlined,
                      onTap: _compartir,
                    ),
                    const SizedBox(width: Sp.sm),
                    _buildMenu(context, esAdmin),
                    const SizedBox(width: Sp.md),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    titlePadding:
                        const EdgeInsets.fromLTRB(56, 0, 56, 16),
                    title: _TituloColapsado(
                      titulo: c.titulo,
                      mostrar: innerBoxIsScrolled,
                    ),
                    background: CancionHeroElite(
                      cancion: c,
                      esFavorito: esFavorito,
                      reproduciendo: reproduciendo,
                      cargando: cargando,
                      onTogglePlay: _togglePlay,
                      onToggleFavorito: _toggleFavorito,
                      onPracticar: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ModoEnsayoScreen(cancion: c),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: CancionPartituraGlow(
                    cancion: c,
                    sonando: reproduciendo,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    backgroundColor: AppColors.fondoOscuro,
                    child: _CustomTabBar(
                      controller: _tabCtrl,
                      tabs: const ['LETRA', 'INFO', 'COMENTARIOS'],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabCtrl,
              children: [
                CancionTabLetra(cancion: c),
                CancionTabInfo(cancion: c, usuario: _usuario),
                CancionTabComentarios(
                  cancion: c,
                  puedeComentar: puedeComentar,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenu(BuildContext context, bool esAdmin) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.dorado,
        size: 22,
      ),
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(borderRadius: Rad.rLg),
      offset: const Offset(0, 50),
      onSelected: (v) {
        switch (v) {
          case 'presentacion':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PresentacionScreen(cancion: widget.cancion),
              ),
            );
            break;
          case 'imagen':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CompartirImagenScreen(cancion: widget.cancion),
              ),
            );
            break;
          case 'cache':
            _borrarCache();
            break;
          case 'editar':
            _editar();
            break;
          case 'eliminar':
            _eliminar();
            break;
        }
      },
      itemBuilder: (_) => [
        if (esAdmin) ...[
          _menuItem(
            'editar',
            Icons.edit_outlined,
            'Editar canción',
            AppColors.onSurface(context),
          ),
          _menuItem(
            'eliminar',
            Icons.delete_outline,
            'Eliminar canción',
            Colors.red,
          ),
          const PopupMenuDivider(),
        ],
        _menuItem(
          'presentacion',
          Icons.fullscreen,
          'Modo presentación',
          AppColors.onSurface(context),
        ),
        _menuItem(
          'imagen',
          Icons.image_outlined,
          'Compartir imagen',
          AppColors.onSurface(context),
        ),
        _menuItem(
          'cache',
          Icons.refresh,
          'Borrar caché',
          AppColors.onSurface(context),
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: Sp.md),
          Text(label, style: AppText.subtitle.copyWith(color: color)),
        ],
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════
// TÍTULO QUE APARECE AL COLAPSAR
// ═══════════════════════════════════════════════════════════

class _TituloColapsado extends StatelessWidget {
  final String titulo;
  final bool mostrar;

  const _TituloColapsado({required this.titulo, required this.mostrar});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: mostrar ? 1.0 : 0.0,
      duration: AppMotion.fast,
      curve: AppMotion.easeOut,
      child: Text(
        titulo,
        style: AppText.title.copyWith(
          color: AppColors.dorado,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BOTONES CIRCULARES DEL APP BAR
// ═══════════════════════════════════════════════════════════

class _CircularBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircularBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _CircularIconButton(
        icon: Icons.arrow_back_ios_new,
        onTap: onTap,
      ),
    );
  }
}

class _CircularIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircularIconButton({required this.icon, required this.onTap});

  @override
  State<_CircularIconButton> createState() => _CircularIconButtonState();
}

class _CircularIconButtonState extends State<_CircularIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          AppMotion.hapticSelection();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.85 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.bouncy,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.45),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Icon(widget.icon, color: AppColors.dorado, size: 18),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TAB BAR CON INDICADOR SLIDING
// ═══════════════════════════════════════════════════════════

class _CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const _CustomTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animation ?? controller,
      builder: (context, _) {
        final pos = controller.animation?.value ?? 0.0;
        return LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / tabs.length;
            const indicatorWidth = 28.0;

            return Stack(
              children: [
                Container(
                  color: AppColors.fondoOscuro,
                  height: 48,
                ),
                Row(
                  children: List.generate(tabs.length, (i) {
                    final activo = (pos.round() == i);
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          AppMotion.hapticSelection();
                          controller.animateTo(i);
                        },
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: AppMotion.fast,
                              style: AppText.label.copyWith(
                                color: activo
                                    ? AppColors.dorado
                                    : AppColors.onSurfaceVariant(context)
                                        .withOpacity(0.5),
                                letterSpacing: 1.5,
                                fontSize: 11,
                                fontWeight: activo
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                              child: Text(tabs[i]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Stack(
                    children: [
                      Container(
                        height: 1,
                        color: AppColors.dorado.withOpacity(0.1),
                      ),
                      AnimatedPositioned(
                        duration: AppMotion.normal,
                        curve: AppMotion.spring,
                        left: (tabWidth * pos) +
                            (tabWidth - indicatorWidth) / 2,
                        bottom: 0,
                        child: Container(
                          width: indicatorWidth,
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradienteDorado,
                            borderRadius: Rad.rPill,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dorado.withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// DELEGATE DEL TAB BAR PINNED
// ═══════════════════════════════════════════════════════════

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  _TabBarDelegate({required this.child, required this.backgroundColor});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: backgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor;
}