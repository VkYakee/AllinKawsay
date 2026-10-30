// lib/features/onboarding/screens/tutorial_screen.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_button.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _pageController = PageController();
  int _paginaActual = 0;

  final List<Map<String, dynamic>> _paginas = [
    {
      'title': 'El Cancionero',
      'desc': 'Encuentra todas tus canciones con numerofonía, letras y audios en un solo lugar.',
      'widget': const _MockupCancionero(),
      'color': Colors.blueAccent,
    },
    {
      'title': 'Modo Ensayo',
      'desc': 'Aprende a tu ritmo. Usa la zampoña virtual y ajusta la velocidad del audio.',
      'widget': const _MockupEnsayo(),
      'color': Colors.green,
    },
    {
      'title': 'Eventos y Mapas',
      'desc': 'No te pierdas ninguna presentación. Mira el clima y la ubicación exacta en el mapa.',
      'widget': const _MockupEventos(),
      'color': Colors.orange,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _siguiente() {
    if (_paginaActual == _paginas.length - 1) {
      Navigator.pop(context);
    } else {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.5,
                colors: [
                  _paginas[_paginaActual]['color'].withOpacity(0.2),
                  AppColors.fondoOscuro,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('SALTAR', style: AppText.label.copyWith(color: Colors.white54)),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _paginaActual = i),
                    itemCount: _paginas.length,
                    itemBuilder: (context, i) {
                      final p = _paginas[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Sp.xxl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 280, child: p['widget']),
                            const SizedBox(height: Sp.xxl),
                            Text(p['title'], style: AppText.h2.copyWith(color: AppColors.dorado, fontSize: 28)),
                            const SizedBox(height: Sp.md),
                            Text(
                              p['desc'],
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(color: Colors.white70, fontSize: 16, height: 1.5),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(Sp.xxl),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_paginas.length, (i) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _paginaActual == i ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _paginaActual == i ? _paginas[i]['color'] : Colors.white24,
                              borderRadius: Rad.rPill,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: Sp.xl),
                      AppButton(
                        label: _paginaActual == _paginas.length - 1 ? '¡EMPEZAR!' : 'SIGUIENTE',
                        fullWidth: true,
                        onPressed: _siguiente,
                      ),
                    ],
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

// ═══════════════════════════════════════════════════════════
// MOCKUPS VISUALES
// ═══════════════════════════════════════════════════════════

class _MockupCancionero extends StatelessWidget {
  const _MockupCancionero();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      glass: true,
      padding: const EdgeInsets.all(Sp.md),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: Rad.rMd,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white54, size: 20),
                const SizedBox(width: Sp.sm),
                Text('Buscar canción...', style: AppText.captionXs.copyWith(color: Colors.white54)),
              ],
            ),
          ),
          const SizedBox(height: Sp.md),
          _filaCancion('Adiós Conima', 'Huayño', AppColors.gradienteGranate),
          const SizedBox(height: Sp.sm),
          _filaCancion('Aguila Negra', 'Huayño', AppColors.gradienteGranate),
        ],
      ),
    );
  }

  Widget _filaCancion(String titulo, String ritmo, Gradient grad) {
    return Container(
      padding: const EdgeInsets.all(Sp.sm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: Rad.rMd,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(gradient: grad, borderRadius: Rad.rSm), child: const Icon(Icons.music_note, color: AppColors.dorado, size: 16)),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppText.subtitle.copyWith(color: Colors.white, fontSize: 13)),
                Text(ritmo, style: AppText.captionXs.copyWith(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.play_arrow_rounded, color: AppColors.dorado, size: 20),
        ],
      ),
    );
  }
}

class _MockupEnsayo extends StatelessWidget {
  const _MockupEnsayo();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      glass: true,
      padding: const EdgeInsets.all(Sp.md),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF14080A),
              borderRadius: Rad.rMd,
              border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(width: 20, color: AppColors.granate),
                const SizedBox(width: 4),
                Text('3 2 2 2', style: AppText.mono.copyWith(color: AppColors.dorado, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: Sp.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 1; i <= 5; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 28, height: 28,
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.gradienteGranate),
                  alignment: Alignment.center,
                  child: Text('$i', style: const TextStyle(color: AppColors.dorado, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockupEventos extends StatelessWidget {
  const _MockupEventos();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      glass: true,
      padding: const EdgeInsets.all(Sp.md),
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.2),
              borderRadius: Rad.rMd,
              border: Border.all(color: Colors.white12),
            ),
            child: const Center(child: Icon(Icons.location_on, color: AppColors.granate, size: 30)),
          ),
          const SizedBox(height: Sp.md),
          Container(
            padding: const EdgeInsets.all(Sp.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: Rad.rMd,
              border: Border.all(color: AppColors.dorado.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(gradient: AppColors.gradienteGranate, borderRadius: Rad.rSm),
                  alignment: Alignment.center,
                  child: Text('15', style: AppText.title.copyWith(color: AppColors.dorado)),
                ),
                const SizedBox(width: Sp.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fiesta Patronal', style: AppText.subtitle.copyWith(color: Colors.white, fontSize: 13)),
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny, color: Colors.orange, size: 12),
                        const SizedBox(width: 4),
                        Text('22°C', style: AppText.captionXs.copyWith(color: Colors.white54, fontSize: 10)),
                      ],
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