// lib/features/perfil/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_card.dart';
import '../../../models/usuario.dart';
import '../../../services/auth_service.dart';
import '../../../services/usuario_service.dart';
// Importamos el Panel de Admin viejo (se migrará después)
import '../../../screens/admin/admin_dashboard_screen.dart';
// Importamos pantallas viejas que aún no migramos
import '../../../screens/compartir_app_screen.dart';
import '../../../screens/gestion_cache_screen.dart';
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
    final onSurface = AppColors.onSurface(context);

    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: StreamBuilder<Usuario?>(
        stream: UsuarioService().miUsuario(),
        builder: (context, snap) {
          final u = snap.data;
          final esAdmin = u?.esAdmin ?? false;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: PerfilHeader(usuario: u),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 120), // Espacio para el nav bar
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Banner de Admin
                    if (esAdmin)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.sm),
                        child: AppCard(
                          color: AppColors.granate,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminDashboardScreen(isDev: u?.esDev ?? false))),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(Sp.sm),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.admin_panel_settings, color: AppColors.dorado, size: 28),
                              ),
                              const SizedBox(width: Sp.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Panel de Administración', style: AppText.subtitle.copyWith(color: AppColors.dorado)),
                                    const SizedBox(height: 2),
                                    Text('Métricas y gestión del grupo', style: AppText.captionXs.copyWith(color: AppColors.dorado.withOpacity(0.7))),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: AppColors.dorado, size: 16),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: Sp.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Sp.xl),
                      child: Text('MI CUENTA', style: AppText.label.copyWith(color: AppColors.dorado.withOpacity(0.5), letterSpacing: 2)),
                    ),
                    const SizedBox(height: Sp.sm),

                    PerfilMenuItem(
                      icono: Icons.upload_file,
                      titulo: 'Mis subidas',
                      subtitulo: 'Canciones y recuerdos que subiste',
                      onTap: () => u != null ? ModalMisSubidas.mostrar(context, u.uid) : null,
                    ),
                    PerfilMenuItem(
                      icono: Icons.qr_code_2,
                      titulo: 'Compartir app',
                      subtitulo: 'Mostrar QR o enviar enlace',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompartirAppScreen())),
                    ),
                    PerfilMenuItem(
                      icono: Icons.storage,
                      titulo: 'Almacenamiento',
                      subtitulo: 'Gestionar caché de audios y fotos',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GestionCacheScreen())),
                    ),

                    const SizedBox(height: Sp.xl),
                    
                    // Botón de Cerrar Sesión
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () => AuthService().logout(),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: Text('CERRAR SESIÓN', style: AppText.label.copyWith(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}