// lib/screens/recuerdos_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/recuerdo.dart';
import '../models/usuario.dart';
import '../services/recuerdo_service.dart';
import '../services/usuario_service.dart';
import '../widgets/recuerdos/recuerdo_card.dart';
import 'agregar_recuerdo_screen.dart';
import 'recuerdo_detalle_screen.dart';

class RecuerdosScreen extends StatefulWidget {
  const RecuerdosScreen({super.key});
  @override
  State<RecuerdosScreen> createState() => _RecuerdosScreenState();
}

class _RecuerdosScreenState extends State<RecuerdosScreen> {
  final _service = RecuerdoService();
  Usuario? _usuario;
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() { _usuario = u; _esAdmin = u?.esAdmin ?? false; });
  }

  Future<void> _eliminar(Recuerdo r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar recuerdo'),
        content: Text('¿Eliminar "${r.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) await _service.eliminar(r.id);
  }

  void _editar(Recuerdo r) => Navigator.push(context, MaterialPageRoute(builder: (_) => AgregarRecuerdoScreen(recuerdo: r)));

  void _verDetalle(Recuerdo r) => Navigator.push(context, MaterialPageRoute(builder: (_) => RecuerdoDetalleScreen(recuerdo: r)));

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Recuerdos',
      floatingActionButton: _esAdmin 
        ? Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgregarRecuerdoScreen())),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Nuevo'),
            ),
          )
        : null,
      body: StreamBuilder<List<Recuerdo>>(
        stream: _service.listar(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const AppSkeletonList(items: 3, featured: true);
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const AppEmptyState(icon: Icons.photo_library, title: 'Sin recuerdos aún', subtitle: 'Cuando subas fotos o videos, aparecerán aquí.');
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.lg, 120),
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final r = lista[i];
              return RecuerdoCard(
                recuerdo: r,
                esAdmin: _esAdmin,
                onTap: () => _verDetalle(r),
                onEditar: () => _editar(r),
                onEliminar: () => _eliminar(r),
              );
            },
          );
        },
      ),
    );
  }
}