import 'package:flutter/material.dart';
import '../../theme/colors.dart';

/// Estado vacío estándar: ícono circular + título + subtítulo opcional
/// + acción opcional (botón). Reutilizable en cualquier lista/pantalla.
class EmptyState extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final Widget? accion;

  const EmptyState({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                size: 64,
                color: AppColors.granate.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.seccionTitulo(context),
                letterSpacing: 0.5,
              ),
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitulo!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: onSurface.withOpacity(0.55),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
            if (accion != null) ...[
              const SizedBox(height: 20),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}