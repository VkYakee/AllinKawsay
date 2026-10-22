// lib/widgets/inicio/proximo_evento_card.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/evento.dart';
import '../../services/evento_service.dart';
import '../../theme/colors.dart';
import 'estados.dart';

class ProximoEventoCard extends StatelessWidget {
  const ProximoEventoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Evento>>(
      stream: EventoService().listar(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SkeletonCard(height: 100);
        }
        final futuros = (snap.data ?? []).where((e) => e.fecha.isAfter(DateTime.now())).toList();
        if (futuros.isEmpty) {
          return const EmptyMini(icon: Icons.event_busy, text: 'Sin eventos próximos');
        }

        final e = futuros.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
          child: AppCard(
            color: AppColors.granate,
            padding: const EdgeInsets.all(Sp.lg),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: Rad.rMd,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${e.fecha.day}', style: AppType.h2.copyWith(color: AppColors.dorado, height: 1)),
                      Text(
                        ['', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'][e.fecha.month],
                        style: AppType.labelXs.copyWith(color: AppColors.dorado.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.titulo, style: AppType.h3.copyWith(color: AppColors.dorado), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('${e.fecha.hour.toString().padLeft(2, '0')}:${e.fecha.minute.toString().padLeft(2, '0')} · ${e.lugar}', style: AppType.captionXs.copyWith(color: AppColors.dorado.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}