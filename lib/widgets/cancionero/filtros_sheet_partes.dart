// lib/widgets/cancionero/filtros_sheet_partes.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.granate.withOpacity(0.3),
          borderRadius: Rad.rPill,
        ),
      ),
    );
  }
}

class SheetHeader extends StatelessWidget {
  final VoidCallback onLimpiar;
  const SheetHeader({super.key, required this.onLimpiar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Filtros', style: AppType.h3),
        const Spacer(),
        TextButton(
          onPressed: onLimpiar,
          child: Text(
            'Limpiar',
            style: AppType.label
                .copyWith(color: AppColors.granate.withOpacity(0.7)),
          ),
        ),
      ],
    );
  }
}

class ChipsSeccion extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const ChipsSeccion({
    super.key,
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sp.sm),
          child: Text(
            titulo.toUpperCase(),
            style: AppType.eyebrow
                .copyWith(color: AppColors.seccionTitulo(context)),
          ),
        ),
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: children),
      ],
    );
  }
}