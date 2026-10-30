// lib/features/cancion_detalle/widgets/cancion_hero_elite.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/audio_visualizer.dart';
import '../../../models/cancion.dart';

/// Hero expandido del detalle.
///
/// Se usa como `background` del FlexibleSpaceBar. Cuando el SliverAppBar
/// colapsa, este widget se va y el `title` del FlexibleSpaceBar toma
/// el control (con un Text sin Hero).
///
/// El Hero tag `cancion_titulo_${c.id}` MATCHEA con el de la
/// `TarjetaCancionElite` — la transición vuela el título entre las
/// dos pantallas.
class CancionHeroElite extends StatelessWidget {
  final Cancion cancion;
  final bool esFavorito;
  final bool reproduciendo;
  final bool cargando;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleFavorito;
  final VoidCallback onPracticar;

  const CancionHeroElite({
    super.key,
    required this.cancion,
    required this.esFavorito,
    required this.reproduciendo,
    required this.cargando,
    required this.onTogglePlay,
    required this.onToggleFavorito,
    required this.onPracticar,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradiente de fondo
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.granateOscuro,
                AppColors.granate.withOpacity(0.5),
                AppColors.fondoOscuro,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),

        // Visualizer de fondo, latiendo si suena
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 130,
          child: IgnorePointer(
            child: Opacity(
              opacity: reproduciendo ? 0.45 : 0.15,
              child: AudioVisualizer(
                isPlaying: reproduciendo,
                color: AppColors.dorado,
                height: 130,
                barCount: 60,
                barWidth: 3,
                gap: 3,
              ),
            ),
          ),
        ),

        // Contenido
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Sp.xl,
                kToolbarHeight + Sp.lg,
                Sp.xl,
                Sp.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Título con Hero — matchea con la card del cancionero
                  Hero(
                    tag: 'cancion_titulo_${cancion.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        cancion.titulo,
                        style: AppText.h1.copyWith(
                          color: onSurface,
                          fontSize: 30,
                          letterSpacing: -0.6,
                          height: 1.05,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (cancion.autor.isNotEmpty) ...[
                    const SizedBox(height: Sp.xs),
                    Text(
                      cancion.autor,
                      style: AppText.subtitle.copyWith(
                        color: onSurface.withOpacity(0.65),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: Sp.md),

                  // Fila de chips + favorito
                  Row(
                    children: [
                      if (cancion.ritmo.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sp.md,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.granate.withOpacity(0.3),
                            borderRadius: Rad.rPill,
                            border: Border.all(
                              color: AppColors.dorado.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.graphic_eq,
                                size: 12,
                                color: AppColors.dorado,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cancion.ritmo,
                                style: AppText.captionXs.copyWith(
                                  color: AppColors.dorado,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (cancion.tieneNumerofonia) ...[
                        const SizedBox(width: Sp.sm),
                        _MiniChip(
                          icon: Icons.grid_on,
                          label: '${cancion.estrofas.where((e) => !e.vacia).length} estrofas',
                        ),
                      ],
                      const Spacer(),
                      _FavoritoButton(
                        activo: esFavorito,
                        onTap: onToggleFavorito,
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.lg),

                  // Botón de play / practicar
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _PlayButton(
                          reproduciendo: reproduciendo,
                          cargando: cargando,
                          onTap: onTogglePlay,
                        ),
                      ),
                      if (cancion.tieneNumerofonia) ...[
                        const SizedBox(width: Sp.sm),
                        Expanded(
                          child: _PracticarButton(onTap: onPracticar),
                        ),
                      ],
                    ],
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
// CHIP MINI
// ═══════════════════════════════════════════════════════════

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.sm, vertical: 5),
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
          Icon(icon, size: 11, color: AppColors.dorado),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppText.captionXs.copyWith(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FAVORITO
// ═══════════════════════════════════════════════════════════

class _FavoritoButton extends StatefulWidget {
  final bool activo;
  final VoidCallback onTap;

  const _FavoritoButton({required this.activo, required this.onTap});

  @override
  State<_FavoritoButton> createState() => _FavoritoButtonState();
}

class _FavoritoButtonState extends State<_FavoritoButton> {
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
        scale: _pressed ? 0.8 : (widget.activo ? 1.15 : 1.0),
        duration: AppMotion.fast,
        curve: AppMotion.bouncy,
        child: Container(
          padding: const EdgeInsets.all(Sp.sm),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.activo
                ? AppColors.granate.withOpacity(0.4)
                : Colors.black.withOpacity(0.3),
            border: Border.all(
              color: widget.activo
                  ? AppColors.dorado.withOpacity(0.6)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Icon(
            widget.activo ? Icons.favorite : Icons.favorite_border,
            color: widget.activo
                ? AppColors.dorado
                : Colors.white.withOpacity(0.7),
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BOTÓN PLAY
// ═══════════════════════════════════════════════════════════

class _PlayButton extends StatefulWidget {
  final bool reproduciendo;
  final bool cargando;
  final VoidCallback onTap;

  const _PlayButton({
    required this.reproduciendo,
    required this.cargando,
    required this.onTap,
  });

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        AppMotion.hapticLight();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.gradienteDorado,
            borderRadius: Rad.rPill,
            boxShadow: [
              BoxShadow(
                color: AppColors.dorado.withOpacity(0.45),
                blurRadius: widget.reproduciendo ? 24 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.cargando)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.granate,
                    strokeWidth: 2.5,
                  ),
                )
              else
                Icon(
                  widget.reproduciendo
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.granate,
                  size: 28,
                ),
              const SizedBox(width: Sp.sm),
              Text(
                widget.reproduciendo ? 'PAUSAR' : 'ESCUCHAR',
                style: AppText.label.copyWith(
                  color: AppColors.granate,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
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
// BOTÓN PRACTICAR
// ═══════════════════════════════════════════════════════════

class _PracticarButton extends StatefulWidget {
  final VoidCallback onTap;

  const _PracticarButton({required this.onTap});

  @override
  State<_PracticarButton> createState() => _PracticarButtonState();
}

class _PracticarButtonState extends State<_PracticarButton> {
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
        scale: _pressed ? 0.95 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: Rad.rPill,
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                color: AppColors.dorado,
                size: 20,
              ),
              const SizedBox(width: Sp.sm),
              Text(
                'PRACTICAR',
                style: AppText.label.copyWith(
                  color: AppColors.dorado,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}