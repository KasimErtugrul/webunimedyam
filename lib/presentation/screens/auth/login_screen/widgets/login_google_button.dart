// lib/presentation/screens/auth/widgets/login_google_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/auth/login_controller.dart';
import '../login_layout_spec.dart';

class LoginGoogleButton extends GetView<LoginController> {
  final LoginLayoutSpec spec;
  const LoginGoogleButton({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isGoogleLoading.value;
      final border = AppTheme.textSec(context).withValues(alpha: 0.2);

      return SizedBox(
        width: double.infinity,
        height: spec.buttonHeight.h,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textPri(context),
            side: BorderSide(color: border, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(spec.buttonRadius.r),
            ),
            backgroundColor: AppTheme.surface(context).withValues(alpha: 0.5),
          ),
          onPressed: loading ? null : controller.signInWithGoogle,
          child: loading
              ? SizedBox(
                  width: spec.loaderSize.w,
                  height: spec.loaderSize.w,
                  child: CircularProgressIndicator(
                    strokeWidth: spec.loaderStroke,
                    color: AppTheme.textSec(context),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/google_logo.png',
                      width: spec.iconSize.w,
                      height: spec.iconSize.w,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.g_mobiledata_rounded,
                        size: (spec.iconSize + 4).sp,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Google ile devam et',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: spec.buttonFontSize.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}