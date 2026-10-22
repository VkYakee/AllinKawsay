// lib/widgets/perfil/perfil_header.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../models/usuario.dart';
import '../../theme/colors.dart';

class PerfilHeader extends StatelessWidget {
  final Usuario? usuario;
  final bool subiendoFoto;
  final VoidCallback onCambiarFoto;
  final VoidCallback onCambiarNombre;

  const PerfilHeader({
    super.key,
    required this.usuario,
    required this.subiendoFoto,
    required this.onCambiarFoto,
    required this.onCambiarNombre,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.fromLTRB(Sp.xxl, Sp.xl, Sp.xxl, Sp.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.granate.withOpacity(0.08),
            AppColors.dorado.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradienteDorado,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dorado.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.granate,
                    backgroundImage:
                        (usuario?.fotoUrl.isNotEmpty ?? false)
                            ? NetworkImage(usuario!.fotoUrl)
                            : null,
                    child: (usuario?.fotoUrl.isEmpty ?? true)
                        ? const Icon(Icons.person,
                            size: 48, color: AppColors.dorado)
                        : null,
                  ),
                ),
                if (usuario != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: subiendoFoto ? null : onCambiarFoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradienteDorado,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.granate, width: 2.5),
                        ),
                        child: subiendoFoto
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: AppColors.granate,
                                    strokeWidth: 2))
                            : const Icon(Icons.camera_alt,
                                size: 16, color: AppColors.granate),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Sp.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                usuario?.nombre ?? 'Usuario',
                style: AppType.h3.copyWith(color: onSurface),
              ),
              if (usuario != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.edit,
                      size: 16, color: AppColors.granate),
                  onPressed: onCambiarNombre,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          Text(
            usuario?.email ?? '',
            style: AppType.bodySm.copyWith(
              color: onSurface.withOpacity(0.55),
            ),
          ),
          const SizedBox(height: Sp.md),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Sp.lg, vertical: Sp.xs + 2),
            decoration: BoxDecoration(
              gradient: usuario?.rol == 'publico'
                  ? null
                  : AppColors.gradienteGranate,
              color: usuario?.rol == 'publico'
                  ? AppColors.negro.withOpacity(0.1)
                  : null,
              borderRadius: Rad.rPill,
              border: usuario?.rol == 'publico'
                  ? Border.all(color: onSurface.withOpacity(0.2))
                  : null,
            ),
            child: Text(
              usuario?.rolNombre ?? 'PÚBLICO',
              style: AppType.labelXs.copyWith(
                color: usuario?.rol == 'publico'
                    ? onSurface.withOpacity(0.7)
                    : AppColors.dorado,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}