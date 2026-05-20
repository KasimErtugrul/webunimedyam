import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../controllers/profile_controller.dart';
import 'widgets/profile_view_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 3.w,
            ),
          ),
        );
      }

      if (!controller.isLoggedIn) {
        return _NotLoggedInView();
      }

      return ProfileViewWidget(controller: controller);
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Giriş yapılmamış ekranı
// ═══════════════════════════════════════════════════════════════════════════

class _NotLoggedInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96.w,
                height: 96.h,
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 2.w,
                  ),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Hesabına Giriş Yap',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Favorilerini, izleme geçmişini ve tüm aktivitelerini\ngörmek için giriş yap.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 36.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  child: Text(
                    'Giriş Yap',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPri(context),
                    side: BorderSide(
                      color: AppTheme.surface(context),
                      width: 1.w,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  child: Text(
                    'Kayıt Ol',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}