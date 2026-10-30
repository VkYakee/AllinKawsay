// lib/features/inicio/screens/inicio_screen.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_button.dart';
import '../../auth/screens/login_screen.dart'; // Solo para tener referencia si algo falla
import '../../../screens/busqueda_global_screen.dart'; // Pantalla vieja (se migrará luego)
import '../../../screens/zampona_screen.dart'; // Pantalla vieja (se migrará luego)

class InicioScreen extends StatefulWidget {
  final String nombreUsuario;
  const InicioScreen({super.key, required this.nombreUsuario});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: CustomScrollView(
        slivers: [
          // 1. HERO INMERSIVO (SliverAppBar)
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.fondoOscuro,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHero(),
            ),
          ),
          
          // 2. CONTENIDO
          SliverPadding(
            padding: const EdgeInsets.all(Sp.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: Sp.md),
                
                // Bento Grid de Accesos Rápidos
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        glass: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusquedaGlobalScreen())),
                        child: Column(
                          children: [
                            const Icon(Icons.search, color: AppColors.dorado, size: 32),
                            const SizedBox(height: Sp.sm),
                            Text('Buscar', style: AppText.subtitle.copyWith(color: AppColors.dorado)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: Sp.md),
                    Expanded(
                      child: AppCard(
                        glass: true,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZamponaScreen())),
                        child: Column(
                          children: [
                            const Icon(Icons.piano, color: AppColors.dorado, size: 32),
                            const SizedBox(height: Sp.sm),
                            Text('Zampoña', style: AppText.subtitle.copyWith(color: AppColors.dorado)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: Sp.xl),
                Text('Últimas canciones', style: AppText.h3.copyWith(color: AppColors.dorado)),
                const SizedBox(height: Sp.md),
                // Aquí irán las canciones (en la Fase 3)
                AppCard(
                  glass: true,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Sp.xl),
                      child: Text('Cargando canciones...', style: AppText.body.copyWith(color: Colors.white54)),
                    ),
                  ),
                ),
                
                const SizedBox(height: Sp.xxxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.granateOscuro,
            AppColors.granate,
            AppColors.fondoOscuro,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sp.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${widget.nombreUsuario}',
                style: AppText.h1.copyWith(color: AppColors.dorado, fontSize: 28),
              ),
              const SizedBox(height: Sp.xs),
              Text(
                'Bienvenido a Allin Kawsay',
                style: AppText.body.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}