// lib/presentation/screens/auth/widgets/login_google_button.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/auth/login_controller.dart';
import '../login_layout_spec.dart';

/// Google butonu — bg-surface-container-high, text-on-surface,
/// rounded-lg, h-12 (border YOK — tasarımdaki düz dolgu)
class LoginGoogleButton extends GetView<LoginController> {
  const LoginGoogleButton({super.key, required this.sizes});

  final LoginSizes sizes;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isGoogleLoading.value;
      final scheme = Theme.of(context).colorScheme;
      final s = sizes;

      return SizedBox(
        width: double.infinity,
        height: s.buttonHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.surfaceContainerHigh,
            foregroundColor: scheme.onSurface,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius),
            ),
          ),
          onPressed: loading ? null : controller.signInWithGoogle,
          child: loading
              ? SizedBox(
                  width: s.loaderSize,
                  height: s.loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: s.loaderStroke,
                    color: scheme.onSurfaceVariant,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/google_logo.png',
                      width: s.googleIconSize,
                      height: s.googleIconSize,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.g_mobiledata_rounded,
                        size: s.googleIconSize + 6,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(width: s.googleGap),
                    Text(
                      'Google ile devam et',
                      style: TextStyle(
                        fontSize: s.buttonFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.01 * s.buttonFontSize,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}