// lib/features/eventos/screens/eventos_screen.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/evento.dart';
import '../../../models/usuario.dart';
import '../../../services/evento_service.dart';
import '../../../services/usuario_service.dart';
// Pantallas viejas de edición (se migrarán después)
import '../../../screens/agregar_evento_screen.dart';
import '../widgets/evento_card.dart';
import 'evento_detalle_screen.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final _service = EventoService();
  Usuario? _usuario;
  bool _esAdmin = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) {
      setState(() {
        _usuario = u;
        _esAdmin = u?.esAdmin ?? false;
      });
    }
  }

  void _editar(Evento e) => Navigator.push(context, MaterialPageRoute(builder: (_) => AgregarEventoScreen(evento: e)));

  void _eliminar(Evento e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text('¿Eliminar "${e.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) await _service.eliminar(e.id);
  }

  Future<void> _editarNota(Evento e) async {
    final ctrl = TextEditingController(text: _usuario?.notaEvento(e.id) ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nota personal'),
        content: TextField(controller: ctrl, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true) {
      await UsuarioService().guardarNotaEvento(e.id, ctrl.text);
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      floatingActionButton: _esAdmin
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton.extended(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgregarEventoScreen())),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo'),
                backgroundColor: AppColors.granate,
                foregroundColor: AppColors.dorado,
              ),
            )
          : null,
      body: StreamBuilder<List<Evento>>(
        stream: _service.listar(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.dorado));
          }
          final lista = snap.data ?? [];
          
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.fondoOscuro,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Eventos', style: AppText.h2.copyWith(color: AppColors.dorado)),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: Sp.xxl, bottom: Sp.lg),
                ),
              ),
              
              if (lista.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: AppColors.dorado.withOpacity(0.3)),
                        const SizedBox(height: Sp.lg),
                        Text('Sin eventos', style: AppText.h3.copyWith(color: AppColors.dorado)),
                        Text('Aún no hay eventos programados.', style: AppText.body.copyWith(color: Colors.white54)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.lg, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final e = lista[i];
                        return EventoCard(
                          evento: e,
                          esPasado: e.fecha.isBefore(DateTime.now()),
                          nota: _usuario?.notaEvento(e.id) ?? '',
                          esAdmin: _esAdmin,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventoDetalleScreen(evento: e))),
                          onEditarNota: () => _editarNota(e),
                          onEditar: () => _editar(e),
                          onEliminar: () => _eliminar(e),
                        );
                      },
                      childCount: lista.length,
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