// lib/features/busqueda/screens/busqueda_global_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/components/allin_input.dart';
import '../../../core/components/allin_loading_siku.dart';
import '../../../core/components/app_card.dart';
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

enum FiltroBusqueda { todos, canciones, eventos, recuerdos }

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
  FiltroBusqueda _filtro = FiltroBusqueda.todos;

  List<Cancion> _canciones = [];
  List<Evento> _eventos = [];
  List<Recuerdo> _recuerdos = [];
  bool _cargando = true;

  final List<String> _sugerencias = const [
    'Diana',
    'Candelaria',
    'Huayno',
    'Ensayo',
    'Carnaval',
    'Zampoña',
    'Aniversario',
  ];

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
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = v.trim().toLowerCase());
    });
  }

  void _aplicarSugerencia(String s) {
    _ctrl.text = s;
    setState(() => _query = s.toLowerCase());
  }

  List<Cancion> get _cancionesFiltradas {
    if (_query.isEmpty) return [];
    if (_filtro == FiltroBusqueda.eventos || _filtro == FiltroBusqueda.recuerdos) {
      return [];
    }
    return _canciones.where((c) =>
        c.titulo.toLowerCase().contains(_query) ||
        c.autor.toLowerCase().contains(_query) ||
        c.ritmo.toLowerCase().contains(_query)).toList();
  }

  List<Evento> get _eventosFiltrados {
    if (_query.isEmpty) return [];
    if (_filtro == FiltroBusqueda.canciones || _filtro == FiltroBusqueda.recuerdos) {
      return [];
    }
    return _eventos.where((e) =>
        e.titulo.toLowerCase().contains(_query) ||
        e.lugar.toLowerCase().contains(_query)).toList();
  }

  List<Recuerdo> get _recuerdosFiltrados {
    if (_query.isEmpty) return [];
    if (_filtro == FiltroBusqueda.canciones || _filtro == FiltroBusqueda.eventos) {
      return [];
    }
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.dorado,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Búsqueda Global',
          style: AppText.h3.copyWith(
            color: AppColors.dorado,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // ─── BARRA DE BÚSQUEDA ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.sm),
            child: AllinInput(
              controller: _ctrl,
              focusNode: _focus,
              label: 'Buscar en todo Allin Kawsay',
              hint: 'Canción, autor, evento, recuerdo...',
              prefixIcon: Icons.search_rounded,
              onChanged: _onChanged,
              suffix: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: AppColors.dorado,
                        size: 20,
                      ),
                      onPressed: () {
                        _ctrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),

          // ─── CHIPS DE FILTRO CATEGORÍA ───
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('Todos', FiltroBusqueda.todos, Icons.all_inclusive_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('Canciones', FiltroBusqueda.canciones, Icons.music_note_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('Eventos', FiltroBusqueda.eventos, Icons.event_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('Recuerdos', FiltroBusqueda.recuerdos, Icons.photo_library_rounded),
              ],
            ),
          ),

          const SizedBox(height: Sp.xs),

          // ─── CONTENIDO ───
          Expanded(
            child: _cargando
                ? const Center(
                    child: AllinLoadingSiku(mensaje: 'Indexando repertorio...'),
                  )
                : _query.isEmpty
                    ? _estadoInicial()
                    : _resultados(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, FiltroBusqueda filtro, IconData icon) {
    final activo = _filtro == filtro;
    return GestureDetector(
      onTap: () {
        AppMotion.hapticLight();
        setState(() => _filtro = filtro);
      },
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: activo
              ? AppColors.dorado
              : AppColors.surfaceVariant(context).withOpacity(0.4),
          borderRadius: Rad.rRound,
          border: Border.all(
            color: activo
                ? AppColors.doradoBrillante
                : AppColors.border(context).withOpacity(0.4),
            width: activo ? 1.5 : 1,
          ),
          boxShadow: activo
              ? [
                  BoxShadow(
                    color: AppColors.dorado.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: activo ? AppColors.fondoOscuro : AppColors.onSurfaceVariant(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppText.caption.copyWith(
                color: activo ? AppColors.fondoOscuro : AppColors.onSurface(context),
                fontWeight: activo ? FontWeight.w800 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoInicial() {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Sp.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.granateProfundo,
                    AppColors.fondoOscuro,
                  ],
                ),
                border: Border.all(
                  color: AppColors.dorado.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dorado.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 40,
                color: AppColors.dorado,
              ),
            ),
            const SizedBox(height: Sp.lg),
            Text(
              'Encuentra en la Hermandad',
              textAlign: TextAlign.center,
              style: AppText.h3.copyWith(color: AppColors.dorado),
            ),
            const SizedBox(height: Sp.xs),
            Text(
              'Partituras, fechas de presentaciones,\nensayos y archivos multimedia.',
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(
                color: AppColors.onSurfaceVariant(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: Sp.xl),

            // Chips de sugerencia rápida
            Text(
              'SUGERENCIAS POPULARES',
              style: AppText.caption.copyWith(
                color: AppColors.dorado.withOpacity(0.8),
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: Sp.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _sugerencias.map((s) {
                return GestureDetector(
                  onTap: () {
                    AppMotion.hapticLight();
                    _aplicarSugerencia(s);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.granateOscuro.withOpacity(0.4),
                      borderRadius: Rad.rRound,
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 13,
                          color: AppColors.dorado,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          s,
                          style: AppText.caption.copyWith(
                            color: AppColors.dorado,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
                Icons.search_off_rounded,
                size: 60,
                color: AppColors.dorado.withOpacity(0.35),
              ),
              const SizedBox(height: Sp.md),
              Text(
                'Sin resultados',
                style: AppText.h3.copyWith(color: AppColors.dorado),
              ),
              const SizedBox(height: Sp.xs),
              Text(
                'No encontramos coincidencias para "$_query".',
                textAlign: TextAlign.center,
                style: AppText.caption.copyWith(
                  color: AppColors.onSurfaceVariant(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.sm),
      children: [
        if (c.isNotEmpty) ...[
          _seccionHeader('CANCIONES & NUMEROFONÍA', Icons.library_music_rounded, c.length),
          const SizedBox(height: Sp.sm),
          ...c.map((item) => _ResultadoCard(
                icon: Icons.music_note_rounded,
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
          _seccionHeader('EVENTOS & ENSAYOS', Icons.event_rounded, e.length),
          const SizedBox(height: Sp.sm),
          ...e.map((item) => _ResultadoCard(
                icon: Icons.calendar_month_rounded,
                title: item.titulo,
                subtitle:
                    '${item.fecha.day}/${item.fecha.month} · ${item.lugar.isEmpty ? 'Sin lugar especificado' : item.lugar}',
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
          _seccionHeader('RECUERDOS & MULTIMEDIA', Icons.photo_library_rounded, r.length),
          const SizedBox(height: Sp.sm),
          ...r.map((item) => _ResultadoCard(
                icon: Icons.photo_camera_rounded,
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
        const SizedBox(height: 60),
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
            letterSpacing: 1.2,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: Sp.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.granateProfundo,
            borderRadius: Rad.rPill,
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.3),
            ),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              fontFamily: 'monospace',
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
          scale: _isPressed ? 0.98 : 1.0,
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
                    gradient: const LinearGradient(
                      colors: [AppColors.granateProfundo, AppColors.granateOscuro],
                    ),
                    borderRadius: Rad.rMd,
                    border: Border.all(
                      color: AppColors.dorado.withOpacity(0.25),
                    ),
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
                        style: AppText.subtitle.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: AppText.caption.copyWith(
                          color: AppColors.onSurfaceVariant(context),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.dorado.withOpacity(0.5),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
