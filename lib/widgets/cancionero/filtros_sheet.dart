// lib/widgets/cancionero/filtros_sheet.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/categoria.dart';
import '../../theme/colors.dart';
import 'filtros_cancionero.dart';
import 'filtros_sheet_partes.dart';

class FiltrosSheet extends StatefulWidget {
  final FiltrosCancionero actual;
  final List<Categoria> categorias;
  final List<String> tags;

  const FiltrosSheet({
    super.key,
    required this.actual,
    required this.categorias,
    required this.tags,
  });

  static Future<FiltrosCancionero?> mostrar(
    BuildContext context, {
    required FiltrosCancionero actual,
    required List<Categoria> categorias,
    required List<String> tags,
  }) {
    return showModalBottomSheet<FiltrosCancionero>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FiltrosSheet(
        actual: actual,
        categorias: categorias,
        tags: tags,
      ),
    );
  }

  @override
  State<FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<FiltrosSheet> {
  late FiltrosCancionero _f;

  @override
  void initState() {
    super.initState();
    _f = widget.actual;
  }

  void _set(FiltrosCancionero n) => setState(() => _f = n);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sp.xl, Sp.md, Sp.xl, Sp.lg),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetHandle(),
                const SizedBox(height: Sp.lg),
                SheetHeader(
                    onLimpiar: () => _set(const FiltrosCancionero())),
                const SizedBox(height: Sp.sm),
                ChipsSeccion(
                  titulo: 'Orden',
                  children: OrdenCancion.values.map((o) {
                    return AppFilterChip(
                      label: _label(o),
                      selected: _f.orden == o,
                      onSelected: (_) => _set(_f.copyWith(orden: o)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: Sp.lg),
                ChipsSeccion(
                  titulo: 'Mostrar',
                  children: [
                    AppFilterChip(
                      label: 'Solo favoritos',
                      selected: _f.soloFavoritos,
                      onSelected: (v) =>
                          _set(_f.copyWith(soloFavoritos: v)),
                    ),
                  ],
                ),
                if (widget.categorias.isNotEmpty) ...[
                  const SizedBox(height: Sp.lg),
                  ChipsSeccion(
                    titulo: 'Categoría',
                    children: widget.categorias.map((c) {
                      final sel = _f.categoriaId == c.id;
                      return AppFilterChip(
                        label: '${c.emoji} ${c.nombre}',
                        selected: sel,
                        onSelected: (_) => _set(sel
                            ? _f.copyWith(limpiarCategoria: true)
                            : _f.copyWith(categoriaId: c.id)),
                      );
                    }).toList(),
                  ),
                ],
                if (widget.tags.isNotEmpty) ...[
                  const SizedBox(height: Sp.lg),
                  ChipsSeccion(
                    titulo: 'Etiqueta',
                    children: widget.tags.map((t) {
                      final sel = _f.tag == t;
                      return AppFilterChip(
                        label: t,
                        selected: sel,
                        onSelected: (_) => _set(sel
                            ? _f.copyWith(limpiarTag: true)
                            : _f.copyWith(tag: t)),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: Sp.xl),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _f),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.granate,
                    foregroundColor: AppColors.dorado,
                    padding:
                        const EdgeInsets.symmetric(vertical: Sp.lg),
                    shape: RoundedRectangleBorder(
                        borderRadius: Rad.rMd),
                  ),
                  child: Text(
                    'Aplicar filtros',
                    style: AppType.label
                        .copyWith(color: AppColors.dorado),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _label(OrdenCancion o) {
    switch (o) {
      case OrdenCancion.titulo:
        return 'Título';
      case OrdenCancion.autor:
        return 'Autor';
      case OrdenCancion.reproducciones:
        return 'Populares';
      case OrdenCancion.recientes:
        return 'Recientes';
    }
  }
}