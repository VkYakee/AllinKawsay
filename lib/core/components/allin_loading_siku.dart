// lib/core/components/allin_loading_siku.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

class AllinLoadingSiku extends StatefulWidget {
  final String? message;
  final double height;
  final bool compact;

  const AllinLoadingSiku({
    super.key,
    this.message,
    this.height = 70,
    this.compact = false,
  });

  @override
  State<AllinLoadingSiku> createState() => _AllinLoadingSikuState();
}

class _AllinLoadingSikuState extends State<AllinLoadingSiku>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // 7 cañas de zampoña con alturas proporcionales relativas
  static const List<double> _alturasBase = [
    1.00, // Caña 1 (más larga)
    0.88, // Caña 2
    0.77, // Caña 3
    0.66, // Caña 4
    0.56, // Caña 5
    0.47, // Caña 6
    0.40, // Caña 7 (más corta)
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxTuboHeight = widget.compact ? 24 : widget.height;
    final double tuboWidth = widget.compact ? 4 : 7;
    final double separacion = widget.compact ? 2.5 : 4.5;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  // Desfase armónico en onda senoidal
                  final double phase = (_ctrl.value * 2 * math.pi) - (i * 0.45);
                  final double pulse = (math.sin(phase) + 1.0) / 2.0; // 0.0 a 1.0
                  final double currentH = maxTuboHeight *
                      (_alturasBase[i] * 0.6 + pulse * _alturasBase[i] * 0.4);

                  final bool isActive = pulse > 0.65;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: separacion / 2),
                    width: tuboWidth,
                    height: currentH,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(tuboWidth / 2),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isActive
                            ? [
                                AppColors.oroReflejo,
                                AppColors.oroSolar,
                                AppColors.granate,
                              ]
                            : [
                                AppColors.granateSagrado,
                                AppColors.granateOscuro,
                                const Color(0xFF1F0307),
                              ],
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.oroSolar.withOpacity(0.6 * pulse),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              );
            },
          ),
          if (widget.message != null && !widget.compact) ...[
            const SizedBox(height: Sp.md),
            Text(
              widget.message!,
              style: AppText.caption.copyWith(
                color: AppColors.oroSolar.withOpacity(0.85),
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
