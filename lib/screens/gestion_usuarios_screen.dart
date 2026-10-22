// lib/screens/gestion_usuarios_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/admin/usuario_baneado_card.dart';
import '../widgets/admin/usuario_card.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = UsuarioService();
  bool _soyDev = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _service.soyDev().then((d) { if (mounted) setState(() => _soyDev = d); });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cambiarRol(Usuario u, String rol) async {
    if (u.rol == rol) return;
    await _service.cambiarRol(u.uid, rol);
  }

  Future<void> _banear(Usuario u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Suspender Usuario'),
        content: Text('¿Suspender a "${u.nombre}"? No podrá acceder a la app.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Suspender')),
        ],
      ),
    );
    if (ok == true) await _service.banear(u.uid);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Usuarios',
      subtitle: _soyDev ? 'Modo Desarrollador' : 'Gestión de Roles',
      bottomNavigationBar: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.dorado,
        labelColor: AppColors.dorado,
        unselectedLabelColor: AppColors.dorado.withOpacity(0.5),
        tabs: const [Tab(text: 'ACTIVOS'), Tab(text: 'SUSPENDIDOS')],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _lista(stream: _service.listar(), esBaneado: false),
          _lista(stream: _service.listarBaneados(), esBaneado: true),
        ],
      ),
    );
  }

  Widget _lista({required Stream<List<Usuario>> stream, required bool esBaneado}) {
    return StreamBuilder<List<Usuario>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const AppSkeletonList(items: 5);
        }
        final lista = snap.data ?? [];
        if (lista.isEmpty) {
          return AppEmptyState(
            icon: esBaneado ? Icons.check_circle_outline : Icons.people_outline,
            title: esBaneado ? 'Sin suspendidos' : 'Sin usuarios',
            subtitle: esBaneado ? 'Todos los usuarios están activos.' : 'No hay usuarios registrados aún.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(Sp.lg),
          itemCount: lista.length,
          itemBuilder: (context, i) {
            final u = lista[i];
            if (esBaneado) {
              return UsuarioBaneadoCard(
                usuario: u,
                onDesbanear: () => _service.desbanear(u.uid),
              );
            }
            return UsuarioCard(
              usuario: u,
              soyDev: _soyDev,
              onCambiarRol: (rol) => _cambiarRol(u, rol),
              onBanear: () => _banear(u),
            );
          },
        );
      },
    );
  }
}