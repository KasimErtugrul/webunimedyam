// lib/presentation/screens/auth/widgets/change_password_submit_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/change_password_controller.dart';
import '../change_password_layout_spec.dart';

/// "✓ Şifreyi Güncelle" — tasarımdaki gibi solid primary buton.
class ChangePasswordSubmitButton extends GetView<ChangePassController> {
  final ChangePasswordLayoutSpec spec;
  const ChangePasswordSubmitButton({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final loading = controller.isChangingPassword.value;
      return ElevatedButton(
        onPressed: loading ? null : controller.submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.55),
          disabledForegroundColor: scheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size(double.infinity, spec.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.radius),
          ),
        ),
        child: loading
            ? SizedBox(
                width: spec.loaderSize,
                height: spec.loaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: spec.loaderStroke,
                  color: scheme.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded,
                      size: spec.iconSize, color: scheme.onPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Şifreyi Güncelle',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: spec.fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      );
    });
  }
}