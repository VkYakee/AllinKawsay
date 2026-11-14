// lib/widgets/tarjeta_compartible.dart
import 'package:flutter/material.dart';

import '../core/design/colors.dart';
import '../core/widgets/atril_numerofonia.dart';
import '../models/cancion.dart';

/// Tarjeta ceremonial para exportar o compartir partituras y letras en WhatsApp / redes.
/// Diseñada con proporción de atril musical de alta legibilidad.
class TarjetaCompartible extends StatelessWidget {
  final Cancion cancion;
  const TarjetaCompartible({super.key, required this.cancion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 780,
      decoration: BoxDecoration(
        color: const Color(0xFF0C0D11),
        border: Border.all(color: AppColors.dorado, width: 2.5),
      ),
      child: Stack(
        children: [
          // Marca de agua central sutil
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.05,
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 480,
                    height: 480,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.music_note,
                      size: 260,
                      color: AppColors.dorado,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── CABECERA CEREMONIAL ───
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.dorado, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dorado.withOpacity(0.25),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.granateProfundo,
                            child: const Icon(
                              Icons.audiotrack,
                              color: AppColors.dorado,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'C.I.A.C. ALLIN KAWSAY',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.dorado,
                              letterSpacing: 2.5,
                              fontFamily: 'serif',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hermandad de Sikuris · Juliaca, Puno, Perú',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.75),
                              fontStyle: FontStyle.italic,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.granateOscuro,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.dorado.withOpacity(0.4),
                        ),
                      ),
                      child: const Text(
                        'PARTITURA OFICIAL',
                        style: TextStyle(
                          color: AppColors.dorado,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Divisor dorado ceremonial doble
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: AppColors.dorado.withOpacity(0.8),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.dorado.withOpacity(0.9),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1.5,
                        color: AppColors.dorado.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ─── TÍTULO Y METADATOS ───
                Text(
                  cancion.titulo.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dorado,
                    letterSpacing: 1.2,
                  ),
                ),
                if (cancion.autor.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Autor: ${cancion.autor}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ],
                if (cancion.ritmo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dorado.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.dorado.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        cancion.ritmo.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dorado,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],

                // ─── NUMEROFONÍA EN FORMATO ATRIL FIJO ───
                if (cancion.tieneNumerofonia) ...[
                  const SizedBox(height: 28),
                  AtrilNumerofonia(
                    estrofas: cancion.estrofas,
                    fontSize: 17,
                  ),
                ],

                // ─── LETRAS ───
                if (cancion.tieneLetra) ...[
                  const SizedBox(height: 28),
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
                          color: AppColors.dorado,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14151B),
                          border: Border.all(
                            color: AppColors.dorado.withOpacity(0.25),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          cancion.letras[i].texto,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                ],

                const SizedBox(height: 20),

                // ─── PIE DE PÁGINA ───
                Container(
                  height: 1,
                  color: AppColors.dorado.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'App Oficial · Allin Kawsay',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      'Preservando el arte del Siku · Puno, Perú',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.dorado.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
