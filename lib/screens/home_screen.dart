import 'package:flutter/material.dart';
import '../services/novedades_service.dart';
import '../theme/colors.dart';
import 'busqueda_global_screen.dart';
import 'cancionero_screen.dart';
import 'eventos_screen.dart';
import 'inicio_screen.dart';
import 'perfil_screen.dart';
import 'recuerdos_screen.dart';
import 'zampona_screen.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  const HomeScreen({super.key, required this.nombreUsuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    NovedadesService.refrescar();
  }

  void _abrirZampona() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ZamponaScreen()),
    );
  }

  void _abrirBusqueda() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BusquedaGlobalScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      InicioScreen(nombreUsuario: widget.nombreUsuario),
      const CancioneroScreen(),
      const EventosScreen(),
      const RecuerdosScreen(),
      PerfilScreen(nombreUsuario: widget.nombreUsuario),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: pages),

          // ═══ FABs FLOTANTES (izquierda para no tapar el botón +) ═══
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'fab_zampona',
                  onPressed: _abrirZampona,
                  backgroundColor: AppColors.granate,
                  foregroundColor: AppColors.dorado,
                  elevation: 4,
                  tooltip: 'Zampoña',
                  child: const _IconoZampona(
                    color: AppColors.dorado,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'fab_busqueda',
                  onPressed: _abrirBusqueda,
                  backgroundColor: AppColors.granate,
                  foregroundColor: AppColors.dorado,
                  elevation: 4,
                  tooltip: 'Buscar',
                  child: const Icon(Icons.search, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio'),
          const NavigationDestination(
              icon: Icon(Icons.library_music_outlined),
              selectedIcon: Icon(Icons.library_music),
              label: 'Cancionero'),
          NavigationDestination(
            icon: ValueListenableBuilder<int>(
              valueListenable: NovedadesService.eventosNuevos,
              builder: (context, count, child) {
                return Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  backgroundColor: AppColors.granate,
                  textColor: AppColors.dorado,
                  child: child,
                );
              },
              child: const Icon(Icons.event_outlined),
            ),
            selectedIcon: ValueListenableBuilder<int>(
              valueListenable: NovedadesService.eventosNuevos,
              builder: (context, count, child) {
                return Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  backgroundColor: AppColors.granate,
                  textColor: AppColors.dorado,
                  child: child,
                );
              },
              child: const Icon(Icons.event),
            ),
            label: 'Eventos',
          ),
          const NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library),
              label: 'Recuerdos'),
          const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil'),
        ],
      ),
    );
  }
}

/// Ícono de zampoña dibujado a mano:
/// 4 cañitas verticales con alturas variadas (agudo → grave).
class _IconoZampona extends StatelessWidget {
  final Color color;
  final double size;
  const _IconoZampona({required this.color, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ZamponaPainter(color: color)),
    );
  }
}

class _ZamponaPainter extends CustomPainter {
  final Color color;
  _ZamponaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const totalCanias = 4;
    final anchoCania = size.width * 0.16;
    final gapTotal =
        size.width - (anchoCania * totalCanias);
    final separacion = gapTotal / (totalCanias - 1);

    // Alturas relativas (aguda → grave)
    const alturas = [0.55, 0.75, 0.9, 1.0];

    for (int i = 0; i < totalCanias; i++) {
      final x = i * (anchoCania + separacion);
      final h = size.height * alturas[i];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, anchoCania, h),
        Radius.circular(anchoCania * 0.45),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ZamponaPainter old) =>
      old.color != color;
}