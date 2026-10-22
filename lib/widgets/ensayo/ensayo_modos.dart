// lib/widgets/ensayo/ensayo_modos.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class EnsayoModos extends StatelessWidget {
  final String modo; // 'audio', 'solo7', 'solo6'
  final bool puedeAudio;
  final ValueChanged<String> onCambiar;

  const EnsayoModos({
    super.key,
    required this.modo,
    required this.puedeAudio,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (puedeAudio)
          Expanded(child: _chip('Audio', Icons.headphones, 'audio', Colors.purpleAccent)),
        if (puedeAudio) const SizedBox(width: Sp.xs),
        Expanded(child: _chip('Solo 7', Icons.arrow_upward, 'solo7', Colors.green)),
        const SizedBox(width: Sp.xs),
        Expanded(child: _chip('Solo 6', Icons.arrow_downward, 'solo6', Colors.blueAccent)),
      ],
    );
  }

  Widget _chip(String label, IconData icon, String value, Color color) {
    final activo = modo == value;
    return GestureDetector(
      onTap: () => onCambiar(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: Sp.sm),
        decoration: BoxDecoration(
          gradient: activo ? LinearGradient(colors: [color, color.withOpacity(0.6)]) : null,
          color: activo ? null : Colors.white.withOpacity(0.05),
          borderRadius: Rad.rMd,
          border: Border.all(color: activo ? color : color.withOpacity(0.3), width: activo ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: activo ? Colors.white : color),
            const SizedBox(height: 2),
            Text(label, style: AppType.labelXs.copyWith(color: activo ? Colors.white : color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}