// lib/features/auth/widgets/login_hero.dart
import 'package:flutter/material.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/particle_field.dart';

class LoginHero extends StatefulWidget {
  const LoginHero({super.key});

  @override
  State<LoginHero> createState() => _LoginHeroState();
}

class _LoginHeroState extends State<LoginHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290,
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: ParticleField(
                count: 35,
                color: AppColors.dorado,
                opacity: 0.45,
                minRadius: 0.8,
                maxRadius: 2.5,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _floatAnim.value),
                    child: child,
                  ),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dorado.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.granate,
                          child: const Icon(
                            Icons.music_note,
                            color: AppColors.dorado,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Sp.xl),
                Text(
                  'ALLIN KAWSAY',
                  style: AppText.h1.copyWith(
                    color: AppColors.dorado,
                    letterSpacing: 8,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
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
            ),
          ),
        ],
      ),
    );
  }
}