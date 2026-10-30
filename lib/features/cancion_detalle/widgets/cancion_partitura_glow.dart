// lib/features/cancion_detalle/widgets/cancion_partitura_glow.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/cancion.dart';
import '../../../screens/numerofonia_fullscreen_screen.dart';
import '../../../widgets/visor_numerofonia.dart';

/// Partitura del detalle con borde que pulsa al ritmo cuando el
/// audio está reproduciendo.
///
/// Sin audio: borde estático dorado tenue.
/// Con audio: borde dorado con glow que late.
class CancionPartituraGlow extends StatefulWidget {
  final Cancion cancion;
  final bool sonando;

  const CancionPartituraGlow({
    super.key,
    required this.cancion,
    required this.sonando,
  });

  @override
  State<CancionPartituraGlow> createState() => _CancionPartituraGlowState();
}

class _CancionPartituraGlowState extends State<CancionPartituraGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.sonando) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant CancionPartituraGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sonando && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.sonando && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.cancion.tieneNumerofonia) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.xs, Sp.lg, Sp.md),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_ctrl.value);
          final glow = widget.sonando ? (0.3 + 0.5 * t) : 0.15;
          final blur = widget.sonando ? (14.0 + 14.0 * t) : 8.0;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: Rad.rLg,
              border: Border.all(
                color: AppColors.dorado.withOpacity(glow),
                width: widget.sonando ? 1.6 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dorado.withOpacity(
                    widget.sonando ? 0.25 * t : 0.05,
                  ),
                  blurRadius: blur,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(Sp.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.granate.withOpacity(0.2),
                      borderRadius: Rad.rSm,
                    ),
                    child: const Icon(
                      Icons.grid_on,
                      color: AppColors.dorado,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: Sp.sm),
                  Text(
                    'PARTITURA',
                    style: AppText.label.copyWith(
                      color: AppColors.dorado,
                      letterSpacing: 1.8,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      AppMotion.hapticSelection();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NumerofoniaFullscreenScreen(
                            estrofas: widget.cancion.estrofas,
                          ),
                        ),
                      );
                    },
                    borderRadius: Rad.rPill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sp.sm,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.granate.withOpacity(0.15),
                        borderRadius: Rad.rPill,
                        border: Border.all(
                          color: AppColors.dorado.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_out_map,
                            color: AppColors.dorado,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AMPLIAR',
                            style: AppText.captionXs.copyWith(
                              color: AppColors.dorado,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.md),
              VisorNumerofonia(
                estrofas: widget.cancion.estrofas,
                escala: 1.0,
                fondoOscuro: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}