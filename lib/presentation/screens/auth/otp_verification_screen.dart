// lib/presentation/screens/auth/otp_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/auth_controller.dart';

/// Kayıt (signup) sonrası kullanıcının email'ine gönderilen 6 haneli OTP
/// kodunu doğrulattığımız ekran. `register_screen.dart` ile aynı görsel
/// dili (AppTheme, gradient header ikonu, kart, hata kutusu, gradient
/// buton) kullanır.
///
/// Beklenen argüman: `{'email': String}` — `AppRoutes.otpVerification`'a
/// `Get.toNamed` ile bu şekilde gönderilir (bkz. AuthController.signUp).
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _codeLength = 6;

  late final String _email;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _email = (args?['email'] as String?) ?? '';
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    // Kullanıcı tüm kodu tek bir kutuya yapıştırırsa (paste), kodu
    // kutulara dağıt.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _codeLength; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final lastIndex = (digits.length - 1).clamp(0, _codeLength - 1);
      _focusNodes[lastIndex].requestFocus();
      if (digits.length >= _codeLength) {
        FocusScope.of(context).unfocus();
        _submit();
      }
      return;
    }

    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_code.length == _codeLength) {
      FocusScope.of(context).unfocus();
      _submit();
    }
  }

  void _submit() {
    final controller = Get.find<AuthController>();
    if (_code.length != _codeLength) return;
    controller.verifyOtp(email: _email, otp: _code);
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
        title: const Text('Email Onayı'),
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
                      Icons.mark_email_read_outlined,
                      color: Colors.white,
                      size: 36.sp,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Center(
                  child: Text(
                    'Kodu Girin',
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
                    _email.isEmpty
                        ? 'Email adresinize gönderilen 6 haneli kodu girin'
                        : '$_email adresine gönderilen 6 haneli kodu girin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_codeLength, (index) {
                    return SizedBox(
                      width: 44.w,
                      height: 56.h,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: _codeLength, // paste desteği için
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
                SizedBox(height: 20.h),
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
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red.shade400,
                                size: 20.sp,
                              ),
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
                      gradient: controller.isVerifyingOtp.value
                          ? null
                          : const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            ),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: controller.isVerifyingOtp.value
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
                      onPressed: controller.isVerifyingOtp.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isVerifyingOtp.value
                            ? AppTheme.surface(context)
                            : Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: AppTheme.surface(context),
                        minimumSize: Size(double.infinity, 54.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: controller.isVerifyingOtp.value
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: CircularProgressIndicator(
                                color: AppTheme.textSec(context),
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Doğrula',
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
                Center(
                  child: Obx(
                    () {
                      final cooldown = controller.resendCooldown.value;
                      final canResend = cooldown == 0 && !controller.isResendingOtp.value;
                      return TextButton(
                        onPressed: canResend
                            ? () => controller.resendOtp(email: _email)
                            : null,
                        child: Text(
                          cooldown > 0
                              ? 'Kodu tekrar gönder ($cooldown sn)'
                              : (controller.isResendingOtp.value
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
