// lib/presentation/screens/auth/widgets/login_error_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../controllers/auth/login_controller.dart';
import '../login_layout_spec.dart';

class LoginErrorBanner extends GetView<LoginController> {
  final LoginLayoutSpec spec;
  const LoginErrorBanner({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.errorMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();

      final red = Colors.red.shade400;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(spec.errorPadding.w),
        margin: EdgeInsets.only(bottom: spec.formSpacing.h),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(spec.errorRadius.r),
          border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: red, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  color: red,
                  fontSize: spec.errorFontSize.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 250.ms)
          .slideY(begin: -0.15, end: 0, curve: Curves.easeOut);
    });
  }
}