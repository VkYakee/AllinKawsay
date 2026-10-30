// lib/widgets/perfil/modal_mis_subidas.dart
import 'package:flutter/material.dart';

import '../../design/design.dart';
import '../../features/cancion_detalle/screens/cancion_detalle_screen.dart';
import '../../models/cancion.dart';
import '../../models/recuerdo.dart';
import '../../services/cancion_service.dart';
import '../../services/recuerdo_service.dart';
import '../../theme/colors.dart';

class ModalMisSubidas {
  static void mostrar(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
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
                const SizedBox(height: Sp.lg),
                Text('Mis subidas', style: AppType.h3),
                const SizedBox(height: Sp.md),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder<List<Cancion>>(
                    future: CancionService().listar().first,
                    builder: (context, canSnap) {
                      return FutureBuilder<List<Recuerdo>>(
                        future: RecuerdoService().listar().first,
                        builder: (context, recSnap) {
                          if (!canSnap.hasData || !recSnap.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.granate,
                              ),
                            );
                          }
                          final misCanciones = canSnap.data!
                              .where((c) => c.creadoPor == uid)
                              .toList();
                          final misRecuerdos = recSnap.data!
                              .where((r) => r.creadoPor == uid)
                              .toList();

                          if (misCanciones.isEmpty &&
                              misRecuerdos.isEmpty) {
                            return const AppEmptyState(
                              icon: Icons.inbox,
                              title: 'Sin subidas',
                              subtitle: 'Aún no has subido nada',
                            );
                          }

                          return ListView(
                            controller: scroll,
                            padding: const EdgeInsets.all(Sp.lg),
                            children: [
                              if (misCanciones.isNotEmpty) ...[
                                const SeccionHeader(
                                  title: 'Canciones',
                                  icon: Icons.music_note,
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(height: Sp.sm),
                                ...misCanciones.map((c) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: Sp.sm,
                                      ),
                                      child: AppCard(
                                        padding: const EdgeInsets.all(
                                          Sp.md,
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  CancionDetalleScreen(
                                                cancion: c,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          c.titulo,
                                          style: AppType.subtitle,
                                        ),
                                      ),
                                    )),
                              ],
                              if (misRecuerdos.isNotEmpty) ...[
                                const SizedBox(height: Sp.lg),
                                const SeccionHeader(
                                  title: 'Recuerdos',
                                  icon: Icons.photo_library,
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(height: Sp.sm),
                                ...misRecuerdos.map((r) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: Sp.sm,
                                      ),
                                      child: AppCard(
                                        padding: const EdgeInsets.all(
                                          Sp.md,
                                        ),
                                        child: Text(
                                          r.titulo,
                                          style: AppType.subtitle,
                                        ),
                                      ),
                                    )),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}