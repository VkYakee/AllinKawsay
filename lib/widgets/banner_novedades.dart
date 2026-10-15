import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Banner de "novedades" que aparece arriba de las pantallas.
/// Se puede cerrar con la X o tocar para navegar.
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.dorado.withOpacity(0.20),
                  AppColors.granate.withOpacity(0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.dorado.withOpacity(0.5), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dorado.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteDorado,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono,
                      color: AppColors.granate, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.granate,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitulo != null && subtitulo!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitulo!,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.granate.withOpacity(0.7),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (onCerrar != null)
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: AppColors.granate),
                    onPressed: onCerrar,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Cerrar',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}