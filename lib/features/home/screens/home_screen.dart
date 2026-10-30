// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../services/novedades_service.dart';
import '../../inicio/screens/inicio_screen.dart';
import '../../cancionero/screens/cancionero_screen.dart'; // <-- NUEVO IMPORT
import '../widgets/main_nav_bar.dart';
import '../widgets/mini_player.dart';

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      InicioScreen(nombreUsuario: widget.nombreUsuario),
      const CancioneroScreen(), // <-- NUEVA PANTALLA
      const Center(child: Text('Eventos (En construcción)', style: TextStyle(color: Colors.white))),
      const Center(child: Text('Recuerdos (En construcción)', style: TextStyle(color: Colors.white))),
      const Center(child: Text('Perfil (En construcción)', style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
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