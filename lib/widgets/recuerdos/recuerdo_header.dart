// lib/widgets/recuerdos/recuerdo_header.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/recuerdo.dart';
import '../../theme/colors.dart';

class RecuerdoHeader extends StatelessWidget {
  final Recuerdo recuerdo;
  const RecuerdoHeader({super.key, required this.recuerdo});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.all(Sp.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recuerdo.titulo,
            style: AppType.h1.copyWith(color: AppColors.granate),
          ),
          const SizedBox(height: Sp.sm),
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: 16, color: onSurface.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(recuerdo.creadorNombre, style: AppType.caption),
              if (recuerdo.fecha != null) ...[
                const SizedBox(width: Sp.md),
                Icon(Icons.calendar_today,
                    size: 14, color: onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  '${recuerdo.fecha!.day}/${recuerdo.fecha!.month}/${recuerdo.fecha!.year}',
                  style: AppType.caption,
                ),
              ],
            ],
          ),
          if (recuerdo.descripcion.isNotEmpty) ...[
            const SizedBox(height: Sp.md),
            Text(
              recuerdo.descripcion,
              style: AppType.body.copyWith(color: onSurface.withOpacity(0.8)),
            ),
          ],
        ],
      ),
    );
  }
}