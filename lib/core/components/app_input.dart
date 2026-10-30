// lib/core/components/app_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/colors.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AppInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.inputFormatters,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = AppColors.onSurface(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      inputFormatters: inputFormatters,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: AppText.body.copyWith(color: onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: AppColors.granate, size: 20),
        suffixIcon: suffix,
        counterText: '',
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.lg),
        labelStyle: const TextStyle(color: AppColors.granate),
        floatingLabelStyle: const TextStyle(color: AppColors.granate, fontWeight: FontWeight.bold),
        hintStyle: TextStyle(color: onSurface.withOpacity(0.4)),
        focusedBorder: OutlineInputBorder(
          borderRadius: Rad.rMd,
          borderSide: const BorderSide(color: AppColors.dorado, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Rad.rMd,
          borderSide: BorderSide(color: AppColors.dorado.withOpacity(0.3), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Rad.rMd,
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Rad.rMd,
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}