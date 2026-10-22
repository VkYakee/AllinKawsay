// lib/screens/actividad_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../services/actividad_service.dart';
import '../theme/colors.dart';
import '../widgets/admin/actividad_item.dart';

class ActividadScreen extends StatelessWidget {
  const ActividadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Historial de Actividad',
      body: StreamBuilder<List<Actividad>>(
        stream: ActividadService().listar(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppSkeletonList(items: 6);
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}', style: AppType.body));
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const AppEmptyState(
              icon: Icons.history,
              title: 'Sin actividad',
              subtitle: 'Las acciones del grupo aparecerán aquí.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(Sp.lg),
            itemCount: lista.length,
            itemBuilder: (context, i) => ActividadItem(actividad: lista[i]),
          );
        },
      ),
    );
  }
}