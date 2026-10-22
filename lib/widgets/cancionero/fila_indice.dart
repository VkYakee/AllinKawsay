// lib/widgets/cancionero/fila_indice.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/cancion.dart';
import '../../theme/colors.dart';

class FilaIndice extends StatelessWidget {
  final Cancion cancion;
  final VoidCallback onTap;

  const FilaIndice({
    super.key,
    required this.cancion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Sp.xl, vertical: Sp.md + 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.dorado.withOpacity(0.12),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Sp.lg),
              Expanded(
                child: Text(
                  cancion.titulo,
                  style: AppType.subtitle.copyWith(color: onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Sp.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.dorado.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}