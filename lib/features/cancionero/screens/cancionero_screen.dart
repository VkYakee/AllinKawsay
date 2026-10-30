// lib/features/cancionero/screens/cancionero_screen.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_button.dart';
import '../../../core/widgets/animated_list_item.dart';

import '../../../models/cancion.dart';

import '../../cancion_detalle/screens/cancion_detalle_screen.dart';
import '../controllers/cancionero_controller.dart';
import '../widgets/tarjeta_cancion_elite.dart';
import 'agregar_cancion_screen.dart';

class CancioneroScreen extends StatefulWidget {
  const CancioneroScreen({super.key});

  @override
  State<CancioneroScreen> createState() => _CancioneroScreenState();
}

class _CancioneroScreenState extends State<CancioneroScreen> {
  late final CancioneroController _controller;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = CancioneroController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _abrirDetalle(Cancion c) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: AppMotion.normal,
        reverseTransitionDuration: AppMotion.fast,
        pageBuilder: (_, __, ___) => CancionDetalleScreen(cancion: c),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: AppMotion.easeOutQuart,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(),
              _buildBuscador(),
              if (_controller.loading)
                _buildSkeletonList()
              else if (_controller.canciones.isEmpty)
                _buildEmptyState()
              else
                _buildLista(),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.esAdmin) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: _FabNueva(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AgregarCancionScreen(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SLIVER APP BAR COLAPSABLE
  // ═══════════════════════════════════════════════════════════

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.fondoOscuro,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      floating: false,
      expandedHeight: 160,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.lg),
        expandedTitleScale: 1.6,
        title: Text(
          'Cancionero',
          style: AppText.h3.copyWith(
            color: AppColors.dorado,
            letterSpacing: -0.3,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.granateOscuro,
                    AppColors.granate.withOpacity(0.7),
                    AppColors.fondoOscuro,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            // Glow dorado radial
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.dorado.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Contador y subtítulo en la esquina inferior derecha
            Positioned(
              right: Sp.lg,
              bottom: Sp.lg,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sp.md,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: Rad.rPill,
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${_controller.canciones.length} canciones',
                      style: AppText.captionXs.copyWith(
                        color: AppColors.dorado,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUSCADOR FLOTANTE
  // ═══════════════════════════════════════════════════════════

  Widget _buildBuscador() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, Sp.md),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context).withOpacity(0.85),
            borderRadius: Rad.rLg,
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            onChanged: _controller.setQuery,
            style: AppText.body.copyWith(
              color: AppColors.onSurface(context),
            ),
            decoration: InputDecoration(
              hintText: 'Buscar canción, autor o ritmo...',
              hintStyle: AppText.body.copyWith(
                color: AppColors.onSurfaceVariant(context).withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.granate.withOpacity(0.7),
                size: 22,
              ),
              suffixIcon: _controller.query.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.onSurfaceVariant(context),
                        size: 18,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        _controller.clearQuery();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Sp.lg,
                vertical: Sp.lg,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LISTA
  // ═══════════════════════════════════════════════════════════

  Widget _buildLista() {
    final canciones = _controller.canciones;
    return SliverList.builder(
      itemCount: canciones.length,
      itemBuilder: (context, i) {
        final c = canciones[i];
        return AnimatedListItem(
          index: i,
          interval: const Duration(milliseconds: 40),
          child: TarjetaCancionElite(
            cancion: c,
            esFavorito: _controller.favoritos.contains(c.id),
            estado: _controller.estado,
            onTap: () => _abrirDetalle(c),
            onTogglePlay: () => _controller.togglePlay(c),
            onToggleFavorito: () => _controller.toggleFavorito(c.id),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SKELETON
  // ═══════════════════════════════════════════════════════════

  Widget _buildSkeletonList() {
    return SliverList.builder(
      itemCount: 8,
      itemBuilder: (context, i) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 5),
        child: _SkeletonCard(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: AppMotion.reveal,
                curve: AppMotion.easeOutQuart,
                builder: (context, v, child) {
                  return Transform.scale(
                    scale: 0.7 + 0.3 * v,
                    child: Opacity(opacity: v, child: child),
                  );
                },
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.granate.withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Icon(
                    _controller.query.isEmpty
                        ? Icons.library_music_outlined
                        : Icons.search_off,
                    size: 48,
                    color: AppColors.dorado.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: Sp.xl),
              Text(
                _controller.query.isEmpty
                    ? 'Aún no hay canciones'
                    : 'Sin resultados',
                textAlign: TextAlign.center,
                style: AppText.h3.copyWith(color: AppColors.dorado),
              ),
              const SizedBox(height: Sp.xs),
              Text(
                _controller.query.isEmpty
                    ? 'El cancionero se irá llenando poco a poco'
                    : 'Probá con otro título, autor o ritmo',
                textAlign: TextAlign.center,
                style: AppText.bodySm.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FAB NUEVA CANCIÓN
// ═══════════════════════════════════════════════════════════

class _FabNueva extends StatefulWidget {
  final VoidCallback onTap;

  const _FabNueva({required this.onTap});

  @override
  State<_FabNueva> createState() => _FabNuevaState();
}

class _FabNuevaState extends State<_FabNueva> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        AppMotion.hapticHeavy();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.bouncy,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Sp.lg,
            vertical: Sp.md,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.gradienteGranate,
            borderRadius: Rad.rPill,
            boxShadow: [
              BoxShadow(
                color: AppColors.granate.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: AppColors.dorado, size: 22),
              const SizedBox(width: Sp.sm),
              Text(
                'NUEVA',
                style: AppText.label.copyWith(
                  color: AppColors.dorado,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SKELETON CARD
// ═══════════════════════════════════════════════════════════

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withOpacity(0.85),
        borderRadius: Rad.rLg,
        border: Border.all(
          color: AppColors.dorado.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          _shimmer(
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmer(
                  child: Container(
                    height: 14,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: Rad.rSm,
                    ),
                  ),
                ),
                const SizedBox(height: Sp.sm),
                _shimmer(
                  child: Container(
                    height: 10,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: Rad.rSm,
                    ),
                  ),
                ),
                const SizedBox(height: Sp.sm),
                _shimmer(
                  child: Container(
                    height: 16,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: Rad.rPill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer({required Widget child}) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final x = -1.0 + 2.0 * _ctrl.value;
            return LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: const [
                Color(0x00FFFFFF),
                Color(0x33FFFFFF),
                Color(0x00FFFFFF),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}