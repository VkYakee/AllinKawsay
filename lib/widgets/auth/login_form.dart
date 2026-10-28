// lib/widgets/auth/login_form.dart
import 'package:flutter/material.dart';
import '../../design/design.dart';
import '../../theme/colors.dart';
import 'google_icon.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool verPass;
  final bool loading;
  final bool loadingGoogle;
  final VoidCallback onVerPass;
  final VoidCallback onLogin;
  final VoidCallback onGoogle;
  final VoidCallback onRegistro;

  const LoginForm({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.verPass,
    required this.loading,
    required this.loadingGoogle,
    required this.onVerPass,
    required this.onLogin,
    required this.onGoogle,
    required this.onRegistro,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Sp.xl),
      child: Column(
        children: [
          AppInput(
            controller: emailCtrl,
            label: 'Correo electrónico',
            hint: 'tu@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: Sp.lg),
          AppInput(
            controller: passCtrl,
            label: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: !verPass,
            suffix: IconButton(
              icon: Icon(
                verPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.granate.withOpacity(0.6),
              ),
              onPressed: onVerPass,
            ),
          ),
          const SizedBox(height: Sp.xl),
          AppButton(
            label: 'INGRESAR',
            fullWidth: true,
            loading: loading,
            onPressed: loading || loadingGoogle ? null : onLogin,
          ),
          const SizedBox(height: Sp.lg),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.granate.withOpacity(0.2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.md),
                child: Text('o', style: AppType.caption.copyWith(color: AppColors.granate.withOpacity(0.5))),
              ),
              Expanded(child: Divider(color: AppColors.granate.withOpacity(0.2))),
            ],
          ),
          const SizedBox(height: Sp.lg),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: loading || loadingGoogle ? null : onGoogle,
              icon: loadingGoogle
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const GoogleIcon(),
              label: Text('Continuar con Google', style: AppType.subtitle.copyWith(color: AppColors.negro)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.negro,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
              ),
            ),
          ),
          const SizedBox(height: Sp.lg),
          TextButton(
            onPressed: loading || loadingGoogle ? null : onRegistro,
            child: Text(
              '¿No tienes cuenta? Regístrate',
              style: AppType.subtitle.copyWith(color: AppColors.granate),
            ),
          ),
        ],
      ),
    );
  }
}