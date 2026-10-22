// lib/widgets/auth/login_hero.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';

class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.dorado.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.dorado.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.granate,
                child: const Icon(Icons.music_note, color: AppColors.dorado, size: 50),
              ),
            ),
          ),
        ),
        const SizedBox(height: Sp.xl),
        Text(
          'ALLIN KAWSAY',
          style: AppType.h1.copyWith(
            color: AppColors.dorado,
            letterSpacing: 5,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: Sp.xs),
        Text(
          'Bienvenido a la app oficial',
          style: AppType.bodySm.copyWith(
            color: AppColors.dorado.withOpacity(0.8),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: Sp.xs),
        Text(
          'C.I.A.C. Allin Kawsay · Juliaca - Perú',
          style: AppType.captionXs.copyWith(
            color: AppColors.dorado.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}