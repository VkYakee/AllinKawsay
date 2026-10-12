import 'package:flutter/material.dart';
import '../../models/recuerdo.dart';
import '../../theme/colors.dart';

class HeroTitulo extends StatelessWidget {
  final Recuerdo recuerdo;
  final Color onSurface;

  const HeroTitulo({
    super.key,
    required this.recuerdo,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.granate.withOpacity(0.08),
            AppColors.dorado.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recuerdo.titulo,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.granate,
              letterSpacing: 0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: onSurface.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                recuerdo.creadorNombre,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          if (recuerdo.fecha != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: onSurface.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  '${recuerdo.fecha!.day}/${recuerdo.fecha!.month}/${recuerdo.fecha!.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}