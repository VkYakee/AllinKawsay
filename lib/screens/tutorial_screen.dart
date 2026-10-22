// lib/screens/tutorial_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../theme/colors.dart';

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
      'icon': Icons.home_rounded,
      'title': 'Inicio',
      'desc': 'Mantente al día con los próximos eventos, las últimas canciones subidas y los recuerdos más recientes del grupo.',
      'color': AppColors.granate,
    },
    {
      'icon': Icons.library_music_rounded,
      'title': 'Cancionero',
      'desc': 'El corazón de la app. Busca canciones, guarda tus favoritas y accede a la numerofonía y letras.',
      'color': Colors.blueAccent,
    },
    {
      'icon': Icons.school_rounded,
      'title': 'Modo Ensayo',
      'desc': 'Dentro de cada canción, toca el botón "Practicar" para usar la zampoña virtual y aprender el ritmo a tu velocidad.',
      'color': Colors.green,
    },
    {
      'icon': Icons.event_rounded,
      'title': 'Eventos',
      'desc': 'Consulta las fechas de las presentaciones. Puedes añadir notas personales a cada evento para no olvidar nada.',
      'color': Colors.orange,
    },
    {
      'icon': Icons.photo_library_rounded,
      'title': 'Recuerdos',
      'desc': 'Revive los mejores momentos. Descarga las fotos y videos para verlos sin conexión a internet.',
      'color': Colors.purpleAccent,
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
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.negro,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('SALTAR', style: AppType.label.copyWith(color: AppColors.dorado.withOpacity(0.6))),
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
                    padding: const EdgeInsets.all(Sp.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Sp.xxl),
                          decoration: BoxDecoration(
                            color: p['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: p['color'].withOpacity(0.5), width: 2),
                          ),
                          child: Icon(p['icon'], size: 80, color: p['color']),
                        ),
                        const SizedBox(height: Sp.xxl),
                        Text(p['title'], style: AppType.h1.copyWith(color: AppColors.dorado, fontSize: 32, letterSpacing: 2)),
                        const SizedBox(height: Sp.lg),
                        Text(
                          p['desc'],
                          textAlign: TextAlign.center,
                          style: AppType.body.copyWith(color: Colors.white70, fontSize: 16, height: 1.6),
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
                          color: _paginaActual == i ? AppColors.dorado : Colors.white24,
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
    );
  }
}