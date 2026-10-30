// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/animated_list_item.dart';

import 'actividad_screen.dart';
import 'estadisticas_admin_screen.dart';
import 'exportar_respaldo_screen.dart';
import 'gestion_actualizaciones_screen.dart';
import 'gestion_categorias_screen.dart';
import 'gestion_usuarios_screen.dart';
import 'notificaciones_admin_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final bool isDev;
  const AdminDashboardScreen({super.key, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.fondoOscuro,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.dorado,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
              title: Text(
                isDev ? 'Panel de Desarrollador' : 'Panel de Control',
                style: AppText.title.copyWith(
                  color: AppColors.dorado,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.granateOscuro,
                          AppColors.fondoOscuro,
                        ],
                      ),
                    ),
                  ),
                  if (isDev)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.cyanAccent.withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (isDev)
            SliverToBoxAdapter(
              child: AnimatedListItem(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Sp.lg,
                    Sp.md,
                    Sp.lg,
                    Sp.sm,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(Sp.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A2540).withOpacity(0.9),
                      borderRadius: Rad.rMd,
                      border: Border.all(
                        color: Colors.cyanAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.code,
                          color: Colors.cyanAccent,
                          size: 24,
                        ),
                        const SizedBox(width: Sp.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DEV MODE ACTIVO',
                                style: AppText.label.copyWith(
                                  color: Colors.cyanAccent,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Acceso a prereleases y gestión de admins',
                                style: AppText.captionXs.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          _seccion(
            context,
            'RESUMEN',
            Icons.insights,
            startIndex: isDev ? 1 : 0,
            items: [
              _OpcionData(
                icon: Icons.insights,
                title: 'Estadísticas del grupo',
                subtitle: 'Métricas, top canciones y usuarios',
                onTap: () =>
                    _nav(context, const EstadisticasAdminScreen()),
              ),
            ],
          ),

          _seccion(
            context,
            'COMUNICACIÓN',
            Icons.campaign,
            startIndex: isDev ? 3 : 2,
            items: [
              _OpcionData(
                icon: Icons.notifications,
                title: 'Notificaciones',
                subtitle: 'Enviar avisos al grupo',
                onTap: () =>
                    _nav(context, const NotificacionesAdminScreen()),
              ),
              _OpcionData(
                icon: Icons.system_update,
                title: 'Actualizaciones',
                subtitle: isDev
                    ? 'Ver releases y prereleases'
                    : 'Aprobar versiones',
                onTap: () =>
                    _nav(context, const GestionActualizacionesScreen()),
              ),
            ],
          ),

          _seccion(
            context,
            'GESTIÓN DE CONTENIDO',
            Icons.settings,
            startIndex: isDev ? 5 : 4,
            items: [
              _OpcionData(
                icon: Icons.people,
                title: 'Usuarios y Roles',
                subtitle: 'Gestionar miembros y administradores',
                onTap: () => _nav(context, const GestionUsuariosScreen()),
              ),
              _OpcionData(
                icon: Icons.category,
                title: 'Categorías',
                subtitle: 'Organizar el cancionero',
                onTap: () => _nav(context, const GestionCategoriasScreen()),
              ),
              _OpcionData(
                icon: Icons.history,
                title: 'Historial de Actividad',
                subtitle: 'Ver quién hizo qué en el grupo',
                onTap: () => _nav(context, const ActividadScreen()),
              ),
              _OpcionData(
                icon: Icons.backup,
                title: 'Exportar respaldo',
                subtitle: 'Descargar base de datos en JSON',
                onTap: () => _nav(context, const ExportarRespaldoScreen()),
              ),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: Sp.xxxl)),
        ],
      ),
    );
  }

  Widget _seccion(
    BuildContext context,
    String titulo,
    IconData icon, {
    required int startIndex,
    required List<_OpcionData> items,
  }) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.xl, Sp.lg, Sp.sm),
          child: Row(
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
          ),
        ),
        ...List.generate(items.length, (i) {
          return AnimatedListItem(
            index: startIndex + i,
            baseDelay: const Duration(milliseconds: 80),
            child: _OpcionCard(data: items[i]),
          );
        }),
      ]),
    );
  }

  void _nav(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _OpcionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OpcionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _OpcionCard extends StatefulWidget {
  final _OpcionData data;
  const _OpcionCard({required this.data});

  @override
  State<_OpcionCard> createState() => _OpcionCardState();
}

class _OpcionCardState extends State<_OpcionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 4),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          AppMotion.hapticLight();
          widget.data.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.spring,
          child: Container(
            padding: const EdgeInsets.all(Sp.md),
            decoration: BoxDecoration(
              color: AppColors.surface(context).withOpacity(0.85),
              borderRadius: Rad.rLg,
              border: Border.all(
                color: AppColors.dorado.withOpacity(0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteGranate,
                    borderRadius: Rad.rMd,
                  ),
                  child: Icon(
                    widget.data.icon,
                    color: AppColors.dorado,
                    size: 20,
                  ),
                ),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.title,
                        style: AppText.subtitle.copyWith(color: onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.data.subtitle,
                        style: AppText.captionXs.copyWith(
                          color: onSurface.withOpacity(0.55),
                        ),
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