import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // ── Input Decoration ──────────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final isDark = AppTheme.isDark(context);

    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: AppTheme.textSec(context),
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(prefixIcon, color: AppTheme.primaryColor, size: 22.sp),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? AppTheme.darkBackground.withValues(alpha: 0.6)
          : AppTheme.lightBackground,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

      // ── Enabled Border ──────────────────────────────────────────────
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.12),
          width: 1.2,
        ),
      ),

      // ── Focused Border ──────────────────────────────────────────────
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: AppTheme.primaryColor,
          width: 1.8,
        ),
      ),

      // ── Error Border ────────────────────────────────────────────────
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 1.2,
        ),
      ),

      // ── Focused Error Border ────────────────────────────────────────
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 1.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPri(context),
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Kayıt Ol',
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // ── Header ────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 16.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 36.sp,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              Center(
                child: Text(
                  'Hesap Oluştur',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              Center(
                child: Text(
                  'ÇOMÜ TV\'ye ücretsiz katılın',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(height: 36.h),

              // ── Form Card ─────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppTheme.isDark(context)
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    // ── Kullanıcı Adı ───────────────────────────────────
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 15.sp,
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Kullanıcı adı gerekli' : null,
                      decoration: _inputDecoration(
                        labelText: 'Kullanıcı Adı',
                        prefixIcon: Icons.person_outlined,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Email ───────────────────────────────────────────
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 15.sp,
                      ),
                      validator: (value) =>
                      value!.isEmpty ? 'Email adresi gerekli' : null,
                      decoration: _inputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // ── Şifre ───────────────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 15.sp,
                      ),
                      validator: (value) => value!.length < 6
                          ? 'Şifre en az 6 karakter olmalı'
                          : null,
                      decoration: _inputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTheme.textSec(context),
                            size: 22.sp,
                          ),
                          onPressed: () {
                            setState(
                                    () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // ── Hata Mesajı ───────────────────────────────────────────
              Obx(() => controller.errorMessage.isNotEmpty
                  ? Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: Colors.red.shade400, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink()),

              // ── Kayıt Ol Butonu ───────────────────────────────────────
              Obx(() => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: controller.isLoading.value
                      ? null
                      : const LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: controller.isLoading.value
                      ? []
                      : [
                    BoxShadow(
                      color: AppTheme.primaryColor
                          .withValues(alpha: 0.3),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                    if (_formKey.currentState!.validate()) {
                      controller.signUp(
                        email: _emailController.text,
                        password: _passwordController.text,
                        username: _usernameController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isLoading.value
                        ? AppTheme.surface(context)
                        : Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: AppTheme.surface(context),
                    minimumSize: Size(double.infinity, 54.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      color: AppTheme.textSec(context),
                      strokeWidth: 2.5.w,
                    ),
                  )
                      : Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}