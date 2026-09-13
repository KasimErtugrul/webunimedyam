// lib/presentation/screens/auth/widgets/login_footer_links.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../login_layout_spec.dart';

class LoginFooterLinks extends StatelessWidget {
  final LoginLayoutSpec spec;
  const LoginFooterLinks({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hesabınız yok mu?',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: spec.linkFontSize.sp,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.register),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              child: Text(
                'Kayıt Ol',
                style: TextStyle(
                  fontSize: spec.linkFontSize.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        TextButton(
          onPressed: () => Get.offAllNamed(AppRoutes.home),
          style: TextButton.styleFrom(
            minimumSize: Size(double.infinity, 40.h),
            foregroundColor: AppTheme.textSec(context),
          ),
          child: Text(
            'Şimdi değil, misafir olarak devam et',
            style: TextStyle(
              fontSize: spec.guestFontSize.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}