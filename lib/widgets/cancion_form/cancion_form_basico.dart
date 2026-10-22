// lib/widgets/cancion_form/cancion_form_basico.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/categoria.dart';
import '../../theme/colors.dart';

class CancionFormBasico extends StatelessWidget {
  final TextEditingController tituloCtrl;
  final TextEditingController autorCtrl;
  final TextEditingController ritmoCtrl;
  final TextEditingController regionCtrl;
  final TextEditingController tagsCtrl;
  final String tipo;
  final ValueChanged<String> onTipoChanged;
  final String categoriaId;
  final List<Categoria> categorias;
  final bool cargandoCategorias;
  final ValueChanged<String?> onCategoriaChanged;

  const CancionFormBasico({
    super.key,
    required this.tituloCtrl,
    required this.autorCtrl,
    required this.ritmoCtrl,
    required this.regionCtrl,
    required this.tagsCtrl,
    required this.tipo,
    required this.onTipoChanged,
    required this.categoriaId,
    required this.categorias,
    required this.cargandoCategorias,
    required this.onCategoriaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Sp.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SeccionHeader(
              title: 'Información Básica',
              icon: Icons.info_outline,
              padding: EdgeInsets.zero),
          const SizedBox(height: Sp.md),
          AppInput(controller: tituloCtrl, label: 'Título *', prefixIcon: Icons.music_note),
          const SizedBox(height: Sp.md),
          AppInput(controller: autorCtrl, label: 'Autor', prefixIcon: Icons.person_outline),
          const SizedBox(height: Sp.md),
          Row(
            children: [
              Expanded(child: AppInput(controller: ritmoCtrl, label: 'Ritmo')),
              const SizedBox(width: Sp.md),
              Expanded(child: AppInput(controller: regionCtrl, label: 'Región')),
            ],
          ),
          const SizedBox(height: Sp.lg),
          Row(
            children: [
              Expanded(
                child: AppFilterChip(
                  label: 'Original',
                  selected: tipo == 'original',
                  onSelected: (_) => onTipoChanged('original'),
                ),
              ),
              const SizedBox(width: Sp.sm),
              Expanded(
                child: AppFilterChip(
                  label: 'Adaptación',
                  selected: tipo == 'adaptacion',
                  onSelected: (_) => onTipoChanged('adaptacion'),
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.lg),
          if (cargandoCategorias)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String>(
              value: categorias.any((c) => c.id == categoriaId) ? categoriaId : null,
              decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category)),
              items: [
                const DropdownMenuItem(value: '', child: Text('Sin categoría')),
                ...categorias.map((c) => DropdownMenuItem(
                    value: c.id, child: Text('${c.emoji} ${c.nombre}'))),
              ],
              onChanged: onCategoriaChanged,
            ),
          const SizedBox(height: Sp.md),
          AppInput(
            controller: tagsCtrl,
            label: 'Etiquetas',
            hint: 'separadas por coma (ej: huayño, festivo)',
            prefixIcon: Icons.local_offer_outlined,
          ),
        ],
      ),
    );
  }
}