// lib/widgets/inicio/estados.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

/// Esqueleto de carga. Se usa mientras llega data de Firestore.
class SkeletonCard extends StatelessWidget {
  final double height;
  const SkeletonCard({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.xs),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: Rad.rLg,
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.15),
              borderRadius: Rad.rPill,
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado vacío mini (una tarjeta con ícono + texto).
class EmptyMini extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyMini({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.xl),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.sm + 2),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.08),
                borderRadius: Rad.rMd,
              ),
              child: Icon(icon,
                  color: AppColors.granate.withOpacity(0.4), size: 24),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error mini (una tarjeta roja suave).
class ErrorMini extends StatelessWidget {
  const ErrorMini({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: Container(
        padding: const EdgeInsets.all(Sp.lg),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: Rad.rLg,
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Text(
                'Error al cargar',
                style: TextStyle(
                    color: Colors.red.withOpacity(0.8), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}