// lib/screens/perfil_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../design/design.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/permisos_service.dart';
import '../services/storage_service.dart';
import '../services/usuario_service.dart';
import '../widgets/perfil/modal_ajustes.dart';
import '../widgets/perfil/modal_mis_subidas.dart';
import '../widgets/perfil/perfil_admin_banner.dart';
import '../widgets/perfil/perfil_header.dart';
import '../widgets/perfil/perfil_menu_item.dart';
import '../widgets/perfil/perfil_stats.dart';
import '../widgets/social_buttons.dart';
import 'admin/admin_dashboard_screen.dart';
import 'compartir_app_screen.dart';

class PerfilScreen extends StatefulWidget {
  final String nombreUsuario;
  const PerfilScreen({super.key, required this.nombreUsuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _subiendoFoto = false;

  Future<void> _cambiarFoto(Usuario u) async {
    final ok = await PermisosService.pedirGaleria(context);
    if (!ok || !mounted) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 500,
        maxHeight: 500);
    if (x == null) return;
    setState(() => _subiendoFoto = true);
    try {
      final url = await StorageService().subirFotoPerfil(File(x.path), u.uid);
      await UsuarioService().actualizarFotoPerfil(u.uid, url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> _cambiarNombre(Usuario u) async {
    final ctrl = TextEditingController(text: u.nombre);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar nombre'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar')),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await UsuarioService().actualizarNombre(u.uid, ctrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Mi Perfil',
      body: StreamBuilder<Usuario?>(
        stream: UsuarioService().miUsuario(),
        builder: (context, snap) {
          final u = snap.data;
          final esAdmin = u?.esAdmin ?? false;
          return ListView(
            padding: const EdgeInsets.only(bottom: Sp.xxxl),
            children: [
              PerfilHeader(
                usuario: u,
                subiendoFoto: _subiendoFoto,
                onCambiarFoto: () => u != null ? _cambiarFoto(u) : null,
                onCambiarNombre: () => u != null ? _cambiarNombre(u) : null,
              ),
              const SizedBox(height: Sp.lg),
              if (u != null) PerfilStats(usuario: u),
              const SizedBox(height: Sp.md),
              if (esAdmin)
                PerfilAdminBanner(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AdminDashboardScreen(
                            isDev: u?.esDev ?? false)),
                  ),
                ),
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
                      builder: (_) => const CompartirAppScreen()),
                ),
              ),
              PerfilMenuItem(
                icono: Icons.settings,
                titulo: 'Ajustes',
                subtitulo: 'Tema y preferencias',
                onTap: () => ModalAjustes.mostrar(context, () {}),
              ),
              const SizedBox(height: Sp.xl),
              const SocialButtons(),
              const SizedBox(height: Sp.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.xxl),
                child: OutlinedButton.icon(
                  onPressed: () => AuthService().logout(),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('CERRAR SESIÓN'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: Sp.lg),
                    shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}