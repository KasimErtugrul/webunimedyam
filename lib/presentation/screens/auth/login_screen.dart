// lib/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/responsive.dart';
import '../../controllers/auth_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Padding
  static const double mainPadding = 24;
  static const double topSpacing = 32;
  static const double welcomeFontSize = 28;
  static const double subtitleFontSize = 14;
  static const double formSpacing = 16;
  static const double fieldSpacing = 40;
  
  // TextField
  static const double fieldFontSize = 14;
  static const double fieldPaddingHorizontal = 12;
  static const double fieldPaddingVertical = 14;
  static const double fieldBorderRadius = 8;
  static const double iconSize = 20;
  
  // Button
  static const double buttonHeight = 48;
  static const double buttonFontSize = 16;
  static const double loadingIndicatorSize = 20;
  static const double loadingStrokeWidth = 2;
  
  // Error
  static const double errorFontSize = 13;
  static const double errorBottomPadding = 16;
  
  // Links
  static const double linkFontSize = 14;
  static const double guestFontSize = 13;
  static const double linkButtonMinWidth = 60;
  static const double linkButtonHeight = 40;
  static const double guestButtonHeight = 40;
}

class _TabletSizes {
  // Padding - tablet için daha büyük
  static const double mainPadding = 40;
  static const double topSpacing = 48;
  static const double welcomeFontSize = 34;
  static const double subtitleFontSize = 16;
  static const double formSpacing = 20;
  static const double fieldSpacing = 50;
  
  // TextField - tablet için daha büyük
  static const double fieldFontSize = 16;
  static const double fieldPaddingHorizontal = 16;
  static const double fieldPaddingVertical = 18;
  static const double fieldBorderRadius = 10;
  static const double iconSize = 24;
  
  // Button - tablet için daha büyük
  static const double buttonHeight = 56;
  static const double buttonFontSize = 18;
  static const double loadingIndicatorSize = 24;
  static const double loadingStrokeWidth = 2.5;
  
  // Error - tablet için daha büyük
  static const double errorFontSize = 15;
  static const double errorBottomPadding = 20;
  
  // Links - tablet için daha büyük
  static const double linkFontSize = 16;
  static const double guestFontSize = 15;
  static const double linkButtonMinWidth = 70;
  static const double linkButtonHeight = 45;
  static const double guestButtonHeight = 45;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

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
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(_PhoneSizes.mainPadding.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: _PhoneSizes.topSpacing.h),
            Text(
              'Hoş Geldiniz',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.welcomeFontSize.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: _PhoneSizes.formSpacing.h),
            Text(
              'ÇOMÜ TV hesabınıza giriş yapın',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.subtitleFontSize.sp,
              ),
            ),
            SizedBox(height: _PhoneSizes.fieldSpacing.h),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.fieldFontSize.sp,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontSize: _PhoneSizes.fieldFontSize.sp),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppTheme.textSec(context),
                  size: _PhoneSizes.iconSize.sp,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.fieldPaddingHorizontal.w,
                  vertical: _PhoneSizes.fieldPaddingVertical.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    _PhoneSizes.fieldBorderRadius.r,
                  ),
                ),
              ),
            ),
            SizedBox(height: _PhoneSizes.formSpacing.h),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.fieldFontSize.sp,
              ),
              decoration: InputDecoration(
                labelText: 'Şifre',
                labelStyle: TextStyle(fontSize: _PhoneSizes.fieldFontSize.sp),
                prefixIcon: Icon(
                  Icons.lock_outlined,
                  color: AppTheme.textSec(context),
                  size: _PhoneSizes.iconSize.sp,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textSec(context),
                    size: _PhoneSizes.iconSize.sp,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.fieldPaddingHorizontal.w,
                  vertical: _PhoneSizes.fieldPaddingVertical.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    _PhoneSizes.fieldBorderRadius.r,
                  ),
                ),
              ),
            ),
            SizedBox(height: _PhoneSizes.formSpacing.h),
            Obx(() => controller.errorMessage.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(
                      bottom: _PhoneSizes.errorBottomPadding.h,
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: _PhoneSizes.errorFontSize.sp,
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(
                        double.infinity,
                        _PhoneSizes.buttonHeight.h,
                      ),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.signIn(
                              email: _emailController.text,
                              password: _passwordController.text,
                            ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: _PhoneSizes.loadingIndicatorSize.w,
                            height: _PhoneSizes.loadingIndicatorSize.h,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
                            ),
                          )
                        : Text(
                            'Giriş Yap',
                            style: TextStyle(
                              fontSize: _PhoneSizes.buttonFontSize.sp,
                            ),
                          ),
                  ),
                )),
            SizedBox(height: _PhoneSizes.formSpacing.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hesabınız yok mu?',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.linkFontSize.sp,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  style: TextButton.styleFrom(
                    minimumSize: Size(
                      _PhoneSizes.linkButtonMinWidth.w,
                      _PhoneSizes.linkButtonHeight.h,
                    ),
                  ),
                  child: Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: _PhoneSizes.linkFontSize.sp,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.home),
              style: TextButton.styleFrom(
                minimumSize: Size(double.infinity, _PhoneSizes.guestButtonHeight.h),
              ),
              child: Text(
                'Şimdi değil, misafir olarak devam et',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.guestFontSize.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_TabletSizes.mainPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _TabletSizes.topSpacing),
                Text(
                  'Hoş Geldiniz',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.welcomeFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: _TabletSizes.formSpacing),
                Text(
                  'ÇOMÜ TV hesabınıza giriş yapın',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.subtitleFontSize,
                  ),
                ),
                SizedBox(height: _TabletSizes.fieldSpacing),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.fieldFontSize,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      fontSize: _TabletSizes.fieldFontSize,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppTheme.textSec(context),
                      size: _TabletSizes.iconSize,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: _TabletSizes.fieldPaddingHorizontal,
                      vertical: _TabletSizes.fieldPaddingVertical,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        _TabletSizes.fieldBorderRadius,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: _TabletSizes.formSpacing),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.fieldFontSize,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    labelStyle: TextStyle(
                      fontSize: _TabletSizes.fieldFontSize,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      color: AppTheme.textSec(context),
                      size: _TabletSizes.iconSize,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textSec(context),
                        size: _TabletSizes.iconSize,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: _TabletSizes.fieldPaddingHorizontal,
                      vertical: _TabletSizes.fieldPaddingVertical,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        _TabletSizes.fieldBorderRadius,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: _TabletSizes.formSpacing),
                Obx(() => controller.errorMessage.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                          bottom: _TabletSizes.errorBottomPadding,
                        ),
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: _TabletSizes.errorFontSize,
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            _TabletSizes.buttonHeight,
                          ),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.signIn(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: _TabletSizes.loadingIndicatorSize,
                                height: _TabletSizes.loadingIndicatorSize,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: _TabletSizes.loadingStrokeWidth,
                                ),
                              )
                            : Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: _TabletSizes.buttonFontSize,
                                ),
                              ),
                      ),
                    )),
                SizedBox(height: _TabletSizes.formSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hesabınız yok mu?',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _TabletSizes.linkFontSize,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      style: TextButton.styleFrom(
                        minimumSize: Size(
                          _TabletSizes.linkButtonMinWidth,
                          _TabletSizes.linkButtonHeight,
                        ),
                      ),
                      child: Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: _TabletSizes.linkFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  style: TextButton.styleFrom(
                    minimumSize: Size(
                      double.infinity,
                      _TabletSizes.guestButtonHeight,
                    ),
                  ),
                  child: Text(
                    'Şimdi değil, misafir olarak devam et',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.guestFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
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