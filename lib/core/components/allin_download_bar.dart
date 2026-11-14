// lib/core/components/allin_download_bar.dart
import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

class AllinDownloadBar extends StatefulWidget {
  final double progress; // 0.0 a 1.0
  final String? title;
  final String? subtitle;
  final bool isIndeterminate;

  const AllinDownloadBar({
    super.key,
    required this.progress,
    this.title,
    this.subtitle,
    this.isIndeterminate = false,
  });

  @override
  State<AllinDownloadBar> createState() => _AllinDownloadBarState();
}

class _AllinDownloadBarState extends State<AllinDownloadBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = widget.progress.clamp(0.0, 1.0);
    final int percentage = (clampedProgress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null || !widget.isIndeterminate)
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.title != null)
                  Expanded(
                    child: Text(
                      widget.title!,
                      style: AppText.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (!widget.isIndeterminate)
                  Text(
                    '$percentage%',
                    style: AppText.captionXs.copyWith(
                      color: AppColors.oroSolar,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: widget.isIndeterminate ? 1.0 : clampedProgress,
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.granateSagrado,
                          AppColors.granate,
                          AppColors.oroSolar,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.oroSolar.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
                // Onda de brillo móvil
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _waveCtrl,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(
                          MediaQuery.of(context).size.width *
                              (2 * _waveCtrl.value - 1),
                          0,
                        ),
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.35),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: Sp.xs),
          Text(
            widget.subtitle!,
            style: AppText.captionXs.copyWith(
              color: AppColors.textDarkSecundario.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}
