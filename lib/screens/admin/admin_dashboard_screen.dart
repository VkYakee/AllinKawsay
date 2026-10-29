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
            AppCard(
              color: const Color(0xFF0A2540).withOpacity(0.9),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              child: Row(
                children: [
                  const Icon(Icons.code, color: Colors.cyanAccent, size: 28),
                  const SizedBox(width: Sp.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DEV MODE ACTIVO', style: AppType.label.copyWith(color: Colors.cyanAccent, letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text('Acceso a prereleases y gestión de admins', style: AppType.captionXs.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.lg),
          ],
          
          const SeccionHeader(title: 'Resumen', icon: Icons.insights),
          _OpcionLista(
            icon: Icons.insights,
            title: 'Estadísticas del grupo',
            subtitle: 'Métricas, top canciones y usuarios',
            onTap: () => _nav(context, const EstadisticasAdminScreen()),
          ),
          
          const SeccionHeader(title: 'Comunicación', icon: Icons.campaign),
          _OpcionLista(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Enviar avisos al grupo',
            onTap: () => _nav(context, const NotificacionesAdminScreen()),
          ),
          _OpcionLista(
            icon: Icons.system_update,
            title: isDev ? 'Actualizaciones (Todos)' : 'Actualizaciones',
            subtitle: isDev ? 'Ver releases y prereleases' : 'Aprobar versiones',
            onTap: () => _nav(context, const GestionActualizacionesScreen()),
          ),
          
          const SeccionHeader(title: 'Gestión de Contenido', icon: Icons.settings),
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
            icon: Icons.history,
            title: 'Historial de Actividad',
            subtitle: 'Ver quién hizo qué en el grupo',
            onTap: () => _nav(context, const ActividadScreen()),
          ),
          _OpcionLista(
            icon: Icons.backup,
            title: 'Exportar respaldo',
            subtitle: 'Descargar base de datos en JSON',
            onTap: () => _nav(context, const ExportarRespaldoScreen()),
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
                color: AppColors.granate.withOpacity(0.1),
                borderRadius: Rad.rMd,
              ),
              child: Icon(icon, color: AppColors.granate, size: 22),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppType.subtitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppType.captionXs.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.dorado.withOpacity(0.6), size: 20),
          ],
        ),
      ),
    );
  }
}