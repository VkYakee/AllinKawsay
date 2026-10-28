// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/novedades_service.dart';
import '../widgets/comunes/main_nav_bar.dart';
import '../widgets/comunes/mini_player.dart'; // <-- NUEVO
import '../widgets/onboarding/permisos_dialog.dart';
import 'cancionero_screen.dart';
import 'eventos_screen.dart';
import 'inicio_screen.dart';
import 'perfil_screen.dart';
import 'recuerdos_screen.dart';
import 'tutorial_screen.dart';

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
    _verificarOnboarding();
  }

  Future<void> _verificarOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorialVisto = prefs.getBool('tutorial_visto') ?? false;
    final permisosVistos = prefs.getBool('permisos_vistos') ?? false;

    if (!tutorialVisto && mounted) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const TutorialScreen()));
      await prefs.setBool('tutorial_visto', true);
    }

    if (!permisosVistos && mounted) {
      await PermisosDialog.mostrar(context);
      await prefs.setBool('permisos_vistos', true);
    }
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
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(), // <-- SE MUESTRA AQUÍ
          ValueListenableBuilder<int>(
            valueListenable: NovedadesService.eventosNuevos,
            builder: (context, count, _) {
              return MainNavBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                eventosNuevos: count,
              );
            },
          ),
        ],
      ),
    );
  }
}