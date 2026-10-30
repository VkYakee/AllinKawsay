// lib/features/eventos/screens/eventos_screen.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/animated_list_item.dart';

import '../../../models/evento.dart';
import '../../../models/usuario.dart';

import '../../../services/evento_service.dart';
import '../../../services/novedades_service.dart';
import '../../../services/usuario_service.dart';

import '../widgets/evento_card_elite.dart';
import 'agregar_evento_screen.dart';
import 'evento_detalle_screen.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final _service = EventoService();
  Usuario? _usuario;
  bool _esAdmin = false;
  int _nuevos = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final u = await UsuarioService().miUsuarioActual();
    if (!mounted) return;
    setState(() {
      _usuario = u;
      _esAdmin = u?.esAdmin ?? false;
    });
    final count = await NovedadesService.contarEventosNuevos();
    if (!mounted) return;
    setState(() => _nuevos = count);
    await NovedadesService.marcarEventosVistos();
  }

  Future<void> _editarNota(Evento e) async {
    final ctrl = TextEditingController(
      text: _usuario?.notaEvento(e.id) ?? '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Rad.rLg),
        backgroundColor: AppColors.surface(context),
        title: Text(
          'Nota personal',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: AppText.body,
          decoration: InputDecoration(
            hintText: 'Solo la ves tú',
            border: OutlineInputBorder(borderRadius: Rad.rMd),
            focusedBorder: OutlineInputBorder(
              borderRadius: Rad.rMd,
              borderSide: const BorderSide(color: AppColors.dorado),
            ),
          ),
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
              'Guardar',
              style: AppText.subtitle.copyWith(
                color: AppColors.dorado,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await UsuarioService().guardarNotaEvento(e.id, ctrl.text);
    _init();
  }

  Future<void> _eliminar(Evento e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Rad.rLg),
        backgroundColor: AppColors.surface(context),
        title: Text(
          'Eliminar evento',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        content: Text(
          '¿Eliminar "${e.titulo}"?',
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
    if (ok == true) await _service.eliminar(e.id);
  }

  void _editar(Evento e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarEventoScreen(evento: e),
      ),
    );
  }

  void _verDetalle(Evento e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventoDetalleScreen(evento: e),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: StreamBuilder<List<Evento>>(
        stream: _service.listar(),
        builder: (context, snap) {
          final lista = snap.data ?? [];
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(lista.length),
              if (snap.connectionState == ConnectionState.waiting && !snap.hasData)
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
                    builder: (_) => const AgregarEventoScreen(),
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
          'Eventos',
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
            if (_nuevos > 0)
              Positioned(
                right: Sp.lg,
                bottom: Sp.lg,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sp.md,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: Rad.rPill,
                    border: Border.all(
                      color: Colors.red.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 6,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_nuevos nuevos',
                        style: AppText.captionXs.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (total > 0)
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
                    '$total eventos',
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

  Widget _buildLista(List<Evento> lista) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      sliver: SliverList.builder(
        itemCount: lista.length,
        itemBuilder: (context, i) {
          final e = lista[i];
          return AnimatedListItem(
            index: i,
            interval: const Duration(milliseconds: 45),
            child: EventoCardElite(
              evento: e,
              esPasado: e.fecha.isBefore(DateTime.now()),
              nota: _usuario?.notaEvento(e.id) ?? '',
              esAdmin: _esAdmin,
              onTap: () => _verDetalle(e),
              onEditarNota: () => _editarNota(e),
              onEditar: () => _editar(e),
              onEliminar: () => _eliminar(e),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return SliverList.builder(
      itemCount: 4,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sp.lg,
          vertical: Sp.xs,
        ),
        child: Container(
          height: 160,
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
                    Icons.event_busy,
                    size: 48,
                    color: AppColors.dorado.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: Sp.xl),
              Text(
                'Sin eventos aún',
                style: AppText.h3.copyWith(color: AppColors.dorado),
              ),
              const SizedBox(height: Sp.xs),
              Text(
                'Cuando haya eventos programados,\naparecerán acá',
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