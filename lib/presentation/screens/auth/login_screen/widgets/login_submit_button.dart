// lib/presentation/screens/auth/widgets/login_submit_button.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/auth/login_controller.dart';
import '../login_layout_spec.dart';

/// CTA — bg-primary, text-on-primary, rounded-lg, h-12, shadow-sm
/// (gradient YOK — tasarımdaki düz dolgu bire bir korunuyor)
class LoginSubmitButton extends GetView<LoginController> {
  const LoginSubmitButton({super.key, required this.sizes, required this.onPressed});

  final LoginSizes sizes;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value;
      final scheme = Theme.of(context).colorScheme;
      final s = sizes;

      return SizedBox(
        width: double.infinity,
        height: s.buttonHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            disabledBackgroundColor: scheme.primary.withValues(alpha: 0.7),
            disabledForegroundColor: scheme.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius), // rounded-lg
            ),
          ),
          onPressed: loading ? null : onPressed,
          child: loading
              ? SizedBox(
                  width: s.loaderSize,
                  height: s.loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: s.loaderStroke,
                    color: scheme.onPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontSize: s.buttonFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.01 * s.buttonFontSize, // label-lg
                      ),
                    ),
                    SizedBox(width: 8), // gap-2
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: s.buttonIconSize,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}