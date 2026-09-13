// lib/presentation/screens/auth/widgets/login_submit_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/auth/login_controller.dart';
import '../login_layout_spec.dart';

class LoginSubmitButton extends GetView<LoginController> {
  final LoginLayoutSpec spec;
  final VoidCallback onPressed;

  const LoginSubmitButton({
    super.key,
    required this.spec,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value;
      final primary = AppTheme.primaryColor;

      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: loading
              ? null
              : const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: loading ? AppTheme.surface(context) : null,
          borderRadius: BorderRadius.circular(spec.buttonRadius.r),
          boxShadow: loading
              ? const []
              : [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            minimumSize: Size(double.infinity, spec.buttonHeight.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(spec.buttonRadius.r),
            ),
          ),
          onPressed: loading ? null : onPressed,
          child: loading
              ? SizedBox(
                  width: spec.loaderSize.w,
                  height: spec.loaderSize.w,
                  child: CircularProgressIndicator(
                    color: AppTheme.textSec(context),
                    strokeWidth: spec.loaderStroke,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Giriş Yap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: spec.buttonFontSize.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: (spec.buttonFontSize + 2).sp,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}