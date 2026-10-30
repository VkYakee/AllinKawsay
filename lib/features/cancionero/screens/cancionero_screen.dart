// lib/features/cancionero/screens/cancionero_screen.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_button.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/cancion.dart';
import '../../../models/usuario.dart';
import '../../../services/cancion_service.dart';
import '../../../services/player_service.dart';
import '../../../services/reproduccion_service.dart';
import '../../../services/usuario_service.dart';
import '../../../screens/cancion_detalle_screen.dart'; // Se migrará después
import '../../../screens/agregar_cancion_screen.dart'; // Se migrará después
import '../widgets/cancionero_header.dart';
import '../widgets/tarjeta_cancion.dart';

class CancioneroScreen extends StatefulWidget {
  const CancioneroScreen({super.key});

  @override
  State<CancioneroScreen> createState() => _CancioneroScreenState();
}

class _CancioneroScreenState extends State<CancioneroScreen> {
  final _service = CancionService();
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    UsuarioService().soyAdmin().then((a) {
      if (mounted) setState(() => _esAdmin = a);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(Cancion c) async {
    final yaSonaba = PlayerService().sonando(c.id);
    await PlayerService().toggle(c);
    if (PlayerService().sonando(c.id) && !yaSonaba) {
      await ReproduccionService.contarUnaVez(c.id);
    }
  }

  void _abrir(Cancion c) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CancionDetalleScreen(cancion: c)));
  }

  List<Cancion> _filtrar(List<Cancion> lista) {
    if (_query.isEmpty) return lista;
    final q = _query.toLowerCase();
    return lista.where((c) =>
        c.titulo.toLowerCase().contains(q) ||
        c.autor.toLowerCase().contains(q) ||
        c.ritmo.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      floatingActionButton: _esAdmin 
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgregarCancionScreen())),
                icon: const Icon(Icons.add),
                label: const Text('Nueva'),
                backgroundColor: AppColors.granate,
                foregroundColor: AppColors.dorado,
              ),
            )
          : null,
      body: StreamBuilder<List<Cancion>>(
        stream: _service.listar(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.dorado));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}', style: AppText.body.copyWith(color: Colors.red)));
          }
          
          final todas = snap.data ?? [];
          final filtradas = _filtrar(todas);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: CancioneroHeader(
                  totalCanciones: todas.length,
                  searchCtrl: _searchCtrl,
                  onSearchChanged: (v) => setState(() => _query = v),
                  onClearSearch: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
              ),
              
              if (filtradas.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: AppColors.dorado.withOpacity(0.3)),
                        const SizedBox(height: Sp.lg),
                        Text('Sin resultados', style: AppText.h3.copyWith(color: AppColors.dorado)),
                        Text('Prueba con otros términos', style: AppText.body.copyWith(color: Colors.white54)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(top: Sp.md, bottom: 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final c = filtradas[i];
                        return StreamBuilder<Usuario?>(
                          stream: UsuarioService().miUsuario(),
                          builder: (context, uSnap) {
                            final favs = uSnap.data?.favoritos ?? [];
                            return ValueListenableBuilder<EstadoPlayer>(
                              valueListenable: PlayerService().estado,
                              builder: (context, estado, _) {
                                return TarjetaCancion(
                                  cancion: c,
                                  esFavorito: favs.contains(c.id),
                                  estado: estado,
                                  onTap: () => _abrir(c),
                                  onTogglePlay: () => _togglePlay(c),
                                  onToggleFavorito: () => UsuarioService().toggleFavorito(c.id),
                                );
                              },
                            );
                          },
                        );
                      },
                      childCount: filtradas.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}