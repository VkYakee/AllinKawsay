// lib/screens/eventos_screen.dart
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/evento.dart';
import '../models/usuario.dart';
import '../services/evento_service.dart';
import '../services/novedades_service.dart';
import '../services/usuario_service.dart';
import '../widgets/eventos/evento_card.dart';
import '../widgets/eventos/eventos_banner.dart';
import 'agregar_evento_screen.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final _service = EventoService();
  Usuario? _usuario;
  bool _esAdmin = false;
  int _nuevos = 0;

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
    final count = await NovedadesService.contarEventosNuevos();
    if (mounted) setState(() => _nuevos = count);
    await NovedadesService.marcarEventosVistos();
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
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
      _init(); // Recargar usuario para actualizar nota
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Eventos',
      floatingActionButton: _esAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgregarEventoScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      body: StreamBuilder<List<Evento>>(
        stream: _service.listar(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
            return const AppSkeletonList(items: 4);
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const AppEmptyState(
              icon: Icons.event_busy,
              title: 'Sin eventos',
              subtitle: 'Aún no hay eventos programados.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.lg, 100),
            itemCount: lista.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return EventosBanner(nuevos: _nuevos);
              final e = lista[i - 1];
              return EventoCard(
                evento: e,
                esPasado: e.fecha.isBefore(DateTime.now()),
                nota: _usuario?.notaEvento(e.id) ?? '',
                esAdmin: _esAdmin,
                onEditarNota: () => _editarNota(e),
                onEditar: () => _editar(e),
                onEliminar: () => _eliminar(e),
              );
            },
          );
        },
      ),
    );
  }
}