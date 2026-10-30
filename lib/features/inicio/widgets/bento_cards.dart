// lib/features/inicio/widgets/bento_cards.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

/// Tarjeta Bento grande con imagen de fondo opcional.
/// Se usa para el próximo evento (héroe del bento).
class BentoHeroCard extends StatefulWidget {
  final String? imageUrl;
  final IconData icon;
  final String eyebrow;
  final String titulo;
  final String? subtitulo;
  final Gradient fallbackGradient;
  final VoidCallback onTap;

  const BentoHeroCard({
    super.key,
    this.imageUrl,
    required this.icon,
    required this.eyebrow,
    required this.titulo,
    this.subtitulo,
    required this.fallbackGradient,
    required this.onTap,
  });

  @override
  State<BentoHeroCard> createState() => _BentoHeroCardState();
}

class _BentoHeroCardState extends State<BentoHeroCard> {
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
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: widget.fallbackGradient,
            borderRadius: Rad.rLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo (si existe)
              if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              // Overlay para legibilidad
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(Sp.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Eyebrow con icono
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.dorado.withOpacity(0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.dorado.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: AppColors.dorado,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: Sp.sm),
                        Text(
                          widget.eyebrow,
                          style: AppText.label.copyWith(
                            color: AppColors.dorado,
                            letterSpacing: 2,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),

                    // Título grande + subtítulo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.titulo,
                          style: AppText.h2.copyWith(
                            color: AppColors.dorado,
                            fontSize: 22,
                            height: 1.1,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitulo != null &&
                            widget.subtitulo!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitulo!,
                            style: AppText.captionXs.copyWith(
                              color: AppColors.dorado.withOpacity(0.75),
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Flecha en la esquina
              Positioned(
                right: Sp.md,
                bottom: Sp.md,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.dorado.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.dorado,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta Bento pequeña (cuadrada). Se usa en pares.
class BentoSmallCard extends StatefulWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Gradient gradient;
  final VoidCallback onTap;

  const BentoSmallCard({
    super.key,
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<BentoSmallCard> createState() => _BentoSmallCardState();
}

class _BentoSmallCardState extends State<BentoSmallCard> {
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
        scale: _pressed ? 0.94 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(Sp.md),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: Rad.rLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(Sp.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.dorado,
                  size: 18,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titulo,
                    style: AppText.title.copyWith(
                      color: AppColors.dorado,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitulo,
                    style: AppText.captionXs.copyWith(
                      color: AppColors.dorado.withOpacity(0.65),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta Bento ancha con imagen a la derecha.
class BentoWideCard extends StatefulWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final String eyebrow;
  final String titulo;
  final String subtitulo;
  final Gradient fallbackGradient;
  final VoidCallback onTap;

  const BentoWideCard({
    super.key,
    this.imageUrl,
    required this.fallbackIcon,
    required this.eyebrow,
    required this.titulo,
    required this.subtitulo,
    required this.fallbackGradient,
    required this.onTap,
  });

  @override
  State<BentoWideCard> createState() => _BentoWideCardState();
}

class _BentoWideCardState extends State<BentoWideCard> {
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
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: widget.fallbackGradient,
            borderRadius: Rad.rLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Contenido izquierda
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(Sp.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: AppColors.dorado,
                            size: 6,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.eyebrow,
                            style: AppText.label.copyWith(
                              color: AppColors.dorado,
                              letterSpacing: 1.5,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.titulo,
                            style: AppText.title.copyWith(
                              color: AppColors.dorado,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitulo,
                            style: AppText.captionXs.copyWith(
                              color: AppColors.dorado.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Imagen o icono derecha
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(24),
                  ),
                  child: widget.imageUrl != null &&
                          widget.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.imageUrl!,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          errorWidget: (_, __, ___) => _fallback(),
                        )
                      : _fallback(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.black.withOpacity(0.2),
      child: Center(
        child: Icon(
          widget.fallbackIcon,
          color: AppColors.dorado.withOpacity(0.4),
          size: 40,
        ),
      ),
    );
  }
}

/// Header de sección Bento (con icono y línea separadora sutil).
class BentoSectionHeader extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String? action;
  final VoidCallback? onAction;

  const BentoSectionHeader({
    super.key,
    required this.icon,
    required this.titulo,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.xl, Sp.lg, Sp.md),
      child: Row(
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
          const Spacer(),
          if (action != null && onAction != null)
            InkWell(
              onTap: onAction,
              borderRadius: Rad.rPill,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sp.sm,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      action!,
                      style: AppText.captionXs.copyWith(
                        color: AppColors.dorado.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.dorado.withOpacity(0.8),
                      size: 10,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}