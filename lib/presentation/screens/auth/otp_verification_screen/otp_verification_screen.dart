// lib/presentation/screens/auth/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../../../app/themes/app_theme.dart';
import '../../../controllers/auth/otp_verification_controller.dart';
import '../forgot_password_screen/widgets/auth_error_banner.dart';
import '../forgot_password_screen/widgets/auth_gradient_button.dart';
import 'otp_verification_layout_spec.dart';

import 'widgets/auth_header_icon.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/otp_code_input.dart';
import 'widgets/otp_resend_button.dart';

/// Kayıt sonrası email'e gönderilen 6 haneli OTP'yi doğruladığımız ekran.
///
/// Beklenen argüman: `{'email': String}`.
class OtpVerificationScreen extends GetView<OtpVerificationController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = OtpVerificationLayoutSpec.of(context);
    return AuthScaffold(
      title: 'Email Onayı',
      maxContentWidth: spec.maxContentWidth,
      horizontalPadding: spec.horizontalPadding,
      verticalPadding: spec.verticalPadding,
      bottomPadding: spec.bottomPadding,
      child: const _OtpForm(),
    );
  }
}

class _OtpForm extends StatefulWidget {
  const _OtpForm();

  @override
  State<_OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<_OtpForm> {
  final _otpKey = GlobalKey<OtpCodeInputState>();
  late final String _email;
  bool _submitting = false;

  OtpVerificationController get _auth => Get.find<OtpVerificationController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _email = (args?['email'] as String?)?.trim() ?? '';
  }

  Future<void> _submit(String code) async {
    if (_submitting) return;
    if (code.length != OtpCodeInput.length) return;

    setState(() => _submitting = true);
    try {
      await _auth.verifyOtp(email: _email, otp: code);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = OtpVerificationLayoutSpec.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Hero ikon ────────────────────────────────
        AuthHeaderIcon(
          icon: Icons.mark_email_read_outlined,
          size: spec.heroSize,
          iconSize: spec.heroIconSize,
          radius: spec.heroRadius,
        ),

        // ── Başlık ───────────────────────────────────
        SizedBox(height: spec.titleTopSpacing.h),
        Text(
          'Kodu Girin',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: spec.titleFontSize.sp,
            fontWeight: FontWeight.bold,
          ),
        ),

        // ── Alt başlık ───────────────────────────────
        SizedBox(height: spec.subtitleTopSpacing.h),
        Text(
          _email.isEmpty
              ? 'Email adresinize gönderilen 6 haneli kodu girin'
              : '$_email adresine gönderilen 6 haneli kodu girin',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: spec.subtitleFontSize.sp,
          ),
        ),

        // ── OTP kutuları ─────────────────────────────
        SizedBox(height: spec.formTopSpacing.h),
        OtpCodeInput(
          key: _otpKey,
          spec: spec,
          onCompleted: _submit,
        ),

        // ── Server hatası ────────────────────────────
        SizedBox(height: spec.buttonTopSpacing.h),
        Obx(() {
          final msg = _auth.errorMessage.value;
          if (msg.isEmpty) return const SizedBox.shrink();
          return AuthErrorBanner(
            message: msg,
            fontSize: spec.errorFontSize,
            padding: spec.errorPadding,
            radius: spec.errorRadius,
            iconSize: spec.errorIconSize,
            marginBottom: spec.errorMarginBottom,
          );
        }),

        // ── Doğrula ──────────────────────────────────
        Obx(
          () => AuthGradientButton(
            label: 'Doğrula',
            loading: _auth.isVerifyingOtp.value || _submitting,
            onPressed: () => _submit(_otpKey.currentState?.code ?? ''),
            height: spec.buttonHeight,
            radius: spec.buttonRadius,
            fontSize: spec.buttonFontSize,
            loaderSize: spec.loaderSize,
            loaderStroke: spec.loaderStroke,
          ),
        ),

       // ── Yeniden gönder ───────────────────────────
SizedBox(height: spec.resendTopSpacing.h),
Obx(
  () => OtpResendButton(
    cooldownSeconds: _auth.resendCooldown.value,
    isLoading: _auth.isResendingOtp.value,
    onResend: () => _auth.resendOtp(email: _email),
    fontSize: spec.resendFontSize,
  ),
),
      ],
    );
  }
}