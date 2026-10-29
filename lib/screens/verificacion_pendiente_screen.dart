// lib/screens/verificacion_pendiente_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../design/design.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';

class VerificacionRefresh {
  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);
  static void trigger() => notifier.value++;
}

class VerificacionPendienteScreen extends StatefulWidget {
  final String email;
  const VerificacionPendienteScreen({super.key, required this.email});

  @override
  State<VerificacionPendienteScreen> createState() => _VerificacionPendienteScreenState();
}

class _VerificacionPendienteScreenState extends State<VerificacionPendienteScreen> {
  bool _reenviando = false;
  bool _verificando = false;
  int _segundos = 0;

  @override
  void initState() {
    super.initState();
    _enviarEmail(primeraVez: true);
  }

  Future<void> _enviarEmail({bool primeraVez = false}) async {
    if (!primeraVez) setState(() => _reenviando = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        setState(() {
          _segundos = 60;
          if (!primeraVez) _reenviando = false;
        });
        _countdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _reenviando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
      }
    }
  }

  void _countdown() {
    if (_segundos > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _segundos--);
        _countdown();
      });
    }
  }

  Future<void> _verificar() async {
    setState(() => _verificando = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final actualizado = FirebaseAuth.instance.currentUser;

      if (actualizado != null && actualizado.emailVerified) {
        VerificacionRefresh.trigger();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aún no verificaste. Revisa tu correo (y spam).')));
      }
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sp.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.granate.withOpacity(0.1),
                  border: Border.all(color: AppColors.dorado.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.dorado.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: const Icon(Icons.mark_email_unread_outlined, size: 48, color: AppColors.dorado),
              ),
              const SizedBox(height: Sp.xl),
              Text('VERIFICA TU CORREO', style: AppType.h2.copyWith(color: AppColors.granate, letterSpacing: 1.5)),
              const SizedBox(height: Sp.sm),
              Text('Hemos enviado un enlace a:', style: AppType.body.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              Text(widget.email, style: AppType.subtitle.copyWith(color: AppColors.granate)),
              const SizedBox(height: Sp.xxl),
              
              AppCard(
                padding: const EdgeInsets.all(Sp.xl),
                child: Column(
                  children: [
                    _paso(1, 'Abre tu correo', 'Busca el email de Allin Kawsay (revisa spam).'),
                    _paso(2, 'Toca el enlace', 'Haz clic en "Verificar correo".'),
                    _paso(3, 'Vuelve aquí', 'Toca el botón de abajo para entrar.', ultimo: true),
                    const SizedBox(height: Sp.xl),
                    AppButton(
                      label: _verificando ? 'VERIFICANDO...' : 'YA VERIFIQUÉ',
                      fullWidth: true,
                      loading: _verificando,
                      onPressed: _verificar,
                    ),
                    const SizedBox(height: Sp.sm),
                    AppButton(
                      label: _reenviando ? 'ENVIANDO...' : (_segundos > 0 ? 'REENVIAR EN ${_segundos}s' : 'REENVIAR EMAIL'),
                      fullWidth: true,
                      variant: AppButtonVariant.secondary,
                      loading: _reenviando,
                      onPressed: _segundos > 0 ? null : () => _enviarEmail(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sp.lg),
              TextButton(
                onPressed: () => AuthService().logout(),
                child: Text('Cerrar sesión', style: AppType.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paso(int num, String titulo, String desc, {bool ultimo = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(gradient: AppColors.gradienteGranate, shape: BoxShape.circle),
            child: Text('$num', style: const TextStyle(color: AppColors.dorado, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppType.subtitle.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                Text(desc, style: AppType.captionXs.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}