import 'package:flutter/material.dart';
import '../../theme/colors.dart';

/// Card con encabezado (ícono + título) y contenido debajo.
/// Reutilizable en cualquier pantalla donde antes había un
/// `_seccionCard` copiado y pegado.
class SeccionCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Widget child;
  final EdgeInsets padding;

  const SeccionCard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.dorado.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.granate.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono,
                    color: AppColors.seccionTitulo(context), size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.seccionTitulo(context),
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}