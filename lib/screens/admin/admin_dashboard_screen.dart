// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';
import '../actividad_screen.dart';
import '../estadisticas_admin_screen.dart';
import '../exportar_respaldo_screen.dart';
import '../gestion_actualizaciones_screen.dart';
import '../gestion_categorias_screen.dart';
import '../gestion_usuarios_screen.dart';
import '../notificaciones_admin_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final bool isDev;
  const AdminDashboardScreen({super.key, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: isDev ? 'Panel de Desarrollador' : 'Panel de Control',
      subtitle: 'Gestión del grupo',
      body: ListView(
        padding: const EdgeInsets.all(Sp.lg),
        children: [
          if (isDev) ...[
            Container(
              padding: const EdgeInsets.all(Sp.lg),
              margin: const EdgeInsets.only(bottom: Sp.lg),
              decoration: BoxDecoration(
                color: const Color(0xFF0A2540),
                borderRadius: Rad.rLg,
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.code, color: Colors.cyanAccent, size: 28),
                  const SizedBox(width: Sp.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEV MODE ACTIVO',
                          style: AppType.label.copyWith(
                            color: Colors.cyanAccent,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Acceso a prereleases y gestión de admins',
                          style: AppType.captionXs.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          _OpcionLista(
            icon: Icons.insights,
            title: 'Estadísticas del grupo',
            subtitle: 'Métricas, top canciones y usuarios',
            onTap: () => _nav(context, const EstadisticasAdminScreen()),
          ),
          const SizedBox(height: Sp.lg),
          const SeccionHeader(
              title: 'Comunicación',
              icon: Icons.campaign,
              padding: EdgeInsets.zero),
          const SizedBox(height: Sp.sm),
          _OpcionLista(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Enviar avisos al grupo',
            onTap: () => _nav(context, const NotificacionesAdminScreen()),
          ),
          _OpcionLista(
            icon: Icons.system_update,
            title: isDev ? 'Actualizaciones (Todos los builds)' : 'Actualizaciones',
            subtitle: isDev
                ? 'Ver releases oficiales y prereleases'
                : 'Aprobar versiones de la app',
            onTap: () => _nav(context, const GestionActualizacionesScreen()),
          ),
          const SizedBox(height: Sp.lg),
          const SeccionHeader(
              title: 'Gestión',
              icon: Icons.settings,
              padding: EdgeInsets.zero),
          const SizedBox(height: Sp.sm),
          _OpcionLista(
            icon: Icons.people,
            title: 'Usuarios y Roles',
            subtitle: 'Gestionar miembros y administradores',
            onTap: () => _nav(context, const GestionUsuariosScreen()),
          ),
          _OpcionLista(
            icon: Icons.category,
            title: 'Categorías',
            subtitle: 'Organizar el cancionero',
            onTap: () => _nav(context, const GestionCategoriasScreen()),
          ),
          _OpcionLista(
            icon: Icons.backup,
            title: 'Exportar respaldo',
            subtitle: 'Descargar base de datos',
            onTap: () => _nav(context, const ExportarRespaldoScreen()),
          ),
          _OpcionLista(
            icon: Icons.history,
            title: 'Historial',
            subtitle: 'Ver actividad reciente',
            onTap: () => _nav(context, const ActividadScreen()),
          ),
          const SizedBox(height: Sp.xxxl),
        ],
      ),
    );
  }

  void _nav(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _OpcionLista extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OpcionLista({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(Sp.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.sm),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.08),
                borderRadius: Rad.rMd,
              ),
              child: Icon(icon, color: AppColors.granate, size: 20),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppType.subtitle),
                  Text(subtitle,
                      style: AppType.captionXs.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.55))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.dorado, size: 20),
          ],
        ),
      ),
    );
  }
}