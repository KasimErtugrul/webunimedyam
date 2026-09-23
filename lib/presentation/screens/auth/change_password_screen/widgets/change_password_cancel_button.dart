// lib/presentation/screens/auth/widgets/change_password_cancel_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../change_password_layout_spec.dart';

/// "Vazgeç" — ikincil buton (surface-container dolgulu).
class ChangePasswordCancelButton extends StatelessWidget {
  final ChangePasswordLayoutSpec spec;
  const ChangePasswordCancelButton({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: Get.back,
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: Size(double.infinity, spec.buttonHeight.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spec.radius.r),
        ),
      ),
      child: Text(
        'Vazgeç',
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: spec.fontSize.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}