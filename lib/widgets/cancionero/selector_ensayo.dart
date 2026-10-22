// lib/widgets/cancionero/selector_ensayo.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/cancion.dart';
import '../../screens/modo_ensayo_screen.dart';
import '../../theme/colors.dart';

class SelectorEnsayo {
  static Future<void> mostrar(
      BuildContext context, List<Cancion> canciones) async {
    final conPartitura =
        canciones.where((c) => c.tieneNumerofonia).toList();
    if (conPartitura.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('No hay canciones con numerofonía todavía')),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetEnsayo(canciones: conPartitura),
    );
  }
}

class _SheetEnsayo extends StatelessWidget {
  final List<Cancion> canciones;
  const _SheetEnsayo({required this.canciones});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: Sp.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.3),
                  borderRadius: Rad.rPill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Sp.xl, Sp.lg, Sp.xl, Sp.lg),
                child: Column(
                  children: [
                    Text('¿Qué quieres practicar?', style: AppType.h3),
                    const SizedBox(height: Sp.xs),
                    Text(
                      '${canciones.length} canciones con partitura',
                      style: AppType.caption.copyWith(
                          color: onSurface.withOpacity(0.55)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  padding: const EdgeInsets.all(Sp.lg),
                  itemCount: canciones.length,
                  itemBuilder: (context, i) {
                    final c = canciones[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: Sp.sm),
                      child: AppCard(
                        padding: const EdgeInsets.all(Sp.md),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ModoEnsayoScreen(cancion: c),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradienteGranate,
                                borderRadius: Rad.rMd,
                              ),
                              child: const Icon(Icons.school,
                                  color: AppColors.dorado, size: 18),
                            ),
                            const SizedBox(width: Sp.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(c.titulo,
                                      style: AppType.subtitle
                                          .copyWith(color: onSurface),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis),
                                  Text(
                                    '${c.estrofas.where((e) => !e.vacia).length} estrofas',
                                    style: AppType.captionXs.copyWith(
                                        color: onSurface
                                            .withOpacity(0.55)),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.play_circle_outline,
                                color: AppColors.dorado
                                    .withOpacity(0.7),
                                size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}