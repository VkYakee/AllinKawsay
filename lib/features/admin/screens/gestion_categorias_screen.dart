// lib/features/admin/screens/gestion_categorias_screen.dart
import 'package:flutter/material.dart';

import '../../../design/design.dart';
import '../../../models/categoria.dart';
import '../../../services/categoria_service.dart';
import '../../../widgets/admin/categoria_card.dart';
import '../../../widgets/admin/categoria_modal.dart';

class GestionCategoriasScreen extends StatefulWidget {
  const GestionCategoriasScreen({super.key});

  @override
  State<GestionCategoriasScreen> createState() =>
      _GestionCategoriasScreenState();
}

class _GestionCategoriasScreenState extends State<GestionCategoriasScreen> {
  final _service = CategoriaService();

  Future<void> _eliminar(Categoria c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Eliminar "${c.emoji} ${c.nombre}"? Las canciones quedarán sin categoría.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) await _service.eliminar(c.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Categorías',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CategoriaModal.mostrar(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: StreamBuilder<List<Categoria>>(
        stream: _service.listar(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppSkeletonList(items: 5);
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const AppEmptyState(
              icon: Icons.category_outlined,
              title: 'Sin categorías',
              subtitle:
                  'Toca el botón + para crear la primera.\nEjemplos: 🎭 Carnaval, ⛪ Religioso.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.lg, 100),
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final c = lista[i];
              return CategoriaCard(
                categoria: c,
                onEditar: () =>
                    CategoriaModal.mostrar(context, categoria: c),
                onEliminar: () => _eliminar(c),
              );
            },
          );
        },
      ),
    );
  }
}