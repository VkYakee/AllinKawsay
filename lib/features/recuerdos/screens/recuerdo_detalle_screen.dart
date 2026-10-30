// lib/features/recuerdos/screens/recuerdo_detalle_screen.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_card.dart';

import '../../../models/recuerdo.dart';
import '../../../models/usuario.dart';

import '../../../services/recuerdo_cache_service.dart';
import '../../../services/usuario_service.dart';

import '../widgets/galeria_fotos_elite.dart';
import '../widgets/video_player_card_elite.dart';

class RecuerdoDetalleScreen extends StatefulWidget {
  final Recuerdo recuerdo;
  const RecuerdoDetalleScreen({super.key, required this.recuerdo});

  @override
  State<RecuerdoDetalleScreen> createState() => _RecuerdoDetalleScreenState();
}

class _RecuerdoDetalleScreenState extends State<RecuerdoDetalleScreen> {
  Usuario? _usuario;
  bool _descargando = false;
  double _progresoDescarga = 0;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  Future<void> _descargar() async {
    final r = widget.recuerdo;
    if (r.totalMedia == 0) return;
    setState(() {
      _descargando = true;
      _progresoDescarga = 0;
    });
    try {
      await RecuerdoCacheService().descargarRecuerdoCompleto(
        r.id,
        fotos: r.fotos,
        videos: r.videos,
        onProgreso: (completados, total) {
          if (mounted) {
            setState(() => _progresoDescarga = completados / total);
          }
        },
      );
      if (!mounted) return;
      _snack('Recuerdo descargado para ver offline');
    } finally {
      if (mounted) {
        setState(() {
          _descargando = false;
          _progresoDescarga = 0;
        });
      }
    }
  }

  Future<void> _editarNota() async {
    final ctrl = TextEditingController(
      text: _usuario?.notaRecuerdo(widget.recuerdo.id) ?? '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Rad.rLg),
        backgroundColor: AppColors.surface(context),
        title: Text(
          'Mi nota personal',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
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
    await UsuarioService().guardarNotaRecuerdo(
      widget.recuerdo.id,
      ctrl.text,
    );
    await _cargarUsuario();
  }

  void _snack(String msg) {
    if (!mounted) return;
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
    final r = widget.recuerdo;
    final onSurface = AppColors.onSurface(context);
    final nota = _usuario?.notaRecuerdo(r.id) ?? '';

    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── APP BAR HERO ───
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: AppColors.fondoOscuro,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Center(
              child: _BotonCircular(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              if (r.totalMedia > 0)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: Sp.md),
                    child: _BotonDescarga(
                      cargando: _descargando,
                      progreso: _progresoDescarga,
                      onTap: _descargando ? null : _descargar,
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 56, 16),
              title: _TituloColapsado(
                titulo: r.titulo,
                mostrar: MediaQuery.of(context).padding.top > 0,
              ),
              background: _HeroRecuerdo(
                recuerdo: r,
                onTapNota: _editarNota,
              ),
            ),
          ),

          // ─── INFORMACIÓN ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.lg, Sp.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sp.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.granate.withOpacity(0.2),
                          borderRadius: Rad.rPill,
                          border: Border.all(
                            color: AppColors.dorado.withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 11,
                              color: AppColors.dorado,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              r.creadorNombre.isEmpty
                                  ? 'Anónimo'
                                  : r.creadorNombre,
                              style: AppText.captionXs.copyWith(
                                color: AppColors.dorado,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (r.fecha != null) ...[
                        const SizedBox(width: Sp.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sp.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.dorado.withOpacity(0.1),
                            borderRadius: Rad.rPill,
                            border: Border.all(
                              color: AppColors.dorado.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 10,
                                color: AppColors.dorado,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${r.fecha!.day}/${r.fecha!.month}/${r.fecha!.year}',
                                style: AppText.captionXs.copyWith(
                                  color: AppColors.dorado,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (r.descripcion.isNotEmpty) ...[
                    const SizedBox(height: Sp.md),
                    Text(
                      r.descripcion,
                      style: AppText.body.copyWith(
                        color: onSurface.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ─── VIDEOS ───
          if (r.tieneVideos)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SeccionTitulo(
                      icon: Icons.videocam_rounded,
                      titulo: 'VIDEOS',
                      count: r.videos.length,
                    ),
                    const SizedBox(height: Sp.sm),
                    for (int i = 0; i < r.videos.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Sp.md),
                        child: VideoPlayerCardElite(
                          recuerdoId: r.id,
                          url: r.videos[i],
                          index: i,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ─── FOTOS ───
          if (r.tieneFotos)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SeccionTitulo(
                      icon: Icons.photo_library_rounded,
                      titulo: 'FOTOS',
                      count: r.fotos.length,
                    ),
                    const SizedBox(height: Sp.sm),
                    GaleriaFotosElite(
                      recuerdoId: r.id,
                      fotos: r.fotos,
                      tituloRecuerdo: r.titulo,
                      puedeDescargar: _usuario?.puedeDescargar ?? false,
                      heroPrefix: r.id,
                    ),
                  ],
                ),
              ),
            ),

          // ─── NOTA PERSONAL ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, Sp.sm),
              child: AppCard(
                padding: const EdgeInsets.all(Sp.lg),
                onTap: _editarNota,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.granate.withOpacity(0.15),
                            borderRadius: Rad.rSm,
                          ),
                          child: const Icon(
                            Icons.sticky_note_2,
                            color: AppColors.dorado,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: Sp.sm),
                        Text(
                          'MI NOTA PERSONAL',
                          style: AppText.label.copyWith(
                            color: AppColors.dorado,
                            letterSpacing: 1.5,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.edit,
                          color: AppColors.dorado.withOpacity(0.5),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.sm),
                    Text(
                      nota.isEmpty
                          ? 'Toca aquí para escribir una nota privada (solo la ves tú).'
                          : nota,
                      style: AppText.body.copyWith(
                        color: nota.isEmpty
                            ? onSurface.withOpacity(0.4)
                            : onSurface.withOpacity(0.9),
                        fontStyle: nota.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HERO RECUERDO
// ═══════════════════════════════════════════════════════════

class _HeroRecuerdo extends StatelessWidget {
  final Recuerdo recuerdo;
  final VoidCallback onTapNota;

  const _HeroRecuerdo({
    required this.recuerdo,
    required this.onTapNota,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.granateOscuro,
                AppColors.granate.withOpacity(0.6),
                AppColors.fondoOscuro,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 260,
            height: 260,
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
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Sp.xl,
                kToolbarHeight + Sp.md,
                Sp.xl,
                Sp.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.dorado.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.dorado.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.photo_library_rounded,
                          color: AppColors.dorado,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: Sp.sm),
                      Text(
                        'RECUERDO',
                        style: AppText.label.copyWith(
                          color: AppColors.dorado,
                          letterSpacing: 2,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.sm),
                  Text(
                    recuerdo.titulo,
                    style: AppText.h1.copyWith(
                      color: onSurface,
                      fontSize: 28,
                      letterSpacing: -0.6,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TÍTULO COLAPSADO
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
      child: Text(
        titulo,
        style: AppText.title.copyWith(
          color: AppColors.dorado,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BOTÓN CIRCULAR
// ═══════════════════════════════════════════════════════════

class _BotonCircular extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _BotonCircular({required this.icon, required this.onTap});

  @override
  State<_BotonCircular> createState() => _BotonCircularState();
}

class _BotonCircularState extends State<_BotonCircular> {
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
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BOTÓN DE DESCARGA MASIVA
// ═══════════════════════════════════════════════════════════

class _BotonDescarga extends StatelessWidget {
  final bool cargando;
  final double progreso;
  final VoidCallback? onTap;

  const _BotonDescarga({
    required this.cargando,
    required this.progreso,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.45),
          border: Border.all(
            color: AppColors.dorado.withOpacity(0.3),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (cargando)
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  value: progreso > 0 ? progreso : null,
                  color: AppColors.dorado,
                  strokeWidth: 2,
                  backgroundColor: AppColors.dorado.withOpacity(0.15),
                ),
              )
            else
              const Icon(
                Icons.download_for_offline_rounded,
                color: AppColors.dorado,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECCIÓN TÍTULO
// ═══════════════════════════════════════════════════════════

class _SeccionTitulo extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final int count;

  const _SeccionTitulo({
    required this.icon,
    required this.titulo,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.18),
            borderRadius: Rad.rSm,
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.2),
            ),
          ),
          child: Icon(icon, color: AppColors.dorado, size: 14),
        ),
        const SizedBox(width: Sp.sm),
        Text(
          titulo,
          style: AppText.label.copyWith(
            color: AppColors.dorado,
            letterSpacing: 1.5,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: Sp.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.2),
            borderRadius: Rad.rPill,
          ),
          child: Text(
            '$count',
            style: AppText.captionXs.copyWith(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}