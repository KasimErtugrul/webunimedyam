// lib/presentation/screens/auth/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/auth_controller.dart';

/// Oturum açık kullanıcının şifresini değiştirdiği ekran. Ayarlar →
/// Hesap → "Şifre Değiştir" üzerinden açılır.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().resetChangePasswordState();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final controller = Get.find<AuthController>();
    setState(() => _validationError = null);

    if (_currentPasswordController.text.isEmpty) {
      setState(() => _validationError = 'Mevcut şifrenizi girin.');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      setState(() => _validationError = 'Yeni şifre en az 6 karakter olmalı.');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _validationError = 'Yeni şifreler birbiriyle uyuşmuyor.');
      return;
    }
    if (_newPasswordController.text == _currentPasswordController.text) {
      setState(() => _validationError = 'Yeni şifre eskisiyle aynı olamaz.');
      return;
    }

    FocusScope.of(context).unfocus();
    controller.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final isTablet = Responsive.isTablet(context);

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
        title: const Text('Şifre Değiştir'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 520 : double.infinity),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 12.h),
                TextField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
                  decoration: InputDecoration(
                    labelText: 'Mevcut Şifre',
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSec(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSec(context),
                      ),
                      onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
                  decoration: InputDecoration(
                    labelText: 'Yeni Şifre',
                    prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.textSec(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSec(context),
                      ),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
                  decoration: InputDecoration(
                    labelText: 'Yeni Şifre (Tekrar)',
                    prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.textSec(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSec(context),
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 20.h),
                if (_validationError != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            _validationError!,
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
                else
                  Obx(
                    () => controller.changePasswordError.isNotEmpty
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14.w),
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    color: Colors.red.shade400, size: 20.sp),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    controller.changePasswordError.value,
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
                        : const SizedBox.shrink(),
                  ),
                Obx(
                  () => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: controller.isChangingPassword.value
                          ? null
                          : const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: controller.isChangingPassword.value
                          ? []
                          : [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 12.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: controller.isChangingPassword.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isChangingPassword.value
                            ? AppTheme.surface(context)
                            : Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: AppTheme.surface(context),
                        minimumSize: Size(double.infinity, 54.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: controller.isChangingPassword.value
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: CircularProgressIndicator(
                                color: AppTheme.textSec(context),
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Şifreyi Güncelle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
