import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';
import '../../../app/themes/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container - responsive boyut
            Container(
              width: 100.w,      // Ekran genişliğine göre
              height: 100.h,     // Ekran yüksekliğine göre
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20.r),  // Responsive radius
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 60.sp,     // Responsive icon boyutu
              ),
            ),
            SizedBox(height: 24.h),  // Responsive yükseklik
            Text(
              'ÜniTV',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 32.sp,     // Responsive font size
                fontWeight: FontWeight.bold,
                letterSpacing: 2.w,   // Responsive harf aralığı
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Üniversite Video Platformu',
              style: TextStyle(
                color: AppTheme.textSec(context), 
                fontSize: 14.sp       // Responsive font size
              ),
            ),
            SizedBox(height: 48.h),
            SizedBox(
              width: 40.r,        // Responsive yükseklik/genişlik
              height: 40.r,
              child: const CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}