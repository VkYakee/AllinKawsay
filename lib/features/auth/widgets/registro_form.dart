// lib/features/auth/widgets/registro_form.dart
import 'package:flutter/material.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/motion.dart';
import '../../../core/design/tokens.dart';
import '../../../core/design/typography.dart';
import '../../../core/components/app_card.dart';
import '../../../core/components/app_button.dart';

import 'google_icon.dart';

class RegistroForm extends StatefulWidget {
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
  State<RegistroForm> createState() => _RegistroFormState();
}

class _RegistroFormState extends State<RegistroForm> {
  bool _nombreValido = false;
  bool _emailValido = false;
  bool _passValido = false;
  bool _pass2Valido = false;

  @override
  void initState() {
    super.initState();
    widget.nombreCtrl.addListener(_onNombreChanged);
    widget.emailCtrl.addListener(_onEmailChanged);
    widget.passCtrl.addListener(_onPassChanged);
    widget.pass2Ctrl.addListener(_onPass2Changed);
  }

  @override
  void dispose() {
    widget.nombreCtrl.removeListener(_onNombreChanged);
    widget.emailCtrl.removeListener(_onEmailChanged);
    widget.passCtrl.removeListener(_onPassChanged);
    widget.pass2Ctrl.removeListener(_onPass2Changed);
    super.dispose();
  }

  void _onNombreChanged() {
    final valido = widget.nombreCtrl.text.trim().length >= 3;
    if (valido != _nombreValido) setState(() => _nombreValido = valido);
  }

  void _onEmailChanged() {
    final email = widget.emailCtrl.text.trim();
    final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (valido != _emailValido) setState(() => _emailValido = valido);
  }

  void _onPassChanged() {
    final valido = widget.passCtrl.text.length >= 6;
    if (valido != _passValido) setState(() => _passValido = valido);
    // Revalidar pass2 si ya tiene texto
    if (widget.pass2Ctrl.text.isNotEmpty) _onPass2Changed();
  }

  void _onPass2Changed() {
    final valido = widget.pass2Ctrl.text.isNotEmpty &&
        widget.pass2Ctrl.text == widget.passCtrl.text;
    if (valido != _pass2Valido) setState(() => _pass2Valido = valido);
  }

  @override
  Widget build(BuildContext context) {
    final puedeSubmit = _nombreValido &&
        _emailValido &&
        _passValido &&
        _pass2Valido &&
        !widget.loading &&
        !widget.loadingGoogle;

    return AppCard(
      glass: true,
      padding: const EdgeInsets.all(Sp.xl),
      child: Column(
        children: [
          // Honeypot invisible
          Offstage(
            offstage: true,
            child: SizedBox(
              height: 0,
              child: TextField(
                controller: widget.honeypotCtrl,
                autofocus: false,
              ),
            ),
          ),
          _ValidatedField(
            controller: widget.nombreCtrl,
            label: 'Nombre completo',
            icon: Icons.person_outline,
            valido: _nombreValido,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: Sp.md),
          _ValidatedField(
            controller: widget.emailCtrl,
            label: 'Correo electrónico',
            icon: Icons.email_outlined,
            valido: _emailValido,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: Sp.md),
          _ValidatedField(
            controller: widget.passCtrl,
            label: 'Contraseña (mín. 6)',
            icon: Icons.lock_outline,
            valido: _passValido,
            obscureText: !widget.verPass,
            suffix: IconButton(
              icon: Icon(
                widget.verPass
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.granate.withOpacity(0.6),
                size: 20,
              ),
              onPressed: widget.onVerPass,
            ),
          ),
          const SizedBox(height: Sp.md),
          _ValidatedField(
            controller: widget.pass2Ctrl,
            label: 'Repetir contraseña',
            icon: Icons.lock_outline,
            valido: _pass2Valido,
            obscureText: !widget.verPass,
          ),
          const SizedBox(height: Sp.xl),

          AppButton(
            label: 'CREAR CUENTA',
            fullWidth: true,
            loading: widget.loading,
            onPressed: puedeSubmit ? widget.onRegistrar : null,
          ),

          const SizedBox(height: Sp.lg),
          _buildDivider(),
          const SizedBox(height: Sp.lg),

          _GoogleButton(
            loading: widget.loadingGoogle,
            onTap: widget.onGoogle,
            disabled: widget.loading || widget.loadingGoogle,
          ),

          const SizedBox(height: Sp.md),
          TextButton.icon(
            onPressed: widget.loading || widget.loadingGoogle
                ? null
                : widget.onVolver,
            icon: const Icon(
              Icons.arrow_back,
              size: 16,
              color: AppColors.dorado,
            ),
            label: Text(
              'Ya tengo cuenta',
              style: AppText.subtitle.copyWith(color: AppColors.dorado),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.dorado.withOpacity(0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md),
          child: Text(
            'o',
            style: AppText.caption.copyWith(
              color: AppColors.dorado.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.dorado.withOpacity(0.2)),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CAMPO VALIDADO EN VIVO
// ═══════════════════════════════════════════════════════════

class _ValidatedField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool valido;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const _ValidatedField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.valido,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<_ValidatedField> createState() => _ValidatedFieldState();
}

class _ValidatedFieldState extends State<_ValidatedField> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChanged);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tieneTexto = widget.controller.text.isNotEmpty;
    final enfocado = _focus.hasFocus;

    Color borderColor;
    double borderWidth;
    if (widget.valido) {
      borderColor = AppColors.dorado.withOpacity(0.7);
      borderWidth = 1.5;
    } else if (tieneTexto) {
      borderColor = Colors.redAccent.withOpacity(0.5);
      borderWidth = 1.2;
    } else if (enfocado) {
      borderColor = AppColors.dorado.withOpacity(0.5);
      borderWidth = 1.5;
    } else {
      borderColor = AppColors.dorado.withOpacity(0.15);
      borderWidth = 1.0;
    }

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.easeOut,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: Rad.rMd,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: widget.valido
            ? [
                BoxShadow(
                  color: AppColors.dorado.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        style: AppText.body.copyWith(color: AppColors.onSurface(context)),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: widget.valido
                ? AppColors.dorado
                : AppColors.granate.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: widget.valido ? AppColors.dorado : AppColors.granate,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: widget.valido
                ? AppColors.dorado
                : AppColors.granate.withOpacity(0.6),
            size: 20,
          ),
          suffixIcon: widget.suffix ??
              (widget.valido
                  ? const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.dorado,
                        size: 20,
                      ),
                    )
                  : null),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Sp.lg,
            vertical: Sp.lg,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BOTÓN GOOGLE
// ═══════════════════════════════════════════════════════════

class _GoogleButton extends StatefulWidget {
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _GoogleButton({
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp:
          widget.disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel:
          widget.disabled ? null : () => setState(() => _pressed = false),
      onTap: widget.disabled
          ? null
          : () {
              AppMotion.hapticLight();
              widget.onTap();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.spring,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(widget.disabled ? 0.5 : 1.0),
            borderRadius: Rad.rMd,
            border: Border.all(
              color: AppColors.dorado.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.dorado.withOpacity(
                  widget.disabled ? 0.1 : 0.25,
                ),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.granate,
                    strokeWidth: 2.5,
                  ),
                )
              else
                const GoogleIcon(),
              const SizedBox(width: Sp.md),
              Text(
                'Registrarme con Google',
                style: AppText.subtitle.copyWith(
                  color: AppColors.granateOscuro,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}