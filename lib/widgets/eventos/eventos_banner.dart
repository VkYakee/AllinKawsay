// lib/widgets/eventos/eventos_banner.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class EventosBanner extends StatelessWidget {
  final int nuevos;
  const EventosBanner({super.key, required this.nuevos});

  @override
  Widget build(BuildContext context) {
    if (nuevos <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, Sp.sm),
      child: Container(
        padding: const EdgeInsets.all(Sp.md),
        decoration: BoxDecoration(
          color: AppColors.dorado.withOpacity(0.15),
          borderRadius: Rad.rMd,
          border: Border.all(color: AppColors.dorado.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.celebration, color: AppColors.granate, size: 20),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Text(
                '$nuevos evento(s) nuevo(s) desde tu última visita',
                style: AppType.subtitle.copyWith(color: AppColors.granate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}