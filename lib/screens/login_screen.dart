import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../widgets/logo.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _loadingGoogle = false;
  bool _verPassword = false;

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _pass.text.trim().isEmpty) {
      _snack('Ingresa email y contraseña');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService().login(_email.text.trim(), _pass.text.trim());
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al iniciar sesión';
      switch (e.code) {
        case 'user-not-found':
          msg = 'No existe una cuenta con ese email';
          break;
        case 'wrong-password':
          msg = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          msg = 'Email inválido';
          break;
        case 'invalid-credential':
          msg = 'Email o contraseña incorrectos';
          break;
      }
      _snack(msg);
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _loadingGoogle = true);
    try {
      final user = await AuthService().loginConGoogle();
      if (user == null && mounted) {
        // Usuario canceló: no hacer nada
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'No se pudo iniciar sesión con Google';
      if (e.code == 'account-exists-with-different-credential') {
        msg = 'Ya existe una cuenta con ese email. '
            'Iniciá sesión con email y contraseña.';
      } else if (e.code == 'network-request-failed') {
        msg = 'Sin conexión a internet';
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
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }