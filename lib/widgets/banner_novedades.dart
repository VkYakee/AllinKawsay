// lib/widgets/banner_novedades.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../theme/colors.dart';

class BannerNovedades extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback? onTap;
  final VoidCallback? onCerrar;

  const BannerNovedades({
    super.key,
    this.icono = Icons.auto_awesome,
    required this.titulo,
    this.subtitulo,
    this.onTap,
    this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, Sp.sm),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.md),
        onTap: onTap,
        border: Border.all(color: AppColors.dorado.withOpacity(0.5)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.sm),
              decoration: BoxDecoration(gradient: AppColors.gradienteDorado, borderRadius: Rad.rMd),
              child: Icon(icono, color: AppColors.granate, size: 20),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppType.subtitle.copyWith(color: AppColors.granate), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (subtitulo != null && subtitulo!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitulo!, style: AppType.captionXs.copyWith(color: AppColors.granate.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            if (onCerrar != null)
              IconButton(icon: const Icon(Icons.close, size: 18, color: AppColors.granate), onPressed: onCerrar, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          ],
        ),
      ),
    );
  }
}