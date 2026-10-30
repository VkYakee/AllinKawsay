// lib/features/perfil/widgets/perfil_header.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../models/usuario.dart';

class PerfilHeader extends StatelessWidget {
  final Usuario? usuario;

  const PerfilHeader({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);
    final esDev = usuario?.esDev ?? false;
    final esAdmin = usuario?.esAdmin ?? false;
    final esPublico = usuario?.rol == 'publico';

    return Padding(
      padding: const EdgeInsets.fromLTRB(Sp.xxl, Sp.xl, Sp.xxl, Sp.xxl),
      child: Column(
        children: [
          // Avatar con borde brillante
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: esDev
                  ? const LinearGradient(colors: [Colors.cyanAccent, Color(0xFF0A2540)])
                  : AppColors.gradienteDorado,
              boxShadow: [
                BoxShadow(
                  color: (esDev ? Colors.cyanAccent : AppColors.dorado).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: esDev ? const Color(0xFF0A2540) : AppColors.granate,
              backgroundImage: (usuario?.fotoUrl.isNotEmpty ?? false)
                  ? NetworkImage(usuario!.fotoUrl)
                  : null,
              child: (usuario?.fotoUrl.isEmpty ?? true)
                  ? Icon(Icons.person, size: 50, color: esDev ? Colors.cyanAccent : AppColors.dorado)
                  : null,
            ),
          ),
          const SizedBox(height: Sp.lg),
          
          // Nombre y Email
          Text(
            usuario?.nombre ?? 'Usuario',
            style: AppText.h2.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Sp.xs),
          Text(
            usuario?.email ?? '',
            style: AppText.body.copyWith(color: onSurface.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Sp.md),
          
          // Rol (Badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: 6),
            decoration: BoxDecoration(
              gradient: esDev
                  ? const LinearGradient(colors: [Color(0xFF0A2540), Color(0xFF163B65)])
                  : (esAdmin ? AppColors.gradienteGranate : null),
              color: esPublico ? Colors.white.withOpacity(0.1) : null,
              borderRadius: Rad.rPill,
              border: esDev
                  ? Border.all(color: Colors.cyanAccent.withOpacity(0.5))
                  : (esPublico ? Border.all(color: Colors.white.withOpacity(0.2)) : null),
            ),
            child: Text(
              usuario?.rolNombre ?? 'PÚBLICO',
              style: AppText.label.copyWith(
                color: esDev ? Colors.cyanAccent : AppColors.dorado,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}