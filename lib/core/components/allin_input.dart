// lib/core/components/allin_input.dart
import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/motion.dart';
import '../design/tokens.dart';
import '../design/typography.dart';

class AllinInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final bool autofocus;
  final int maxLines;
  final FocusNode? focusNode;

  const AllinInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofocus = false,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  State<AllinInput> createState() => _AllinInputState();
}

class _AllinInputState extends State<AllinInput> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: Sp.xs, bottom: Sp.xs),
            child: Text(
              widget.label!,
              style: AppText.caption.copyWith(
                color: _isFocused
                    ? AppColors.oroSolar
                    : AppColors.textDarkSecundario,
                fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
        AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.easeOut,
          decoration: BoxDecoration(
            color: _isFocused
                ? AppColors.superficieCard.withOpacity(0.9)
                : AppColors.grafitoCarbon.withOpacity(0.55),
            borderRadius: Rad.rMd,
            border: Border.all(
              color: _errorText != null
                  ? Colors.redAccent.withOpacity(0.8)
                  : _isFocused
                      ? AppColors.oroSolar
                      : Colors.white.withOpacity(0.08),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.oroSolar.withOpacity(0.2),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            style: AppText.body.copyWith(
              color: Colors.white,
              fontSize: 15,
            ),
            cursorColor: AppColors.oroSolar,
            onChanged: (val) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
              widget.onChanged?.call(val);
            },
            onFieldSubmitted: widget.onSubmitted,
            validator: (val) {
              if (widget.validator != null) {
                final err = widget.validator!(val);
                setState(() => _errorText = err);
                return err;
              }
              return null;
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Sp.lg,
                vertical: 16,
              ),
              hintText: widget.hint,
              hintStyle: AppText.body.copyWith(
                color: Colors.white.withOpacity(0.28),
                fontSize: 14,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: _isFocused
                          ? AppColors.oroSolar
                          : Colors.white.withOpacity(0.4),
                    )
                  : null,
              suffixIcon: widget.suffix,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
          ),
        ),
        if (_errorText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: Sp.sm, top: Sp.xs),
            child: AnimatedOpacity(
              duration: AppMotion.fast,
              opacity: 1.0,
              child: Text(
                _errorText!,
                style: AppText.captionXs.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
