// lib/core/components/allin_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/motion.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import 'allin_button.dart';

class AllinDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;

  const AllinDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText = 'Aceptar',
    this.cancelText = 'Cancelar',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
  });

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
    IconData? icon,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: AppMotion.normal,
      pageBuilder: (ctx, _, __) => AllinDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: AppMotion.spring,
        );
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16 * anim.value,
            sigmaY: 16 * anim.value,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: anim,
              child: child,
            ),
          ),
        );
      },
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: AppMotion.normal,
      pageBuilder: (ctx, _, __) => child,
      transitionBuilder: (ctx, anim, _, c) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: AppMotion.spring,
        );
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16 * anim.value,
            sigmaY: 16 * anim.value,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: anim,
              child: c,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: Sp.xl),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: AppColors.fondoOLED.withOpacity(0.92),
          borderRadius: Rad.rXl,
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.4)
                : AppColors.oroSolar.withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
            if (isDestructive)
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 25,
              )
            else
              BoxShadow(
                color: AppColors.granateSagrado.withOpacity(0.35),
                blurRadius: 25,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(Sp.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDestructive
                          ? Colors.red.withOpacity(0.12)
                          : AppColors.granateSagrado.withOpacity(0.3),
                      border: Border.all(
                        color: isDestructive
                            ? Colors.red.withOpacity(0.4)
                            : AppColors.oroSolar.withOpacity(0.5),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isDestructive ? Colors.redAccent : AppColors.oroSolar,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: Sp.md),
                ],
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppText.h3.copyWith(
                    color: isDestructive ? Colors.redAccent : AppColors.oroSolar,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: Sp.sm),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(
                      color: AppColors.textDarkSecundario,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                if (content != null) ...[
                  const SizedBox(height: Sp.md),
                  content!,
                ],
                const SizedBox(height: Sp.xl),
                Row(
                  children: [
                    if (cancelText != null) ...[
                      Expanded(
                        child: AllinButton(
                          text: cancelText!,
                          variant: AllinButtonVariant.glass,
                          height: 46,
                          onPressed: onCancel ?? () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: Sp.sm),
                    ],
                    if (confirmText != null)
                      Expanded(
                        child: AllinButton(
                          text: confirmText!,
                          variant: isDestructive
                              ? AllinButtonVariant.danger
                              : AllinButtonVariant.primary,
                          height: 46,
                          onPressed: onConfirm ?? () => Navigator.pop(context, true),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
