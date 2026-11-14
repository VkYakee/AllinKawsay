// lib/widgets/banner_novedades.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../core/design/colors.dart';
import '../core/design/motion.dart';
import '../core/design/tokens.dart';
import '../core/design/typography.dart';

class BannerNovedades extends StatefulWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback? onTap;
  final VoidCallback? onCerrar;

  const BannerNovedades({
    super.key,
    this.icono = Icons.celebration_rounded,
    required this.titulo,
    this.subtitulo,
    this.onTap,
    this.onCerrar,
  });

  @override
  State<BannerNovedades> createState() => _BannerNovedadesState();
}

class _BannerNovedadesState extends State<BannerNovedades> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.xs),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
        onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.spring,
          child: ClipRRect(
            borderRadius: Rad.rLg,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(Sp.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.granateProfundo.withOpacity(0.85),
                      AppColors.fondoOscuro.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: Rad.rLg,
                  border: Border.all(
                    color: AppColors.dorado.withOpacity(0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dorado.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.dorado, AppColors.doradoBrillante],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dorado.withOpacity(0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icono,
                        color: AppColors.fondoOscuro,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: Sp.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.titulo,
                            style: AppText.subtitle.copyWith(
                              color: AppColors.dorado,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.subtitulo != null &&
                              widget.subtitulo!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitulo!,
                              style: AppText.caption.copyWith(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.onCerrar != null)
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.dorado,
                        ),
                        onPressed: widget.onCerrar,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
