import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});
  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool _loading = false;
  bool _loadingGoogle = false;
  bool _verPass = false;

  Future<void> _registrar() async {
    final nombre = _nombre.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text;
    final pass2 = _pass2.text;

    if (nombre.isEmpty || email.isEmpty || pass.isEmpty) {
      _snack('Completa todos los campos');
      return;
    }
    if (pass.length < 6) {
      _snack('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (pass != pass2) {
      _snack('Las contraseñas no coinciden');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService().registrar(email, pass, nombre);
      if (mounted) {
        _snack('¡Cuenta creada! Bienvenido/a $nombre');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al registrarte';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Ese email ya está registrado';
          break;
        case 'weak-password':
          msg = 'Contraseña muy débil';
          break;
        case 'invalid-email':
          msg = 'Email inválido';
          break;
      }
      _snack(msg);
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registrarConGoogle() async {
    setState(() => _loadingGoogle = true);
    try {
      final user = await AuthService().loginConGoogle();
      if (user != null && mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'No se pudo registrar con Google';
      if (e.code == 'account-exists-with-different-credential') {
        msg = 'Ese email ya está registrado con contraseña.';
      }
      _snack(msg);
    } catch (e) {
      final s = e.toString();
      if (s.contains('ApiException: 10')) {
        _snack('Configuración incompleta: falta registrar el SHA-1 en '
            'Firebase Console.');
      } else if (s.contains('sign_in_canceled') ||
          s.contains('canceled')) {
        // Silencioso
      } else {
        _snack('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
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
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.person_add_alt_1,
                        size: 42, color: AppColors.dorado),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ÚNETE AL GRUPO',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dorado,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu cuenta para acceder al cancionero',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.dorado.withOpacity(0.6),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.dorado.withOpacity(0.25)),
                    ),
                    child: Column(
                      children: [
                        // ══════ Botón Google (rápido) ══════
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: (_loading || _loadingGoogle)
                                ? null
                                : _registrarConGoogle,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.dorado
                                      .withOpacity(0.5),
                                  width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Colors.white,
                            ),
                            child: _loadingGoogle
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: AppColors.granate,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'G',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4285F4),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Registrarme con Google',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.negro,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                  color: AppColors.dorado
                                      .withOpacity(0.2)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Text(
                                'o con email',
                                style: TextStyle(
                                  color: AppColors.dorado
                                      .withOpacity(0.6),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                  color: AppColors.dorado
                                      .withOpacity(0.2)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _nombre,
                          textCapitalization:
                              TextCapitalization.words,
                          style: const TextStyle(color: Colors.white),
                          decoration:
                              _deco('Nombre completo', Icons.person),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _deco('Email', Icons.email),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _pass,
                          obscureText: !_verPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: _deco(
                              'Contraseña (mín. 6)', Icons.lock).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verPass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color:
                                    AppColors.dorado.withOpacity(0.6),
                              ),
                              onPressed: () => setState(
                                  () => _verPass = !_verPass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _pass2,
                          obscureText: !_verPass,
                          style: const TextStyle(color: Colors.white),
                          decoration: _deco('Repetir contraseña',
                              Icons.lock_outline),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            onPressed: _loading ? null : _registrar,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: AppColors.dorado,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'CREAR CUENTA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: (_loading || _loadingGoogle)
                        ? null
                        : () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back,
                        size: 16,
                        color: AppColors.dorado.withOpacity(0.7)),
                    label: Text(
                      'Ya tengo cuenta',
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

  InputDecoration _deco(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.dorado.withOpacity(0.8)),
      prefixIcon:
          Icon(icono, color: AppColors.dorado.withOpacity(0.8), size: 20),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
    );
  }
}