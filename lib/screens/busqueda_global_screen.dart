// lib/screens/busqueda_global_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/cancion.dart';
import '../models/evento.dart';
import '../models/recuerdo.dart';
import '../services/cancion_service.dart';
import '../services/evento_service.dart';
import '../services/recuerdo_service.dart';
import '../theme/colors.dart';
import '../widgets/busqueda/busqueda_resultado_card.dart';
import 'cancion_detalle_screen.dart';
import 'recuerdo_detalle_screen.dart';

class BusquedaGlobalScreen extends StatefulWidget {
  const BusquedaGlobalScreen({super.key});

  @override
  State<BusquedaGlobalScreen> createState() => _BusquedaGlobalScreenState();
}

class _BusquedaGlobalScreenState extends State<BusquedaGlobalScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';
  Timer? _debounce;

  List<Cancion> _canciones = [];
  List<Evento> _eventos = [];
  List<Recuerdo> _recuerdos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  Future<void> _cargar() async {
    try {
      final c = await CancionService().listar().first;
      final e = await EventoService().listar().first;
      final r = await RecuerdoService().listar().first;
      if (mounted) setState(() { _canciones = c; _eventos = e; _recuerdos = r; _cargando = false; });
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = v.trim().toLowerCase());
    });
  }

  List<Cancion> get _cancionesFiltradas {
    if (_query.isEmpty) return [];
    return _canciones.where((c) =>
        c.titulo.toLowerCase().contains(_query) ||
        c.autor.toLowerCase().contains(_query) ||
        c.ritmo.toLowerCase().contains(_query)).toList();
  }

  List<Evento> get _eventosFiltrados {
    if (_query.isEmpty) return [];
    return _eventos.where((e) =>
        e.titulo.toLowerCase().contains(_query) ||
        e.lugar.toLowerCase().contains(_query)).toList();
  }

  List<Recuerdo> get _recuerdosFiltrados {
    if (_query.isEmpty) return [];
    return _recuerdos.where((r) => r.titulo.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Buscar',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Sp.lg),
            child: AppInput(
              controller: _ctrl,
              focusNode: _focus,
              label: 'Buscar',
              hint: 'Canciones, eventos, recuerdos...',
              prefixIcon: Icons.search,
              onChanged: _onChanged,
              suffix: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () { _ctrl.clear(); setState(() => _query = ''); },
                    )
                  : null,
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator(color: AppColors.granate))
                : _query.isEmpty
                    ? const AppEmptyState(icon: Icons.search, title: 'Escribe algo para buscar', subtitle: 'Encuentra tus canciones, eventos y recuerdos favoritos.')
                    : _resultados(),
          ),
        ],
      ),
    );
  }

  Widget _resultados() {
    final c = _cancionesFiltradas;
    final e = _eventosFiltrados;
    final r = _recuerdosFiltrados;

    if (c.isEmpty && e.isEmpty && r.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off,
        title: 'Sin resultados',
        subtitle: 'No se encontró nada para "$_query".',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      children: [
        if (c.isNotEmpty) ...[
          const SeccionHeader(title: 'Canciones', icon: Icons.library_music, padding: EdgeInsets.zero),
          const SizedBox(height: Sp.sm),
          ...c.map((item) => BusquedaResultadoCard(
                icon: Icons.music_note,
                title: item.titulo,
                subtitle: '${item.ritmo} · ${item.autor}',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CancionDetalleScreen(cancion: item))),
              )),
          const SizedBox(height: Sp.lg),
        ],
        if (e.isNotEmpty) ...[
          const SeccionHeader(title: 'Eventos', icon: Icons.event, padding: EdgeInsets.zero),
          const SizedBox(height: Sp.sm),
          ...e.map((item) => BusquedaResultadoCard(
                icon: Icons.event,
                title: item.titulo,
                subtitle: '${item.fecha.day}/${item.fecha.month} · ${item.lugar}',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Los eventos se ven desde la pestaña Eventos')));
                },
              )),
          const SizedBox(height: Sp.lg),
        ],
        if (r.isNotEmpty) ...[
          const SeccionHeader(title: 'Recuerdos', icon: Icons.photo_library, padding: EdgeInsets.zero),
          const SizedBox(height: Sp.sm),
          ...r.map((item) => BusquedaResultadoCard(
                icon: Icons.photo_library,
                title: item.titulo,
                subtitle: '${item.fotos.length} fotos',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecuerdoDetalleScreen(recuerdo: item))),
              )),
        ],
        const SizedBox(height: Sp.xxxl),
      ],
    );
  }
}