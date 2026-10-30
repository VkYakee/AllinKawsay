// lib/features/auth/widgets/login_hero.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';

class LoginHero extends StatefulWidget {
  const LoginHero({super.key});

  @override
  State<LoginHero> createState() => _LoginHeroState();
}

class _LoginHeroState extends State<LoginHero> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animation.value),
              child: child,
            );
          },
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.dorado.withOpacity(0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dorado.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
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
        ),
        const SizedBox(height: Sp.xxxl),
        Text(
          'ALLIN KAWSAY',
          style: AppText.h1.copyWith(
            color: AppColors.dorado,
            letterSpacing: 8,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: Sp.xs),
        Text(
          'Bienvenido a la app oficial',
          style: AppText.bodySm.copyWith(
            color: AppColors.dorado.withOpacity(0.8),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: Sp.xs),
        Text(
          'C.I.A.C. Allin Kawsay · Juliaca - Perú',
          style: AppText.captionXs.copyWith(
            color: AppColors.dorado.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}