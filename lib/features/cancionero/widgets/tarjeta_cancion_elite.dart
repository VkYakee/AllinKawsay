// lib/features/cancionero/widgets/tarjeta_cancion_elite.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/audio_visualizer.dart';
import '../../../models/cancion.dart';
import '../../../services/player_service.dart';

/// Card reconstruida del cancionero.
///
/// Diferente a la anterior:
/// - Play orb circular con MiniEqualizer dentro cuando suena.
/// - Borde que se ilumina cuando la canción es la actual.
/// - Metadata apilada con chips inline (ritmo, partitura, plays).
/// - Hero tag para transición al detalle.
/// - Spring scale en press.
class TarjetaCancionElite extends StatefulWidget {
  final Cancion cancion;
  final bool esFavorito;
  final EstadoPlayer estado;
  final VoidCallback onTap;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleFavorito;

  const TarjetaCancionElite({
    super.key,
    required this.cancion,
    required this.esFavorito,
    required this.estado,
    required this.onTap,
    required this.onTogglePlay,
    required this.onToggleFavorito,
  });

  @override
  State<TarjetaCancionElite> createState() => _TarjetaCancionEliteState();
}

class _TarjetaCancionEliteState extends State<TarjetaCancionElite> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.cancion;
    final onSurface = AppColors.onSurface(context);
    final sonando = widget.estado.cancionId == c.id;
    final reproduciendo = sonando && widget.estado.playing;
    final cargando = sonando && widget.estado.cargando;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 5),
      child: GestureDetector(
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
          child: AnimatedContainer(
            duration: AppMotion.normal,
            curve: AppMotion.easeOut,
            padding: const EdgeInsets.all(Sp.md),
            decoration: BoxDecoration(
              color: AppColors.surface(context).withOpacity(sonando ? 1.0 : 0.85),
              borderRadius: Rad.rLg,
              border: Border.all(
                color: sonando
                    ? AppColors.dorado.withOpacity(0.7)
                    : AppColors.dorado.withOpacity(0.12),
                width: sonando ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: sonando
                      ? AppColors.dorado.withOpacity(0.15)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: sonando ? 18 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Play orb
                _PlayOrb(
                  reproduciendo: reproduciendo,
                  cargando: cargando,
                  onTap: widget.onTogglePlay,
                ),
                const SizedBox(width: Sp.md),

                // Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'cancion_titulo_${c.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            c.titulo,
                            style: AppText.title.copyWith(
                              color: onSurface,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _subtitulo(c),
                        style: AppText.captionXs.copyWith(
                          color: onSurface.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Sp.sm),
                      _ChipsRow(cancion: c, sonando: sonando),
                    ],
                  ),
                ),

                // Favorito
                _FavoritoButton(
                  activo: widget.esFavorito,
                  onTap: widget.onToggleFavorito,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitulo(Cancion c) {
    final partes = <String>[];
    if (c.ritmo.isNotEmpty) partes.add(c.ritmo);
    if (c.autor.isNotEmpty) partes.add(c.autor);
    return partes.isEmpty ? 'Sin autor' : partes.join(' · ');
  }
}

// ═══════════════════════════════════════════════════════════
// PLAY ORB
// ═══════════════════════════════════════════════════════════

class _PlayOrb extends StatefulWidget {
  final bool reproduciendo;
  final bool cargando;
  final VoidCallback onTap;

  const _PlayOrb({
    required this.reproduciendo,
    required this.cargando,
    required this.onTap,
  });

  @override
  State<_PlayOrb> createState() => _PlayOrbState();
}

class _PlayOrbState extends State<_PlayOrb> {
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
        scale: _pressed ? 0.88 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.bouncy,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.easeOut,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.reproduciendo
                ? AppColors.gradienteDorado
                : AppColors.gradienteGranate,
            boxShadow: [
              BoxShadow(
                color: (widget.reproduciendo
                        ? AppColors.dorado
                        : AppColors.granate)
                    .withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: widget.cargando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.dorado,
                      strokeWidth: 2.5,
                    ),
                  )
                : widget.reproduciendo
                    ? MiniEqualizer(
                        isPlaying: true,
                        color: AppColors.granate,
                        size: 22,
                        barCount: 3,
                      )
                    : const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.dorado,
                        size: 30,
                      ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CHIPS
// ═══════════════════════════════════════════════════════════

class _ChipsRow extends StatelessWidget {
  final Cancion cancion;
  final bool sonando;

  const _ChipsRow({required this.cancion, required this.sonando});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (sonando)
          _chip(
            icon: Icons.graphic_eq,
            label: 'Sonando',
            color: AppColors.dorado,
            bg: AppColors.granate.withOpacity(0.5),
          ),
        if (cancion.tieneNumerofonia)
          _chip(
            icon: Icons.grid_on,
            label: 'Partitura',
            color: AppColors.doradoOscuro,
            bg: AppColors.dorado.withOpacity(0.12),
          ),
        _chip(
          icon: Icons.play_arrow_rounded,
          label: '${cancion.reproducciones}',
          color: AppColors.onSurfaceVariant(context),
          bg: AppColors.onSurfaceVariant(context).withOpacity(0.08),
        ),
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: Rad.rPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppText.captionXs.copyWith(
              color: color,
              fontSize: 9,
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
        scale: _pressed ? 0.8 : (widget.activo ? 1.1 : 1.0),
        duration: AppMotion.fast,
        curve: AppMotion.bouncy,
        child: Padding(
          padding: const EdgeInsets.all(Sp.xs),
          child: Icon(
            widget.activo ? Icons.favorite : Icons.favorite_border,
            color: widget.activo
                ? AppColors.granate
                : AppColors.onSurfaceVariant(context).withOpacity(0.35),
            size: 22,
          ),
        ),
      ),
    );
  }
}