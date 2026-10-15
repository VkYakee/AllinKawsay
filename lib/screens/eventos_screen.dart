import 'package:flutter/material.dart';
import '../models/evento.dart';
import '../models/usuario.dart';
import '../services/evento_service.dart';
import '../services/novedades_service.dart';
import '../services/usuario_service.dart';
import '../theme/colors.dart';
import '../widgets/comunes/empty_state.dart';
import '../widgets/comunes/error_state.dart';
import '../widgets/watermark_overlay.dart';
import 'agregar_evento_screen.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final _service = EventoService();
  bool _esAdmin = false;
  Usuario? _usuario;
  bool _bannerVisible = false;
  int _eventosNuevosAlEntrar = 0;

  @override
  void initState() {
    super.initState();
    _chequearAdmin();
    _cargarUsuario();
    _marcarComoVisto();
  }

  Future<void> _marcarComoVisto() async {
    // Contamos cuántos nuevos hay antes de marcarlos como vistos,
    // así podemos mostrar el banner "X nuevos" al entrar.
    final count = await NovedadesService.contarEventosNuevos();
    if (!mounted) return;
    if (count > 0) {
      setState(() {
        _eventosNuevosAlEntrar = count;
        _bannerVisible = true;
      });
      // Auto-ocultar a los 5 segundos
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _bannerVisible = false);
      });
    }
    await NovedadesService.marcarEventosVistos();
  }

  Future<void> _chequearAdmin() async {
    final a = await UsuarioService().soyAdmin();
    if (mounted) setState(() => _esAdmin = a);
  }

  Future<void> _cargarUsuario() async {
    final u = await UsuarioService().miUsuarioActual();
    if (mounted) setState(() => _usuario = u);
  }

  Future<void> _onRefresh() async {
    await _chequearAdmin();
    await _cargarUsuario();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _eliminar(Evento e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar evento',
            style: TextStyle(
                color: AppColors.granate, fontWeight: FontWeight.bold)),
        content: Text(
            '¿Eliminar "${e.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.eliminar(e.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Evento "${e.titulo}" eliminado')),
        );
      }
    }
  }

  void _editar(Evento e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgregarEventoScreen(evento: e)),
    );
  }

  Future<void> _editarNota(Evento e) async {
    final ctrl = TextEditingController(
      text: _usuario?.notaEvento(e.id) ?? '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Nota: ${e.titulo}'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: llevar tal instrumento, ir a tal hora...',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await UsuarioService().guardarNotaEvento(e.id, ctrl.text);
      await _cargarUsuario();
    }
  }
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _esAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AgregarEventoScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('NUEVO'),
            )
          : null,
      body: WatermarkOverlay(
        opacity: 0.04,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.dorado,
          child: StreamBuilder<List<Evento>>(
            stream: _service.listar(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData) {
                return const _LoadingSkeleton();
              }
              if (snap.hasError) {
                return ErrorState(
                  titulo: 'Error al cargar eventos',
                  detalle: snap.error.toString(),
                  onRetry: () => setState(() {}),
                );
              }
              final lista = snap.data ?? [];
              if (lista.isEmpty) {
                return EmptyState(
                  icono: Icons.event_busy,
                  titulo: 'Sin eventos',
                  subtitulo: _esAdmin
                      ? 'Toca el botón NUEVO para agregar el primero'
                      : 'El admin aún no ha publicado eventos',
                );
              }

              return Column(
                children: [
                  // Banner de eventos nuevos
                  if (_bannerVisible && _eventosNuevosAlEntrar > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.dorado.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color:
                                  AppColors.dorado.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.celebration,
                                color: AppColors.granate, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$_eventosNuevosAlEntrar evento(s) nuevo(s) '
                                'desde tu última visita',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.granate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: lista.length,
                      itemBuilder: (context, i) {
                        final e = lista[i];
                        final pasado = e.fecha.isBefore(DateTime.now());
                        final nota = _usuario?.notaEvento(e.id) ?? '';
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration:
                              Duration(milliseconds: 300 + (i * 50)),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: _tarjetaEvento(
                              context, e, pasado, nota, onSurface),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('PRÓXIMOS EVENTOS',
              style: TextStyle(letterSpacing: 1.5, fontSize: 16)),
          const SizedBox(width: 8),
          StreamBuilder<List<Evento>>(
            stream: _service.listar(),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dorado.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${snap.data!.length}',
                  style: const TextStyle(
                    color: AppColors.dorado,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tarjetaEvento(BuildContext context, Evento e, bool pasado,
      String nota, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: pasado
                ? onSurface.withOpacity(0.15)
                : AppColors.dorado.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(pasado ? 0.02 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: pasado
                          ? const LinearGradient(colors: [
                              Color(0xFF424242),
                              Color(0xFF212121)
                            ])
                          : AppColors.gradienteGranate,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (pasado
                                  ? Colors.black
                                  : AppColors.granate)
                              .withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${e.fecha.day}',
                          style: const TextStyle(
                            color: AppColors.dorado,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _mes(e.fecha.month),
                          style: TextStyle(
                            color: AppColors.dorado.withOpacity(0.9),
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.titulo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                            fontSize: 16,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 12,
                                color: onSurface.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text(_hora(e.fecha),
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        onSurface.withOpacity(0.65))),
                            if (e.lugar.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Icon(Icons.place,
                                  size: 12,
                                  color: onSurface.withOpacity(0.5)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  e.lugar,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          onSurface.withOpacity(0.65)),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (e.descripcion.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            e.descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12,
                                color: onSurface.withOpacity(0.55),
                                height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: AppColors.dorado.withOpacity(0.15)),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _editarNota(e),
                    icon: Icon(
                      nota.isEmpty
                          ? Icons.sticky_note_2_outlined
                          : Icons.sticky_note_2,
                      size: 16,
                      color: nota.isEmpty
                          ? onSurface.withOpacity(0.4)
                          : AppColors.dorado,
                    ),
                    label: Text(
                      nota.isEmpty ? 'Nota' : 'Mi nota',
                      style: TextStyle(
                        fontSize: 12,
                        color: nota.isEmpty
                            ? onSurface.withOpacity(0.5)
                            : AppColors.granate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_esAdmin)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert,
                          color: onSurface.withOpacity(0.5), size: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onSelected: (v) {
                        if (v == 'editar') {
                          _editar(e);
                        } else if (v == 'eliminar') {
                          _eliminar(e);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit,
                                  size: 20, color: AppColors.granate),
                              SizedBox(width: 10),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 20, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (nota.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.dorado.withOpacity(0.12),
                    AppColors.dorado.withOpacity(0.06),
                  ]),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.dorado.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sticky_note_2,
                        size: 14, color: AppColors.granate),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        nota,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: onSurface.withOpacity(0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _mes(int m) {
    const meses = [
      '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return meses[m];
  }

  String _hora(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 160,
                            height: 18,
                            color: Colors.grey.withOpacity(0.1)),
                        const SizedBox(height: 8),
                        Container(
                            width: 120,
                            height: 14,
                            color: Colors.grey.withOpacity(0.1)),
                        const SizedBox(height: 8),
                        Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.grey.withOpacity(0.1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}