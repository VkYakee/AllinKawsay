// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/novedades_service.dart';
import '../widgets/comunes/main_nav_bar.dart';
import 'cancionero_screen.dart';
import 'eventos_screen.dart';
import 'inicio_screen.dart';
import 'perfil_screen.dart';
import 'recuerdos_screen.dart';

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
      const CancioneroScreen(),
      const EventosScreen(),
      const RecuerdosScreen(),
      PerfilScreen(nombreUsuario: widget.nombreUsuario),
    ];

    return Scaffold(
      extendBody: true, // <-- Magia: permite que el scroll pase por detrás de la barra
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: NovedadesService.eventosNuevos,
        builder: (context, count, _) {
          return MainNavBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            eventosNuevos: count,
          );
        },
      ),
    );
  }
}