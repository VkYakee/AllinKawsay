// lib/features/inicio/screens/inicio_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/animated_list_item.dart';

import '../../../models/cancion.dart';

import '../../../widgets/banner_novedades.dart';
import '../../../widgets/social_buttons.dart';

import '../../../screens/busqueda_global_screen.dart';
import '../../../screens/compartir_app_screen.dart';
import '../../../screens/historia_screen.dart';
import '../../../screens/zampona_screen.dart';

import '../../cancion_detalle/screens/cancion_detalle_screen.dart';
import '../../eventos/screens/evento_detalle_screen.dart';
import '../../recuerdos/screens/recuerdo_detalle_screen.dart';

import '../controllers/inicio_controller.dart';
import '../widgets/bento_cards.dart';

class InicioScreen extends StatefulWidget {
  final String nombreUsuario;
  const InicioScreen({super.key, required this.nombreUsuario});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late final InicioController _controller;
  bool _bannerCerrado = false;

  @override
  void initState() {
    super.initState();
    _controller = InicioController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _abrirDiscord() async {
    try {
      await launchUrl(
        Uri.parse('https://discord.gg/ojailbreaks'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: () async {
              _controller.refresh();
              await Future.delayed(const Duration(milliseconds: 400));
            },
            color: AppColors.dorado,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                _buildSliverAppBar(),
                if (_controller.proximoEvento != null && !_bannerCerrado)
                  SliverToBoxAdapter(
                    child: BannerNovedades(
                      icono: Icons.celebration,
                      titulo:
                          'Nuevo evento: ${_controller.proximoEvento!.titulo}',
                      subtitulo:
                          '${_controller.proximoEvento!.fecha.day}/${_controller.proximoEvento!.fecha.month} · ${_controller.proximoEvento!.lugar}',
                      onTap: () => setState(() => _bannerCerrado = true),
                      onCerrar: () => setState(() => _bannerCerrado = true),
                    ),
                  ),
                _buildProximoEvento(),
                _buildAccionesRapidas(),
                _buildUltimasCanciones(),
                _buildUltimoRecuerdo(),
                _buildHistoria(),
                const SliverToBoxAdapter(child: SizedBox(height: Sp.xl)),
                const SliverToBoxAdapter(child: Divider()),
                const SliverToBoxAdapter(child: SocialButtons()),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 220,
      backgroundColor: AppColors.fondoOscuro,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.granateOscuro,
                    AppColors.granate.withOpacity(0.6),
                    AppColors.fondoOscuro,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.dorado.withOpacity(0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, Sp.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const _HoyChip(),
                        const Spacer(),
                        _HeaderButton(
                          icon: Icons.search,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BusquedaGlobalScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: Sp.sm),
                        _HeaderButton(
                          icon: Icons.piano,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ZamponaScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _AvatarGlow(nombre: widget.nombreUsuario),
                        const SizedBox(width: Sp.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola,',
                                style: AppText.bodySm.copyWith(
                                  color: Colors.white.withOpacity(0.6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.nombreUsuario,
                                style: AppText.h2.copyWith(
                                  color: AppColors.dorado,
                                  fontSize: 24,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProximoEvento() {
    final evento = _controller.proximoEvento;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: Sp.xs),
        child: AnimatedListItem(
          index: 0,
          baseDelay: const Duration(milliseconds: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BentoSectionHeader(
                icon: Icons.event,
                titulo: 'PRÓXIMO EVENTO',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
                child: evento == null
                    ? BentoHeroCard(
                        icon: Icons.event_busy,
                        eyebrow: 'SIN EVENTOS',
                        titulo: 'Pronto habrá novedades',
                        subtitulo: 'Vuelve a chequear en unos días',
                        fallbackGradient: LinearGradient(
                          colors: [
                            AppColors.granate.withOpacity(0.5),
                            AppColors.granateOscuro,
                          ],
                        ),
                        onTap: () {},
                      )
                    : BentoHeroCard(
                        icon: Icons.event,
                        eyebrow: 'PRÓXIMO EVENTO',
                        titulo: evento.titulo,
                        subtitulo:
                            '${evento.fecha.day}/${evento.fecha.month} · ${evento.fecha.hour.toString().padLeft(2, '0')}:${evento.fecha.minute.toString().padLeft(2, '0')}${evento.lugar.isNotEmpty ? ' · ${evento.lugar}' : ''}',
                        fallbackGradient: AppColors.gradienteGranate,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventoDetalleScreen(evento: evento),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccionesRapidas() {
    return SliverToBoxAdapter(
      child: AnimatedListItem(
        index: 1,
        baseDelay: const Duration(milliseconds: 120),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.lg, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BentoSmallCard(
                  icon: Icons.qr_code_2,
                  titulo: 'Compartir',
                  subtitulo: 'Invita al grupo',
                  gradient: AppColors.gradienteDorado,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CompartirAppScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Sp.md),
              Expanded(
                child: BentoSmallCard(
                  icon: Icons.forum,
                  titulo: 'Comunidad',
                  subtitulo: 'Únete al Discord',
                  gradient: AppColors.gradienteGranate,
                  onTap: _abrirDiscord,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUltimasCanciones() {
    final canciones = _controller.ultimasCanciones;
    if (canciones.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BentoSectionHeader(
            icon: Icons.library_music,
            titulo: 'ÚLTIMAS CANCIONES',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
            child: Column(
              children: List.generate(canciones.length, (i) {
                final c = canciones[i];
                return AnimatedListItem(
                  index: i,
                  baseDelay: const Duration(milliseconds: 180),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Sp.sm),
                    child: _MiniCancionCard(
                      cancion: c,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CancionDetalleScreen(cancion: c),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltimoRecuerdo() {
    final r = _controller.ultimoRecuerdo;
    if (r == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BentoSectionHeader(
            icon: Icons.photo_library,
            titulo: 'ÚLTIMO RECUERDO',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
            child: AnimatedListItem(
              index: 0,
              baseDelay: const Duration(milliseconds: 240),
              child: BentoWideCard(
                imageUrl: r.fotos.isNotEmpty ? r.fotos.first : null,
                fallbackIcon: Icons.photo_library,
                eyebrow: 'RECUERDO',
                titulo: r.titulo,
                subtitulo:
                    '${r.fotos.length} fotos${r.videos.isNotEmpty ? ' · ${r.videos.length} videos' : ''}',
                fallbackGradient: AppColors.gradienteGranate,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecuerdoDetalleScreen(recuerdo: r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoria() {
    final h = _controller.historiaActual;
    if (h == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BentoSectionHeader(
            icon: Icons.auto_stories,
            titulo: 'NUESTRA HISTORIA',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
            child: AnimatedListItem(
              index: 0,
              baseDelay: const Duration(milliseconds: 300),
              child: BentoWideCard(
                fallbackIcon: Icons.auto_stories,
                eyebrow: 'HISTORIA',
                titulo: 'Cómo empezó el grupo',
                subtitulo: h.contenido.length > 60
                    ? '${h.contenido.substring(0, 60)}...'
                    : h.contenido,
                fallbackGradient: AppColors.gradienteDorado,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoriaScreen(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HEADER — CHIP HOY + BOTONES
// ═══════════════════════════════════════════════════════════

class _HoyChip extends StatelessWidget {
  const _HoyChip();

  static const _meses = [
    '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
  ];

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sp.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: Rad.rPill,
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.dorado,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'HOY · ${ahora.day} ${_meses[ahora.month]}',
            style: AppText.captionXs.copyWith(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.35),
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.3),
            ),
          ),
          child: Icon(widget.icon, color: AppColors.dorado, size: 18),
        ),
      ),
    );
  }
}

class _AvatarGlow extends StatelessWidget {
  final String nombre;
  const _AvatarGlow({required this.nombre});

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.gradienteDorado,
        boxShadow: [
          BoxShadow(
            color: AppColors.dorado.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.granate,
          border: Border.all(
            color: AppColors.granateOscuro,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          inicial,
          style: AppText.h3.copyWith(
            color: AppColors.dorado,
            fontSize: 22,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MINI CANCIÓN CARD
// ═══════════════════════════════════════════════════════════

class _MiniCancionCard extends StatefulWidget {
  final Cancion cancion;
  final VoidCallback onTap;

  const _MiniCancionCard({required this.cancion, required this.onTap});

  @override
  State<_MiniCancionCard> createState() => _MiniCancionCardState();
}

class _MiniCancionCardState extends State<_MiniCancionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        AppMotion.hapticLight();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Container(
          padding: const EdgeInsets.all(Sp.md),
          decoration: BoxDecoration(
            color: AppColors.surface(context).withOpacity(0.85),
            borderRadius: Rad.rLg,
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.gradienteGranate,
                  borderRadius: Rad.rMd,
                ),
                child: const Icon(
                  Icons.music_note,
                  color: AppColors.dorado,
                  size: 20,
                ),
              ),
              const SizedBox(width: Sp.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cancion.titulo,
                      style: AppText.subtitle.copyWith(color: onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.cancion.ritmo.isEmpty
                          ? 'Sin ritmo'
                          : widget.cancion.ritmo,
                      style: AppText.captionXs.copyWith(
                        color: onSurface.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
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