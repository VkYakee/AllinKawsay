// lib/widgets/inicio/proximo_evento.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/evento.dart';
import '../../services/evento_service.dart';
import '../../theme/colors.dart';
import 'estados.dart';

class ProximoEventoCard extends StatelessWidget {
  const ProximoEventoCard({super.key});

  static const _meses = [
    '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
  ];

  static String _hora(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Evento>>(
      stream: EventoService().listar(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SkeletonCard(height: 100);
        }
        if (snap.hasError) return const ErrorMini();

        final futuros = (snap.data ?? [])
            .where((e) => e.fecha.isAfter(DateTime.now()))
            .toList();
        if (futuros.isEmpty) {
          return const EmptyMini(
              icon: Icons.event_busy,
              text: 'Sin eventos próximos');
        }

        final e = futuros.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
          child: AppCard(
            color: AppColors.granate,
            border: Border.all(
                color: AppColors.dorado.withOpacity(0.3)),
            child: Row(
              children: [
                _BloqueFecha(fecha: e.fecha, meses: _meses),
                const SizedBox(width: Sp.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppColors.dorado,
                        ),
                      ),
                      const SizedBox(height: Sp.xs + 2),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 12,
                              color:
                                  AppColors.dorado.withOpacity(0.8)),
                          const SizedBox(width: 4),
                          Text(
                            _hora(e.fecha),
                            style: TextStyle(
                                color: AppColors.dorado
                                    .withOpacity(0.9),
                                fontSize: 12),
                          ),
                          if (e.lugar.isNotEmpty) ...[
                            const SizedBox(width: Sp.md),
                            Icon(Icons.place,
                                size: 12,
                                color: AppColors.dorado
                                    .withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                e.lugar,
                                style: TextStyle(
                                    color: AppColors.dorado
                                        .withOpacity(0.9),
                                    fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
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

class _BloqueFecha extends StatelessWidget {
  final DateTime fecha;
  final List<String> meses;

  const _BloqueFecha({required this.fecha, required this.meses});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: Rad.rMd,
        border: Border.all(color: AppColors.dorado.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${fecha.day}',
            style: const TextStyle(
              color: AppColors.dorado,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          Text(
            meses[fecha.month],
            style: TextStyle(
              color: AppColors.dorado.withOpacity(0.9),
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}