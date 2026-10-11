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
          // === MARCA DE AGUA ===
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.06,
                child: Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 500,
                      height: 500,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // === CONTENIDO ===
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.granate,
                          child: const Icon(Icons.music_note,
                              color: AppColors.dorado),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ALLIN KAWSAY',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.granate,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Grupo de Sikuris',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.negro,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(height: 2, color: AppColors.dorado),
                const SizedBox(height: 20),

                // Título
                Text(
                  cancion.titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.granate,
                    letterSpacing: 1,
                  ),
                ),
                if (cancion.autor.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    cancion.autor,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppColors.negro,
                    ),
                  ),
                ],
                if (cancion.ritmo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    cancion.ritmo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.negro.withOpacity(0.6),
                    ),
                  ),
                ],

                // Numerofonía (tablas simétricas, entra completa en 800px)
                if (cancion.tieneNumerofonia) ...[
                  const SizedBox(height: 24),
                  VisorNumerofonia(
                    estrofas: cancion.estrofas,
                    escala: 1.0,
                  ),
                ],

                // Letras con título
                if (cancion.tieneLetra) ...[
                  const SizedBox(height: 24),
                  for (int i = 0; i < cancion.letras.length; i++)
                    if (!cancion.letras[i].vacia) ...[
                      Text(
                        cancion.letras[i].titulo.isNotEmpty
                            ? cancion.letras[i].titulo.toUpperCase()
                            : 'LETRA ${i + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.granate,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.blanco,
                          border: Border.all(
                              color: AppColors.negro.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cancion.letras[i].texto,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            color: AppColors.negro,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                ],

                const SizedBox(height: 24),
                Container(height: 1, color: AppColors.dorado),
                const SizedBox(height: 8),
                const Text(
                  'Compartido desde la app oficial',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.negro,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}