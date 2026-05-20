import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giriş Yap',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            Text(
              'Hoş Geldiniz',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ÇOMÜ TV hesabınıza giriş yapın',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 40.h),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppTheme.textSec(context),
                  size: 20.sp,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                labelText: 'Şifre',
                labelStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(
                  Icons.lock_outlined,
                  color: AppTheme.textSec(context),
                  size: 20.sp,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textSec(context),
                    size: 20.sp,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Obx(() => controller.errorMessage.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13.sp,
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48.h),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.signIn(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.w,
                            ),
                          )
                        : Text(
                            'Giriş Yap',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                  ),
                )),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hesabınız yok mu?',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 14.sp,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  style: TextButton.styleFrom(
                    minimumSize: Size(60.w, 40.h),
                  ),
                  child: Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.home),
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, 40.h),
              ),
              child: Text(
                'Şimdi değil, misafir olarak devam et',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}