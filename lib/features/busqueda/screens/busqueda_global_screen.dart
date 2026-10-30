// lib/features/busqueda/screens/busqueda_global_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/components/app_card.dart';
import '../../../core/components/app_input.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

import '../../../models/cancion.dart';
import '../../../models/evento.dart';
import '../../../models/recuerdo.dart';

import '../../../services/cancion_service.dart';
import '../../../services/evento_service.dart';
import '../../../services/recuerdo_service.dart';

import '../../cancion_detalle/screens/cancion_detalle_screen.dart';
import '../../eventos/screens/evento_detalle_screen.dart';
import '../../recuerdos/screens/recuerdo_detalle_screen.dart';

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
      if (mounted) {
        setState(() {
          _canciones = c;
          _eventos = e;
          _recuerdos = r;
          _cargando = false;
        });
      }
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
    return _recuerdos
        .where((r) => r.titulo.toLowerCase().contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoOscuro,
        iconTheme: const IconThemeData(color: AppColors.dorado),
        title: Text(
          'Buscar',
          style: AppText.h3.copyWith(color: AppColors.dorado),
        ),
      ),
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
              suffix: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.granate,
                      ),
                      onPressed: () {
                        _ctrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.dorado,
                    ),
                  )
                : _query.isEmpty
                    ? _estadoInicial()
                    : _resultados(),
          ),
        ],
      ),
    );
  }

  Widget _estadoInicial() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sp.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.granate.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.search,
                size: 42,
                color: AppColors.dorado.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: Sp.lg),
            Text(
              'Escribe algo para buscar',
              textAlign: TextAlign.center,
              style: AppText.h3.copyWith(color: AppColors.dorado),
            ),
            const SizedBox(height: Sp.xs),
            Text(
              'Canciones, eventos y recuerdos\nen un solo lugar',
              textAlign: TextAlign.center,
              style: AppText.bodySm.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultados() {
    final c = _cancionesFiltradas;
    final e = _eventosFiltrados;
    final r = _recuerdosFiltrados;

    if (c.isEmpty && e.isEmpty && r.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.dorado.withOpacity(0.3),
              ),
              const SizedBox(height: Sp.lg),
              Text(
                'Sin resultados',
                style: AppText.h3.copyWith(color: AppColors.dorado),
              ),
              const SizedBox(height: Sp.xs),
              Text(
                'No se encontró nada para "$_query"',
                textAlign: TextAlign.center,
                style: AppText.bodySm.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      children: [
        if (c.isNotEmpty) ...[
          _seccionHeader('CANCIONES', Icons.library_music, c.length),
          const SizedBox(height: Sp.sm),
          ...c.map((item) => _ResultadoCard(
                icon: Icons.music_note,
                title: item.titulo,
                subtitle:
                    '${item.ritmo}${item.autor.isNotEmpty ? ' · ${item.autor}' : ''}',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CancionDetalleScreen(cancion: item),
                  ),
                ),
              )),
          const SizedBox(height: Sp.lg),
        ],
        if (e.isNotEmpty) ...[
          _seccionHeader('EVENTOS', Icons.event, e.length),
          const SizedBox(height: Sp.sm),
          ...e.map((item) => _ResultadoCard(
                icon: Icons.event,
                title: item.titulo,
                subtitle:
                    '${item.fecha.day}/${item.fecha.month} · ${item.lugar.isEmpty ? 'Sin lugar' : item.lugar}',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventoDetalleScreen(evento: item),
                  ),
                ),
              )),
          const SizedBox(height: Sp.lg),
        ],
        if (r.isNotEmpty) ...[
          _seccionHeader('RECUERDOS', Icons.photo_library, r.length),
          const SizedBox(height: Sp.sm),
          ...r.map((item) => _ResultadoCard(
                icon: Icons.photo_library,
                title: item.titulo,
                subtitle:
                    '${item.fotos.length} fotos${item.videos.isNotEmpty ? ' · ${item.videos.length} videos' : ''}',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecuerdoDetalleScreen(recuerdo: item),
                  ),
                ),
              )),
        ],
        const SizedBox(height: Sp.xxxl),
      ],
    );
  }

  Widget _seccionHeader(String titulo, IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, color: AppColors.dorado, size: 16),
        const SizedBox(width: Sp.sm),
        Text(
          titulo,
          style: AppText.label.copyWith(
            color: AppColors.dorado,
            letterSpacing: 1.5,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: Sp.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.2),
            borderRadius: Rad.rPill,
          ),
          child: Text(
            '$count',
            style: AppText.captionXs.copyWith(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultadoCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ResultadoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ResultadoCard> createState() => _ResultadoCardState();
}

class _ResultadoCardState extends State<_ResultadoCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          AppMotion.hapticLight();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.spring,
          child: AppCard(
            glass: true,
            padding: const EdgeInsets.all(Sp.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteGranate,
                    borderRadius: Rad.rMd,
                  ),
                  child: Icon(widget.icon, color: AppColors.dorado, size: 20),
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppText.subtitle.copyWith(color: onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: AppText.captionXs.copyWith(
                          color: onSurface.withOpacity(0.55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.dorado.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}