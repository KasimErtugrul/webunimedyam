// lib/presentation/screens/auth/reset_password_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/auth_controller.dart';

/// "Şifremi unuttum" akışının ikinci adımı: kullanıcı email'ine gelen 6
/// haneli kodu ve yeni şifresini girer, [AuthController.confirmPasswordReset]
/// çağrılır. Başarılıysa Login ekranına yönlendirilir.
///
/// Beklenen argüman: `{'email': String}`.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const int _codeLength = 6;

  late final String _email;
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _email = (args?['email'] as String?) ?? '';
    _otpControllers = List.generate(_codeLength, (_) => TextEditingController());
    _otpFocusNodes = List.generate(_codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _codeLength; i++) {
        _otpControllers[i].text = i < digits.length ? digits[i] : '';
      }
      final lastIndex = (digits.length - 1).clamp(0, _codeLength - 1);
      _otpFocusNodes[lastIndex].requestFocus();
      return;
    }
    if (value.isNotEmpty && index < _codeLength - 1) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  void _submit() {
    final controller = Get.find<AuthController>();
    setState(() => _validationError = null);

    if (_otp.length != _codeLength) {
      setState(() => _validationError = 'Lütfen 6 haneli kodu eksiksiz girin.');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      setState(() => _validationError = 'Şifre en az 6 karakter olmalı.');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _validationError = 'Şifreler birbiriyle uyuşmuyor.');
      return;
    }

    FocusScope.of(context).unfocus();
    controller.confirmPasswordReset(
      email: _email,
      otp: _otp,
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
        title: const Text('Şifreni Sıfırla'),
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
                Center(
                  child: Text(
                    _email.isEmpty
                        ? 'Email adresinize gönderilen kodu girin'
                        : '$_email adresine gönderilen kodu girin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_codeLength, (index) {
                    return SizedBox(
                      width: 44.w,
                      height: 56.h,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: _codeLength,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppTheme.isDark(context)
                              ? AppTheme.darkBackground.withValues(alpha: 0.6)
                              : AppTheme.lightBackground,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppTheme.isDark(context)
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1.8,
                            ),
                          ),
                        ),
                        onChanged: (value) => _onDigitChanged(index, value),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: Obx(
                    () {
                      final cooldown = controller.resetResendCooldown.value;
                      final canResend =
                          cooldown == 0 && !controller.isResendingResetOtp.value;
                      return TextButton(
                        onPressed: canResend
                            ? () => controller.resendPasswordResetOtp(email: _email)
                            : null,
                        child: Text(
                          cooldown > 0
                              ? 'Kodu tekrar gönder ($cooldown sn)'
                              : (controller.isResendingResetOtp.value
                                  ? 'Gönderiliyor...'
                                  : 'Kodu tekrar gönder'),
                          style: TextStyle(
                            color: canResend
                                ? AppTheme.primaryColor
                                : AppTheme.textSec(context),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20.h),
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
                    () => controller.errorMessage.isNotEmpty
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
                        : const SizedBox.shrink(),
                  ),
                Obx(
                  () => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: controller.isVerifyingReset.value
                          ? null
                          : const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: controller.isVerifyingReset.value
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
                      onPressed: controller.isVerifyingReset.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isVerifyingReset.value
                            ? AppTheme.surface(context)
                            : Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: AppTheme.surface(context),
                        minimumSize: Size(double.infinity, 54.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: controller.isVerifyingReset.value
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: CircularProgressIndicator(
                                color: AppTheme.textSec(context),
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Şifreyi Sıfırla',
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
