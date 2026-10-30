// lib/features/auth/widgets/registro_form.dart
import 'package:flutter/material.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_input.dart';
import '../../../core/components/app_button.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import 'google_icon.dart';

class RegistroForm extends StatelessWidget {
  final TextEditingController nombreCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController pass2Ctrl;
  final TextEditingController honeypotCtrl;
  final bool verPass;
  final bool loading;
  final bool loadingGoogle;
  final VoidCallback onVerPass;
  final VoidCallback onRegistrar;
  final VoidCallback onGoogle;
  final VoidCallback onVolver;

  const RegistroForm({
    super.key,
    required this.nombreCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.pass2Ctrl,
    required this.honeypotCtrl,
    required this.verPass,
    required this.loading,
    required this.loadingGoogle,
    required this.onVerPass,
    required this.onRegistrar,
    required this.onGoogle,
    required this.onVolver,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      glass: true,
      padding: const EdgeInsets.all(Sp.xl),
      child: Column(
        children: [
          // 🍯 Honeypot invisible (Anti-bots)
          Offstage(
            offstage: true,
            child: SizedBox(
              height: 0,
              child: TextField(controller: honeypotCtrl, autofocus: false),
            ),
          ),
          AppInput(
            controller: nombreCtrl,
            label: 'Nombre completo',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: Sp.md),
          AppInput(
            controller: emailCtrl,
            label: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: Sp.md),
          AppInput(
            controller: passCtrl,
            label: 'Contraseña (mín. 6)',
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
          const SizedBox(height: Sp.md),
          AppInput(
            controller: pass2Ctrl,
            label: 'Repetir contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: !verPass,
          ),
          const SizedBox(height: Sp.xl),
          AppButton(
            label: 'CREAR CUENTA',
            fullWidth: true,
            loading: loading,
            onPressed: loading || loadingGoogle ? null : onRegistrar,
          ),
          const SizedBox(height: Sp.lg),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.dorado.withOpacity(0.2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sp.md),
                child: Text('o', style: AppText.caption.copyWith(color: AppColors.onSurfaceVariant(context))),
              ),
              Expanded(child: Divider(color: AppColors.dorado.withOpacity(0.2))),
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
              label: Text('Registrarme con Google', style: AppText.subtitle.copyWith(color: Colors.black)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: Rad.rMd),
              ),
            ),
          ),
          const SizedBox(height: Sp.md),
          TextButton.icon(
            onPressed: loading || loadingGoogle ? null : onVolver,
            icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.dorado),
            label: Text('Ya tengo cuenta', style: AppText.subtitle.copyWith(color: AppColors.dorado)),
          ),
        ],
      ),
    );
  }
}