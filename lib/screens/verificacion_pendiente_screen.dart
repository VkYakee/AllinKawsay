import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';

/// Notifier global para que el _AuthGate se entere cuando el usuario
/// acaba de verificar el correo, y redirija automáticamente al Home.
class VerificacionRefresh {
  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);
  static void trigger() => notifier.value++;
}

class VerificacionPendienteScreen extends StatefulWidget {
  final String email;
  const VerificacionPendienteScreen({super.key, required this.email});

  @override
  State<VerificacionPendienteScreen> createState() =>
      _VerificacionPendienteScreenState();
}

class _VerificacionPendienteScreenState
    extends State<VerificacionPendienteScreen> {
  bool _reenviando = false;
  bool _verificando = false;
  int _segundosParaReenviar = 0;
  bool _emailEnviadoAhora = false;

  @override
  void initState() {
    super.initState();
    _enviarEmailInicial();
  }

  Future<void> _enviarEmailInicial() async {
    final ok = await _enviarEmail();
    if (ok && mounted) {
      setState(() {
        _emailEnviadoAhora = true;
        _segundosParaReenviar = 60;
      });
      _iniciarCountdown();
    }
  }

  void _iniciarCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_segundosParaReenviar > 0) {
        setState(() => _segundosParaReenviar--);
        _iniciarCountdown();
      }
    });
  }

  Future<bool> _enviarEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await user.sendEmailVerification();
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo enviar el email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _reenviar() async {
    if (_segundosParaReenviar > 0) return;
    setState(() => _reenviando = true);
    final ok = await _enviarEmail();
    if (!mounted) return;
    setState(() {
      _reenviando = false;
      if (ok) {
        _segundosParaReenviar = 60;
        _iniciarCountdown();
      }
    });
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email reenviado. Revisá tu bandeja.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _yaVerifique() async {
    setState(() => _verificando = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Recargar el usuario para traer el estado actualizado
      await user.reload();
      final actualizado = FirebaseAuth.instance.currentUser;

      if (actualizado != null && actualizado.emailVerified) {
        // Ya verificado → trigger al AuthGate para que redirija
        VerificacionRefresh.trigger();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Todavía no verificaste. Revisá tu correo (y la carpeta spam).'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F0F),
              AppColors.granateOscuro,
              AppColors.granate,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.4),
                          width: 2),
                    ),
                    child: const Icon(Icons.mark_email_unread_outlined,
                        size: 52, color: AppColors.dorado),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'VERIFICÁ TU CORREO',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dorado,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _emailEnviadoAhora
                        ? 'Te enviamos un email a:'
                        : 'Enviaremos un email de verificación a:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.dorado.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dorado,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.4),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _paso(
                          numero: '1',
                          titulo: 'Abrí tu correo',
                          descripcion:
                              'Buscá el email de "Allin Kawsay" (revisá spam).',
                        ),
                        const SizedBox(height: 14),
                        _paso(
                          numero: '2',
                          titulo: 'Tocá el enlace',
                          descripcion:
                              'Hacé clic en "Verificar correo" del email.',
                        ),
                        const SizedBox(height: 14),
                        _paso(
                          numero: '3',
                          titulo: 'Volvé a la app',
                          descripcion:
                              'Tocá "YA VERIFIQUÉ" y entrás automáticamente.',
                          ultimo: true,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed:
                                _verificando ? null : _yaVerifique,
                            icon: _verificando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.dorado,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Icon(Icons.check_circle,
                                    size: 20),
                            label: Text(
                              _verificando
                                  ? 'VERIFICANDO...'
                                  : 'YA VERIFIQUÉ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.granate,
                              foregroundColor: AppColors.dorado,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: (_reenviando ||
                                    _segundosParaReenviar > 0)
                                ? null
                                : _reenviar,
                            icon: _reenviando
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: AppColors.granate,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh, size: 18),
                            label: Text(
                              _reenviando
                                  ? 'ENVIANDO...'
                                  : (_segundosParaReenviar > 0
                                      ? 'REENVIAR EN ${_segundosParaReenviar}s'
                                      : 'REENVIAR EMAIL'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.granate,
                              side: BorderSide(
                                  color: AppColors.granate.withOpacity(0.6)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton.icon(
                    onPressed: _cerrarSesion,
                    icon: Icon(Icons.logout,
                        size: 16,
                        color: AppColors.dorado.withOpacity(0.7)),
                    label: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: AppColors.dorado.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _paso({
    required String numero,
    required String titulo,
    required String descripcion,
    bool ultimo = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.gradienteGranate,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.granate.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            numero,
            style: const TextStyle(
              color: AppColors.dorado,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.granate,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                descripcion,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.negro.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}