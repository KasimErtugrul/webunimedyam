// lib/presentation/screens/auth/widgets/register_submit_button.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/auth/register_controller.dart';
import '../register_layout_spec.dart';

/// CTA — bg-primary, text-on-primary, rounded-lg, headline-sm bold,
/// shadow-lg (primary-container/20), aktif ölçek 0.98.
class RegisterSubmitButton extends GetView<RegisterController> {
  const RegisterSubmitButton({
    super.key,
    required this.sizes,
    required this.onPressed,
  });

  final RegisterSizes sizes;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value;
      final scheme = Theme.of(context).colorScheme;
      final s = sizes;

      return SizedBox(
        width: double.infinity,
        height: s.submitHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            disabledBackgroundColor: scheme.primary.withValues(alpha: 0.7),
            disabledForegroundColor: scheme.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: s.submitHPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(s.submitRadius),
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
                      'Kayıt Ol',
                      style: TextStyle(
                        fontSize: s.submitFontSize,
                        fontWeight: FontWeight.w700,
                        height: 24 / 18,
                        letterSpacing: -0.01 * s.submitFontSize,
                      ),
                    ),
                    SizedBox(width: s.chipVPadding + 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: s.submitIconSize,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}