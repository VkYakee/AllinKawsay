// lib/features/perfil/screens/perfil_screen.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_card.dart';
import '../../../core/widgets/animated_list_item.dart';

import '../../../models/usuario.dart';
import '../../../services/auth_service.dart';
import '../../../services/cancion_service.dart';
import '../../../services/usuario_service.dart';

import '../../admin/screens/admin_dashboard_screen.dart';
import '../../compartir/screens/compartir_app_screen.dart';
import 'gestion_cache_screen.dart';

import '../../../widgets/perfil/modal_mis_subidas.dart';

import '../widgets/perfil_header.dart';
import '../widgets/perfil_menu_item.dart';

class PerfilScreen extends StatefulWidget {
  final String nombreUsuario;
  const PerfilScreen({super.key, required this.nombreUsuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: StreamBuilder<Usuario?>(
        stream: UsuarioService().miUsuario(),
        builder: (context, snap) {
          final u = snap.data;
          final esAdmin = u?.esAdmin ?? false;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Gradiente de fondo superior
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.granateOscuro.withOpacity(0.6),
                        AppColors.fondoOscuro,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: PerfilHeader(usuario: u),
                  ),
                ),
              ),

              // Stats
              if (u != null)
                SliverToBoxAdapter(
                  child: AnimatedListItem(
                    index: 0,
                    baseDelay: const Duration(milliseconds: 100),
                    child: _PerfilStats(usuario: u),
                  ),
                ),

              // Admin Banner
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 1,
                  baseDelay: const Duration(milliseconds: 150),
                  child: esAdmin
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sp.lg,
                            vertical: Sp.md,
                          ),
                          child: _AdminBanner(
                            esDev: u?.esDev ?? false,
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: AppMotion.normal,
                                pageBuilder: (_, __, ___) =>
                                    AdminDashboardScreen(
                                  isDev: u?.esDev ?? false,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              // Título "MI CUENTA"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Sp.xl,
                    Sp.lg,
                    Sp.xl,
                    Sp.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradienteDorado,
                          borderRadius: Rad.rPill,
                        ),
                      ),
                      const SizedBox(width: Sp.md),
                      Text(
                        'MI CUENTA',
                        style: AppText.label.copyWith(
                          color: AppColors.dorado,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Items del menú
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 2,
                  baseDelay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      PerfilMenuItem(
                        icono: Icons.upload_file,
                        titulo: 'Mis subidas',
                        subtitulo: 'Canciones y recuerdos que subiste',
                        onTap: () => u != null
                            ? ModalMisSubidas.mostrar(context, u.uid)
                            : null,
                      ),
                      PerfilMenuItem(
                        icono: Icons.qr_code_2,
                        titulo: 'Compartir app',
                        subtitulo: 'Mostrar QR o enviar enlace',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompartirAppScreen(),
                          ),
                        ),
                      ),
                      PerfilMenuItem(
                        icono: Icons.storage,
                        titulo: 'Almacenamiento',
                        subtitulo: 'Gestionar caché de audios y fotos',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GestionCacheScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: Sp.xl)),

              // Cerrar sesión
              SliverToBoxAdapter(
                child: AnimatedListItem(
                  index: 3,
                  baseDelay: const Duration(milliseconds: 250),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sp.lg,
                      vertical: Sp.md,
                    ),
                    child: _CerrarSesionButton(
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: Rad.rLg,
                            ),
                            backgroundColor: AppColors.surface(context),
                            title: Text(
                              'Cerrar sesión',
                              style: AppText.h3.copyWith(
                                color: AppColors.dorado,
                              ),
                            ),
                            content: Text(
                              '¿Seguro que quieres salir?',
                              style: AppText.body,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: Text(
                                  'Cancelar',
                                  style: AppText.subtitle.copyWith(
                                    color: AppColors.onSurfaceVariant(context),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                child: Text(
                                  'Salir',
                                  style: AppText.subtitle.copyWith(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await AuthService().logout();
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// STATS
// ═══════════════════════════════════════════════════════════

class _PerfilStats extends StatelessWidget {
  final Usuario usuario;
  const _PerfilStats({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      child: AppCard(
        glass: true,
        padding: const EdgeInsets.symmetric(vertical: Sp.lg, horizontal: Sp.md),
        child: Row(
          children: [
            Expanded(
              child: FutureBuilder<int>(
                future: CancionService().contarPorUsuario(
                  usuario.uid,
                  nombre: usuario.nombre,
                ),
                builder: (context, snap) => _StatTile(
                  icon: Icons.library_music,
                  value: '${snap.data ?? 0}',
                  label: 'Canciones',
                ),
              ),
            ),
            _divider(),
            Expanded(
              child: FutureBuilder<int>(
                future: CancionService().totalReproduccionesDeUsuario(
                  usuario.uid,
                  nombre: usuario.nombre,
                ),
                builder: (context, snap) => _StatTile(
                  icon: Icons.play_arrow_rounded,
                  value: '${snap.data ?? 0}',
                  label: 'Reproducciones',
                ),
              ),
            ),
            _divider(),
            Expanded(
              child: _StatTile(
                icon: Icons.favorite,
                value: '${usuario.favoritos.length}',
                label: 'Favoritos',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.dorado.withOpacity(0.15),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.dorado, size: 22),
        const SizedBox(height: Sp.xs),
        Text(
          value,
          style: AppText.h3.copyWith(
            color: Colors.white,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppText.captionXs.copyWith(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ADMIN BANNER
// ═══════════════════════════════════════════════════════════

class _AdminBanner extends StatefulWidget {
  final bool esDev;
  final VoidCallback onTap;

  const _AdminBanner({required this.esDev, required this.onTap});

  @override
  State<_AdminBanner> createState() => _AdminBannerState();
}

class _AdminBannerState extends State<_AdminBanner> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        AppMotion.hapticLight();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Container(
          padding: const EdgeInsets.all(Sp.lg),
          decoration: BoxDecoration(
            gradient: widget.esDev
                ? const LinearGradient(
                    colors: [Color(0xFF0A2540), Color(0xFF163B65)],
                  )
                : AppColors.gradienteGranate,
            borderRadius: Rad.rLg,
            border: Border.all(
              color: widget.esDev
                  ? Colors.cyanAccent.withOpacity(0.5)
                  : AppColors.dorado.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.esDev ? Colors.cyanAccent : AppColors.granate)
                    .withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Sp.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.esDev ? Icons.code : Icons.admin_panel_settings,
                  color: widget.esDev ? Colors.cyanAccent : AppColors.dorado,
                  size: 28,
                ),
              ),
              const SizedBox(width: Sp.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.esDev
                          ? 'Panel de Desarrollador'
                          : 'Panel de Administración',
                      style: AppText.title.copyWith(
                        color: widget.esDev ? Colors.cyanAccent : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Métricas y gestión del grupo',
                      style: AppText.captionXs.copyWith(
                        color: widget.esDev ? Colors.cyanAccent.withOpacity(0.7) : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: widget.esDev ? Colors.cyanAccent : AppColors.dorado,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CERRAR SESIÓN
// ═══════════════════════════════════════════════════════════

class _CerrarSesionButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CerrarSesionButton({required this.onTap});

  @override
  State<_CerrarSesionButton> createState() => _CerrarSesionButtonState();
}

class _CerrarSesionButtonState extends State<_CerrarSesionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        AppMotion.hapticHeavy();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: Rad.rMd,
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: Colors.redAccent, size: 20),
              const SizedBox(width: Sp.sm),
              Text(
                'CERRAR SESIÓN',
                style: AppText.label.copyWith(
                  color: Colors.redAccent,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}