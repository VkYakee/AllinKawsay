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
                  // ══════ LOGO REAL ══════
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.dorado.withOpacity(0.3),
                          blurRadius: 24,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.granate,
                          child: const Icon(Icons.person_add_alt_1,
                              color: AppColors.dorado, size: 50),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ══════ TEXTOS ══════
                  const Text(
                    'ÚNETE AL GRUPO',
                    style: TextStyle(
                      fontSize: 22,
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
                      color: AppColors.dorado.withOpacity(0.65),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'C.I.A.C. Allin Kawsay · Juliaca - Perú',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.dorado.withOpacity(0.4),
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ══════ CARD DE REGISTRO ══════
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.dorado.withOpacity(0.4),
                        width: 1.5,
                      ),
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
                        // Botón Google
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: (_loading || _loadingGoogle)
                                ? null
                                : _registrarConGoogle,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color:
                                      AppColors.negro.withOpacity(0.15),
                                  width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: AppColors.blanco,
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
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      _GoogleIcon(),
                                      SizedBox(width: 12),
                                      Text(
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
                                  color: AppColors.granate
                                      .withOpacity(0.2)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Text(
                                'o con email',
                                style: TextStyle(
                                  color:
                                      AppColors.negro.withOpacity(0.4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                  color: AppColors.granate
                                      .withOpacity(0.2)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _nombre,
                          textCapitalization:
                              TextCapitalization.words,
                          style: const TextStyle(
                              color: AppColors.negro, fontSize: 15),
                          decoration: _deco(
                              'Nombre completo', Icons.person),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              color: AppColors.negro, fontSize: 15),
                          decoration: _deco('Email', Icons.email),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _pass,
                          obscureText: !_verPass,
                          style: const TextStyle(
                              color: AppColors.negro, fontSize: 15),
                          decoration: _deco(
                              'Contraseña (mín. 6)', Icons.lock)
                              .copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verPass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color:
                                    AppColors.granate.withOpacity(0.6),
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
                          style: const TextStyle(
                              color: AppColors.negro, fontSize: 15),
                          decoration: _deco('Repetir contraseña',
                              Icons.lock_outline),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            onPressed: _loading ? null : _registrar,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.granate,
                              foregroundColor: AppColors.dorado,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
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

  /// Decoration para los campos de texto con label DORADO/GRANATE
  /// explícito, para que sea visible en cualquier modo.
  InputDecoration _deco(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.granate,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.granate,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      prefixIcon: Icon(icono, color: AppColors.granate, size: 20),
      filled: true,
      fillColor: AppColors.grisClaro,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.dorado, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: AppColors.dorado.withOpacity(0.5)),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }
}

/// Icono de Google con los 4 colores de la marca.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4285F4),
                Color(0xFFEA4335),
                Color(0xFFFBBC05),
                Color(0xFF34A853),
              ],
            ).createShader(bounds),
            child: const Text(
              'G',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}