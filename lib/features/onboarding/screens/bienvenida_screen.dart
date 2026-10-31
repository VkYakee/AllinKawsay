// lib/features/onboarding/screens/bienvenida_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/widgets/particle_field.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textoCtrl;
  late final AnimationController _glowCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _tituloSlide;
  late final Animation<double> _tituloOpacity;
  late final Animation<Offset> _versionSlide;
  late final Animation<double> _versionOpacity;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _buttonOpacity;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Controladores
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Logo: escala con rebote + fade
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: AppMotion.bouncy),
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    // Título: entra desde abajo con fade
    _tituloSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _textoCtrl,
        curve: const Interval(0.2, 0.7, curve: AppMotion.easeOutQuart),
      ),
    );
    _tituloOpacity = CurvedAnimation(
      parent: _textoCtrl,
      curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
    );

    // Versión 3.0: entra después del título
    _versionSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _textoCtrl,
        curve: const Interval(0.4, 0.9, curve: AppMotion.easeOutQuart),
      ),
    );
    _versionOpacity = CurvedAnimation(
      parent: _textoCtrl,
      curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
    );

    // Botón: entra al final
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _textoCtrl,
        curve: const Interval(0.6, 1.0, curve: AppMotion.easeOutQuart),
      ),
    );
    _buttonOpacity = CurvedAnimation(
      parent: _textoCtrl,
      curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
    );

    // Glow del logo
    _glowAnim = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // Iniciar secuencia
    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textoCtrl.forward();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textoCtrl.dispose();
    _glowCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _continuar() {
    AppMotion.hapticHeavy();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      body: Stack(
        children: [
          // Fondo de partículas
          const Positioned.fill(
            child: IgnorePointer(
              child: ParticleField(
                count: 50,
                color: AppColors.dorado,
                opacity: 0.3,
                minRadius: 1.0,
                maxRadius: 3.0,
              ),
            ),
          ),

          // Gradiente de fondo para que las partículas resalten
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    AppColors.granate.withOpacity(0.3),
                    AppColors.fondoOscuro.withOpacity(0.8),
                    AppColors.fondoOscuro,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Contenido central
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo animado con glow
                    AnimatedBuilder(
                      animation: _logoCtrl,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoOpacity,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: AnimatedBuilder(
                              animation: _glowAnim,
                              builder: (context, _) {
                                return Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.dorado.withOpacity(
                                          _glowAnim.value,
                                        ),
                                        blurRadius: 50,
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
                                        child: const Icon(
                                          Icons.music_note,
                                          color: AppColors.dorado,
                                          size: 64,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: Sp.xxxl),

                    // Título "ALLIN KAWSAY"
                    FadeTransition(
                      opacity: _tituloOpacity,
                      child: SlideTransition(
                        position: _tituloSlide,
                        child: Text(
                          'ALLIN KAWSAY',
                          style: AppText.h1.copyWith(
                            color: AppColors.dorado,
                            fontSize: 32,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: Sp.md),

                    // Versión 3.0
                    FadeTransition(
                      opacity: _versionOpacity,
                      child: SlideTransition(
                        position: _versionSlide,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sp.lg,
                                vertical: Sp.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.dorado.withOpacity(0.15),
                                borderRadius: Rad.rPill,
                                border: Border.all(
                                  color: AppColors.dorado.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                'VERSIÓN 3.0',
                                style: AppText.label.copyWith(
                                  color: AppColors.dorado,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: Sp.lg),
                            Text(
                              'Bienvenido a la nueva experiencia.\nRediseñada para el grupo.',
                              style: AppText.body.copyWith(
                                color: Colors.white70,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Botón "Comenzar"
                    FadeTransition(
                      opacity: _buttonOpacity,
                      child: SlideTransition(
                        position: _buttonSlide,
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: GestureDetector(
                            onTap: _continuar,
                            child: AnimatedContainer(
                              duration: AppMotion.fast,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradienteDorado,
                                borderRadius: Rad.rPill,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.dorado.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'COMENZAR',
                                    style: AppText.label.copyWith(
                                      color: AppColors.granateOscuro,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: Sp.sm),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.granateOscuro,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.xxxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}