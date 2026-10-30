// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_card.dart';
// Pantallas viejas que iremos migrando
import '../../../screens/estadisticas_admin_screen.dart';
import '../../../screens/notificaciones_admin_screen.dart';
import '../../../screens/gestion_actualizaciones_screen.dart';
import '../../../screens/gestion_usuarios_screen.dart';
import '../../../screens/gestion_categorias_screen.dart';
import '../../../screens/exportar_respaldo_screen.dart';
import '../../../screens/actividad_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final bool isDev;
  const AdminDashboardScreen({super.key, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        title: Text(isDev ? 'Panel de Desarrollador' : 'Panel de Control', style: AppText.h3.copyWith(color: AppColors.dorado)),
        backgroundColor: AppColors.fondoOscuro,
        iconTheme: const IconThemeData(color: AppColors.dorado),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Sp.lg),
        children: [
          if (isDev) ...[
            AppCard(
              glass: true,
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
                        Text('DEV MODE ACTIVO', style: AppText.label.copyWith(color: Colors.cyanAccent, letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text('Acceso a prereleases y gestión de admins', style: AppText.captionXs.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.lg),
          ],
          
          _seccionHeader('Resumen', Icons.insights),
          _OpcionLista(
            icon: Icons.insights,
            title: 'Estadísticas del grupo',
            subtitle: 'Métricas, top canciones y usuarios',
            onTap: () => _nav(context, const EstadisticasAdminScreen()),
          ),
          
          const SizedBox(height: Sp.md),
          _seccionHeader('Comunicación', Icons.campaign),
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
          
          const SizedBox(height: Sp.md),
          _seccionHeader('Gestión de Contenido', Icons.settings),
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

  Widget _seccionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm, left: Sp.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.dorado),
          const SizedBox(width: Sp.sm),
          Text(title.toUpperCase(), style: AppText.label.copyWith(color: AppColors.dorado.withOpacity(0.6), letterSpacing: 1.5)),
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
        glass: true,
        onTap: onTap,
        padding: const EdgeInsets.all(Sp.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Sp.sm),
              decoration: BoxDecoration(
                color: AppColors.granate.withOpacity(0.2),
                borderRadius: Rad.rMd,
              ),
              child: Icon(icon, color: AppColors.dorado, size: 22),
            ),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.subtitle.copyWith(color: AppColors.onSurface(context))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.captionXs.copyWith(color: AppColors.onSurfaceVariant(context))),
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