// lib/widgets/tarjeta_compartible.dart
import 'package:flutter/material.dart';
import '../models/cancion.dart';
import '../theme/colors.dart';
import 'visor_numerofonia.dart';

class TarjetaCompartible extends StatelessWidget {
  final Cancion cancion;
  const TarjetaCompartible({super.key, required this.cancion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      color: AppColors.blanco,
      child: Stack(
        children: [
          // Marca de agua sutil
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.04,
                child: Center(
                  child: Image.asset('assets/logo.png', width: 500, height: 500, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ClipOval(child: Image.asset('assets/logo.png', width: 70, height: 70, fit: BoxFit.cover)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ALLIN KAWSAY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.granate, letterSpacing: 2)),
                        Text('Grupo de Sikuris', style: TextStyle(fontSize: 14, color: AppColors.negro, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(height: 2, color: AppColors.dorado),
                const SizedBox(height: 32),
                
                Text(cancion.titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.granate)),
                if (cancion.autor.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(cancion.autor, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: AppColors.negro)),
                ],
                if (cancion.ritmo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(cancion.ritmo, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.negro.withOpacity(0.6))),
                ],

                if (cancion.tieneNumerofonia) ...[
                  const SizedBox(height: 32),
                  VisorNumerofonia(estrofas: cancion.estrofas, escala: 1.0),
                ],

                if (cancion.tieneLetra) ...[
                  const SizedBox(height: 32),
                  for (int i = 0; i < cancion.letras.length; i++)
                    if (!cancion.letras[i].vacia) ...[
                      Text(
                        cancion.letras[i].titulo.isNotEmpty ? cancion.letras[i].titulo.toUpperCase() : 'LETRA ${i + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.granate, letterSpacing: 2),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.blanco, border: Border.all(color: AppColors.negro.withOpacity(0.1)), borderRadius: BorderRadius.circular(12)),
                        child: Text(cancion.letras[i].texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.8, color: AppColors.negro, fontStyle: FontStyle.italic)),
                      ),
                    ],
                ],
                const SizedBox(height: 24),
                Container(height: 1, color: AppColors.dorado),
                const SizedBox(height: 12),
                const Text('Compartido desde la app oficial', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.negro, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}