// lib/features/inicio/screens/inicio_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

import '../../../models/evento.dart';
import '../../../services/novedades_service.dart';

import '../../../widgets/banner_novedades.dart';
import '../../../widgets/inicio/hero_inicio.dart';
import '../../../widgets/inicio/proximo_evento_card.dart';
import '../../../widgets/inicio/tarjeta_historia.dart';
import '../../../widgets/inicio/ultimas_canciones.dart';
import '../../../widgets/inicio/ultimo_recuerdo.dart';
import '../../../widgets/social_buttons.dart';

import '../../busqueda/screens/busqueda_global_screen.dart';
import '../../../screens/compartir_app_screen.dart';
import '../../zampona/screens/zampona_screen.dart';
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
  }

  void _abrirDiscord() async {
    try {
      await launchUrl(
        Uri.parse('https://discord.gg/ojailbreaks'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.dorado,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 1. HERO
            SliverToBoxAdapter(
              child: HeroInicio(
                nombreUsuario: widget.nombreUsuario,
                onBuscar: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BusquedaGlobalScreen(),
                  ),
                ),
                onZampona: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ZamponaScreen(),
                  ),
                ),
              ),
            ),

            // 2. BANNER DE NOVEDADES
            if (_eventoNuevo != null && !_bannerCerrado)
              SliverToBoxAdapter(
                child: BannerNovedades(
                  icono: Icons.celebration,
                  titulo: 'Nuevo evento: ${_eventoNuevo!.titulo}',
                  subtitulo:
                      '${_eventoNuevo!.fecha.day}/${_eventoNuevo!.fecha.month} · ${_eventoNuevo!.lugar}',
                  onTap: () => setState(() => _bannerCerrado = true),
                  onCerrar: () => setState(() => _bannerCerrado = true),
                ),
              ),

            // 3. CHIP HOY
            const SliverToBoxAdapter(child: _SeccionHoy()),

            // 4. PRÓXIMO EVENTO — destacado full-width
            const SliverToBoxAdapter(child: ProximoEventoCard()),

            const SliverToBoxAdapter(child: SizedBox(height: Sp.md)),

            // 5. BENTO — 2 acciones rápidas
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _BentoActionCard(
                        icon: Icons.qr_code_2,
                        titulo: 'Compartir',
                        subtitulo: 'Invita al grupo',
                        gradient: AppColors.gradienteDorado,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompartirAppScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Sp.md),
                    Expanded(
                      child: _BentoActionCard(
                        icon: Icons.forum,
                        titulo: 'Comunidad',
                        subtitulo: 'Únete al Discord',
                        gradient: AppColors.gradienteGranate,
                        onTap: _abrirDiscord,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 6. ÚLTIMAS CANCIONES
            const SliverToBoxAdapter(child: SizedBox(height: Sp.xl)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Sp.lg),
                child: _SeccionHeaderBento(
                  icon: Icons.library_music,
                  titulo: 'ÚLTIMAS CANCIONES',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Sp.sm)),
            const SliverToBoxAdapter(child: UltimasCanciones()),

            // 7. ÚLTIMO RECUERDO
            const SliverToBoxAdapter(child: SizedBox(height: Sp.xl)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Sp.lg),
                child: _SeccionHeaderBento(
                  icon: Icons.photo_library,
                  titulo: 'ÚLTIMO RECUERDO',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Sp.sm)),
            const SliverToBoxAdapter(child: UltimoRecuerdo()),

            // 8. HISTORIA
            const SliverToBoxAdapter(child: SizedBox(height: Sp.xl)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Sp.lg),
                child: _SeccionHeaderBento(
                  icon: Icons.auto_stories,
                  titulo: 'NUESTRA HISTORIA',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Sp.sm)),
            const SliverToBoxAdapter(child: TarjetaHistoria()),

            // 9. SOCIAL
            const SliverToBoxAdapter(child: SizedBox(height: Sp.xxl)),
            const SliverToBoxAdapter(child: Divider()),
            const SliverToBoxAdapter(child: SocialButtons()),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CHIP HOY — fecha del día con acento dorado
// ═══════════════════════════════════════════════════════════

class _SeccionHoy extends StatelessWidget {
  const _SeccionHoy();

  static const _meses = [
    '', 'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
    'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
  ];

  static const _dias = [
    '', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES',
    'VIERNES', 'SÁBADO', 'DOMINGO',
  ];

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, Sp.sm),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppColors.gradienteDorado,
              borderRadius: Rad.rPill,
            ),
          ),
          const SizedBox(width: Sp.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOY',
                style: AppText.label.copyWith(
                  color: AppColors.dorado,
                  letterSpacing: 2.5,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_dias[ahora.weekday]} ${ahora.day} DE ${_meses[ahora.month]}',
                style: AppText.captionXs.copyWith(
                  color: AppColors.dorado.withOpacity(0.5),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HEADER DE SECCIÓN BENTO
// ═══════════════════════════════════════════════════════════

class _SeccionHeaderBento extends StatelessWidget {
  final IconData icon;
  final String titulo;

  const _SeccionHeaderBento({
    required this.icon,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.granate.withOpacity(0.18),
            borderRadius: Rad.rSm,
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.2),
            ),
          ),
          child: Icon(icon, color: AppColors.dorado, size: 14),
        ),
        const SizedBox(width: Sp.sm),
        Text(
          titulo,
          style: AppText.label.copyWith(
            color: AppColors.dorado,
            letterSpacing: 1.5,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CELDA BENTO — con spring physics y gradiente
// ═══════════════════════════════════════════════════════════

class _BentoActionCard extends StatefulWidget {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final Gradient gradient;
  final VoidCallback onTap;

  const _BentoActionCard({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_BentoActionCard> createState() => _BentoActionCardState();
}

class _BentoActionCardState extends State<_BentoActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        AppMotion.hapticLight();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Container(
          height: 130,
          padding: const EdgeInsets.all(Sp.md),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: Rad.rLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(Sp.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.dorado,
                  size: 20,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titulo,
                    style: AppText.title.copyWith(
                      color: AppColors.dorado,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitulo,
                    style: AppText.captionXs.copyWith(
                      color: AppColors.dorado.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}