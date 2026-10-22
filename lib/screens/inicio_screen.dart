// lib/screens/inicio_screen.dart — VERSIÓN REDISEÑADA
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../models/evento.dart';
import '../services/novedades_service.dart';
import '../widgets/banner_novedades.dart';
import '../widgets/inicio/hero_inicio.dart';
import '../widgets/inicio/proximo_evento.dart';
import '../widgets/inicio/tarjeta_historia.dart';
import '../widgets/inicio/ultimas_canciones.dart';
import '../widgets/inicio/ultimo_recuerdo.dart';
import '../widgets/social_buttons.dart';
import 'busqueda_global_screen.dart';
import 'zampona_screen.dart';

class InicioScreen extends StatefulWidget {
  final String nombreUsuario;
  const InicioScreen({super.key, required this.nombreUsuario});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  Evento? _eventoNuevo;
  bool _bannerCerrado = false;

  @override
  void initState() {
    super.initState();
    _cargarNovedades();
  }

  Future<void> _cargarNovedades() async {
    final evento = await NovedadesService.eventoNuevoNoVisto();
    if (!mounted) return;
    setState(() => _eventoNuevo = evento);
  }

  Future<void> _onRefresh() async {
    await _cargarNovedades();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      watermark: true,
      onRefresh: _onRefresh,
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          HeroInicio(
            nombreUsuario: widget.nombreUsuario,
            onBuscar: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const BusquedaGlobalScreen()),
            ),
            onZampona: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ZamponaScreen()),
            ),
          ),
          if (_eventoNuevo != null && !_bannerCerrado)
            BannerNovedades(
              icono: Icons.celebration,
              titulo: 'Nuevo evento: ${_eventoNuevo!.titulo}',
              subtitulo:
                  '${_eventoNuevo!.fecha.day}/${_eventoNuevo!.fecha.month}'
                  ' · ${_eventoNuevo!.lugar}',
              onTap: () => setState(() => _bannerCerrado = true),
              onCerrar: () =>
                  setState(() => _bannerCerrado = true),
            ),
          const SizedBox(height: Sp.lg),
          const SeccionHeader(
              title: 'Próximo evento',
              icon: Icons.event_available),
          const ProximoEventoCard(),
          const SizedBox(height: Sp.lg),
          const SeccionHeader(
              title: 'Últimas canciones',
              icon: Icons.library_music),
          const UltimasCanciones(),
          const SizedBox(height: Sp.lg),
          const SeccionHeader(
              title: 'Último recuerdo',
              icon: Icons.photo_library),
          const UltimoRecuerdo(),
          const SizedBox(height: Sp.lg),
          const SeccionHeader(
              title: 'Nuestra historia',
              icon: Icons.history_edu),
          const TarjetaHistoria(),
          const SizedBox(height: Sp.xxl),
          const Divider(),
          const SizedBox(height: Sp.sm),
          const SocialButtons(),
          const SizedBox(height: Sp.xxxl),
        ],
      ),
    );
  }
}