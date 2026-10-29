// lib/screens/registro_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../design/design.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../widgets/auth/login_hero.dart';
import '../widgets/auth/registro_form.dart';

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
  final _honeypot = TextEditingController();

  bool _loading = false;
  bool _loadingGoogle = false;
  bool _verPass = false;
  final DateTime _inicioFormulario = DateTime.now();

  Future<void> _registrar() async {
    final nombre = _nombre.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text;
    final pass2 = _pass2.text;

    // 🍯 Anti-bot
    if (_honeypot.text.isNotEmpty) return _snack('Error al crear cuenta.');
    if (DateTime.now().difference(_inicioFormulario).inSeconds < 3) {
      return _snack('El formulario se envió muy rápido.');
    }

    if (nombre.isEmpty || email.isEmpty || pass.isEmpty) return _snack('Completa todos los campos');
    if (pass.length < 6) return _snack('La contraseña debe tener al menos 6 caracteres');
    if (pass != pass2) return _snack('Las contraseñas no coinciden');

    setState(() => _loading = true);
    try {
      final user = await AuthService().registrar(email, pass, nombre);
      try {
        await user?.sendEmailVerification();
      } catch (_) {}
      if (mounted) {
        _snack('¡Cuenta creada! Revisa tu correo.');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al registrarte';
      if (e.code == 'email-already-in-use') msg = 'Ese email ya está registrado';
      if (e.code == 'weak-password') msg = 'Contraseña muy débil';
      if (e.code == 'invalid-email') msg = 'Email inválido';
      _snack(msg);
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registrarConGoogle() async {
    if (DateTime.now().difference(_inicioFormulario).inSeconds < 2) {
      return _snack('Espera un momento antes de continuar.');
    }
    setState(() => _loadingGoogle = true);
    try {
      final user = await AuthService().loginConGoogle();
      if (user != null && mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _snack(e.code == 'account-exists-with-different-credential' ? 'Ese email ya está registrado.' : 'Error con Google');
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
    _nombre.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    _honeypot.dispose();
    super.dispose();
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
              const LoginHero(),
              const SizedBox(height: Sp.xxxl),
              RegistroForm(
                nombreCtrl: _nombre,
                emailCtrl: _email,
                passCtrl: _pass,
                pass2Ctrl: _pass2,
                honeypotCtrl: _honeypot,
                verPass: _verPass,
                loading: _loading,
                loadingGoogle: _loadingGoogle,
                onVerPass: () => setState(() => _verPass = !_verPass),
                onRegistrar: _registrar,
                onGoogle: _registrarConGoogle,
                onVolver: () => Navigator.pop(context),
              ),
              const SizedBox(height: Sp.xxl),
            ],
          ),
        ),
      ),
    );
  }
}