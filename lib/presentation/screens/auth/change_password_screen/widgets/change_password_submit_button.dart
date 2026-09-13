// lib/presentation/screens/auth/widgets/change_password_submit_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/auth/change_password_controller.dart';
import '../change_password_layout_spec.dart';

class ChangePasswordSubmitButton extends GetView<ChangePasswordController> {
  final ChangePasswordLayoutSpec spec;
  final VoidCallback onPressed;

  const ChangePasswordSubmitButton({
    super.key,
    required this.spec,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isChangingPassword.value;
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: loading
              ? null
              : const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: loading
              ? const []
              : [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                loading ? AppTheme.surface(context) : Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: AppTheme.surface(context),
            minimumSize: Size(double.infinity, spec.buttonHeight.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: loading
              ? SizedBox(
                  width: spec.loaderSize.w,
                  height: spec.loaderSize.w,
                  child: CircularProgressIndicator(
                    color: AppTheme.textSec(context),
                    strokeWidth: spec.loaderStroke,
                  ),
                )
              : Text(
                  'Şifreyi Güncelle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: spec.fontSize.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      );
    });
  }
}