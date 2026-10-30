// lib/features/recuerdos/screens/recuerdos_screen.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/animated_list_item.dart';

import '../../../models/recuerdo.dart';
import '../../../models/usuario.dart';

import '../../../services/recuerdo_service.dart';
import '../../../services/usuario_service.dart';

import '../widgets/recuerdo_card_elite.dart';
import 'agregar_recuerdo_screen.dart';
import 'recuerdo_detalle_screen.dart';

class RecuerdosScreen extends StatefulWidget {
  const RecuerdosScreen({super.key});

  @override
  State<RecuerdosScreen> createState() => _RecuerdosScreenState();
}

class _RecuerdosScreenState extends State<RecuerdosScreen> {
  final _service = RecuerdoService();
  Usuario? _usuario;
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (!mounted) return;
    setState(() {
      _usuario = u;
      _esAdmin = u?.esAdmin ?? false;
    });
  }

  Future<void> _eliminar(Recuerdo r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Rad.rLg),
        backgroundColor: AppColors.surface(context),
        title: Text(
          'Eliminar recuerdo',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        content: Text(
          '¿Eliminar "${r.titulo}"? Esta acción no se puede deshacer.',
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: AppText.subtitle.copyWith(
                color: AppColors.onSurfaceVariant(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
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
    if (ok == true) await _service.eliminar(r.id);
  }

  void _editar(Recuerdo r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarRecuerdoScreen(recuerdo: r),
      ),
    );
  }

  void _verDetalle(Recuerdo r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecuerdoDetalleScreen(recuerdo: r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: StreamBuilder<List<Recuerdo>>(
        stream: _service.listar(),
        builder: (context, snap) {
          final lista = snap.data ?? [];
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(lista.length),
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData)
                _buildSkeleton()
              else if (lista.isEmpty)
                _buildEmpty()
              else
                _buildLista(lista),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          );
        },
      ),
      floatingActionButton: _esAdmin
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: _FabNuevo(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AgregarRecuerdoScreen(),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar(int total) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      backgroundColor: AppColors.fondoOscuro,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(Sp.lg, 0, Sp.lg, Sp.lg),
        expandedTitleScale: 1.6,
        title: Text(
          'Recuerdos',
          style: AppText.h3.copyWith(
            color: AppColors.dorado,
            letterSpacing: -0.3,
          ),
        ),
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
                    AppColors.granate.withOpacity(0.5),
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
                width: 220,
                height: 220,
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
            if (total > 0)
              Positioned(
                right: Sp.lg,
                bottom: Sp.lg,
                child: Container(
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
                    '$total recuerdos',
                    style: AppText.captionXs.copyWith(
                      color: AppColors.dorado,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLista(List<Recuerdo> lista) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 0),
      sliver: SliverList.builder(
        itemCount: lista.length,
        itemBuilder: (context, i) {
          final r = lista[i];
          return AnimatedListItem(
            index: i,
            interval: const Duration(milliseconds: 60),
            child: RecuerdoCardElite(
              recuerdo: r,
              esAdmin: _esAdmin,
              onTap: () => _verDetalle(r),
              onEditar: () => _editar(r),
              onEliminar: () => _eliminar(r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return SliverList.builder(
      itemCount: 3,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sp.lg,
          vertical: Sp.sm,
        ),
        child: Container(
          height: 260,
          decoration: BoxDecoration(
            color: AppColors.surface(context).withOpacity(0.5),
            borderRadius: Rad.rLg,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
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
                builder: (context, v, child) => Transform.scale(
                  scale: 0.7 + 0.3 * v,
                  child: Opacity(opacity: v, child: child),
                ),
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
                    Icons.photo_library_outlined,
                    size: 48,
                    color: AppColors.dorado.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: Sp.xl),
              Text(
                'Sin recuerdos aún',
                style: AppText.h3.copyWith(color: AppColors.dorado),
              ),
              const SizedBox(height: Sp.xs),
              Text(
                'Cuando subas fotos o videos,\naparecerán acá',
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

class _FabNuevo extends StatefulWidget {
  final VoidCallback onTap;
  const _FabNuevo({required this.onTap});

  @override
  State<_FabNuevo> createState() => _FabNuevoState();
}

class _FabNuevoState extends State<_FabNuevo> {
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
                'NUEVO',
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