// lib/features/cancion_detalle/widgets/cancion_hero.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
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
    
    return Padding(
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
                      style: AppText.h1.copyWith(color: onSurface, fontSize: 26, letterSpacing: -0.5),
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
              IconButton(
                icon: Icon(
                  esFavorito ? Icons.favorite : Icons.favorite_border,
                  color: esFavorito ? AppColors.granate : onSurface.withOpacity(0.3),
                  size: 28,
                ),
                onPressed: onToggleFavorito,
              ),
            ],
          ),
          const SizedBox(height: Sp.md),
          Row(
            children: [
              if (cancion.ritmo.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.granate.withOpacity(0.1),
                    borderRadius: Rad.rPill,
                    border: Border.all(color: AppColors.granate.withOpacity(0.3)),
                  ),
                  child: Text(
                    cancion.ritmo,
                    style: AppText.captionXs.copyWith(color: AppColors.granate, fontWeight: FontWeight.bold),
                  ),
                ),
              const Spacer(),
              if (cancion.tieneNumerofonia)
                TextButton.icon(
                  onPressed: onPracticar,
                  icon: const Icon(Icons.school, size: 18, color: AppColors.dorado),
                  label: Text('PRACTICAR', style: AppText.label.copyWith(color: AppColors.dorado)),
                ),
            ],
          ),
          const SizedBox(height: Sp.lg),
          
          // Botón de Play tipo Píldora
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: onTogglePlay,
              icon: cargando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.dorado, strokeWidth: 2))
                  : Icon(reproduciendo ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28),
              label: Text(
                reproduciendo ? 'PAUSAR AUDIO' : 'ESCUCHAR AUDIO',
                style: AppText.label.copyWith(fontSize: 14, letterSpacing: 1.2),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.granate,
                foregroundColor: AppColors.dorado,
                shape: RoundedRectangleBorder(borderRadius: Rad.rPill),
                elevation: 4,
                shadowColor: AppColors.granate.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}