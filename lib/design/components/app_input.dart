// lib/design/components/app_input.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../tokens.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final accentColor = isDark ? AppColors.dorado : AppColors.granate;

    return ClipRRect(
      borderRadius: Rad.rMd,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassBlur.subtle,
          sigmaY: GlassBlur.subtle,
        ),
        child: TextFormField(
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
          style: TextStyle(
            color: onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: accentColor, size: 20),
            suffixIcon: suffix,
            counterText: '',
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.white.withOpacity(0.75),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Sp.lg,
              vertical: Sp.lg,
            ),
            labelStyle: TextStyle(
              color: onSurface.withOpacity(0.65),
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
            hintStyle: TextStyle(color: onSurface.withOpacity(0.38)),
            focusedBorder: OutlineInputBorder(
              borderRadius: Rad.rMd,
              borderSide: const BorderSide(color: AppColors.dorado, width: 1.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: Rad.rMd,
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.14)
                    : AppColors.granate.withOpacity(0.15),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: Rad.rMd,
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: Rad.rMd,
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: Rad.rMd,
              borderSide: BorderSide(color: onSurface.withOpacity(0.08)),
            ),
          ),
        ),
      ),
    );
  }
}
