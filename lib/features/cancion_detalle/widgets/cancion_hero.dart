// lib/features/cancion_detalle/widgets/cancion_hero.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/audio_visualizer.dart';
import '../../../models/cancion.dart';

class CancionHero extends StatelessWidget {
  final Cancion cancion;
  final bool esFavorito;
  final bool reproduciendo;
  final bool cargando;
  final VoidCallback onToggleFavorito;
  final VoidCallback onTogglePlay;
  final VoidCallback onPracticar;

  const CancionHero({
    super.key,
    required this.cancion,
    required this.esFavorito,
    required this.reproduciendo,
    required this.cargando,
    required this.onToggleFavorito,
    required this.onTogglePlay,
    required this.onPracticar,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);

    return Stack(
      children: [
        // Fondo: gradiente oscuro + visualizer grande detrás del texto
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.granate.withOpacity(0.18),
                  AppColors.fondoOscuro,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 40,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.35,
              child: AudioVisualizer(
                isPlaying: reproduciendo,
                color: AppColors.dorado,
                height: 120,
                barCount: 56,
                barWidth: 3,
                gap: 3,
              ),
            ),
          ),
        ),

        // Contenido
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.xl, Sp.md, Sp.xl, Sp.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cancion.titulo,
                          style: AppText.h1.copyWith(
                            color: onSurface,
                            fontSize: 30,
                            letterSpacing: -0.6,
                            height: 1.05,
                          ),
                        ),
                        if (cancion.autor.isNotEmpty) ...[
                          const SizedBox(height: Sp.xs),
                          Text(
                            cancion.autor,
                            style: AppText.subtitle.copyWith(
                              color: onSurface.withOpacity(0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      AppMotion.hapticLight();
                      onToggleFavorito();
                    },
                    child: AnimatedScale(
                      scale: esFavorito ? 1.1 : 1.0,
                      duration: AppMotion.fast,
                      curve: AppMotion.spring,
                      child: Padding(
                        padding: const EdgeInsets.all(Sp.xs),
                        child: Icon(
                          esFavorito
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: esFavorito
                              ? AppColors.granate
                              : onSurface.withOpacity(0.3),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.md),

              Row(
                children: [
                  if (cancion.ritmo.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sp.md,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.granate.withOpacity(0.1),
                        borderRadius: Rad.rPill,
                        border: Border.all(
                          color: AppColors.granate.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.graphic_eq,
                            size: 12,
                            color: AppColors.granate,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cancion.ritmo,
                            style: AppText.captionXs.copyWith(
                              color: AppColors.granate,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (cancion.tieneNumerofonia)
                    TextButton.icon(
                      onPressed: onPracticar,
                      icon: const Icon(
                        Icons.school,
                        size: 18,
                        color: AppColors.dorado,
                      ),
                      label: Text(
                        'PRACTICAR',
                        style: AppText.label.copyWith(
                          color: AppColors.dorado,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Sp.lg),

              // Botón de Play tipo Píldora con spring physics
              _PlayPillButton(
                reproduciendo: reproduciendo,
                cargando: cargando,
                onTap: onTogglePlay,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayPillButton extends StatefulWidget {
  final bool reproduciendo;
  final bool cargando;
  final VoidCallback onTap;

  const _PlayPillButton({
    required this.reproduciendo,
    required this.cargando,
    required this.onTap,
  });

  @override
  State<_PlayPillButton> createState() => _PlayPillButtonState();
}

class _PlayPillButtonState extends State<_PlayPillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        AppMotion.hapticLight();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Container(
          width: double.infinity,
          height: 56,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.cargando)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.dorado,
                    strokeWidth: 2.5,
                  ),
                )
              else
                Icon(
                  widget.reproduciendo
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.dorado,
                  size: 30,
                ),
              const SizedBox(width: Sp.md),
              Text(
                widget.reproduciendo ? 'PAUSAR AUDIO' : 'ESCUCHAR AUDIO',
                style: AppText.label.copyWith(
                  color: AppColors.dorado,
                  fontSize: 14,
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