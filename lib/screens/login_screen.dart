// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../design/design.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../widgets/auth/login_form.dart';
import '../widgets/auth/login_hero.dart';
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
      if (e.code == 'user-not-found') msg = 'No existe una cuenta con ese email';
      if (e.code == 'wrong-password') msg = 'Contraseña incorrecta';
      if (e.code == 'invalid-credential') msg = 'Email o contraseña incorrectos';
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
      if (user == null && mounted) {} // Cancelado
    } on FirebaseAuthException catch (e) {
      _snack(e.code == 'network-request-failed' ? 'Sin conexión a internet' : 'Error con Google');
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
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
            colors: [Color(0xFF0F0F0F), AppColors.granateOscuro, AppColors.granate],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Sp.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoginHero(),
                  const SizedBox(height: Sp.xxxl),
                  LoginForm(
                    emailCtrl: _email,
                    passCtrl: _pass,
                    verPass: _verPassword,
                    loading: _loading,
                    loadingGoogle: _loadingGoogle,
                    onVerPass: () => setState(() => _verPassword = !_verPassword),
                    onLogin: _login,
                    onGoogle: _loginGoogle,
                    onRegistro: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroScreen())),
                  ),
                  const SizedBox(height: Sp.xxl),
                  Text(
                    'Hecho con ❤️ para el grupo',
                    style: AppType.captionXs.copyWith(color: AppColors.dorado.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}