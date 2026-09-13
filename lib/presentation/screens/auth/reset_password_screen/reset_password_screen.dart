// lib/presentation/screens/auth/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/auth/reset_password_controller.dart';
import '../forgot_password_screen/widgets/auth_error_banner.dart';
import '../forgot_password_screen/widgets/auth_gradient_button.dart';
import '../otp_verification_screen/widgets/auth_scaffold.dart';
import '../otp_verification_screen/widgets/otp_resend_button.dart';
import '../register_screen/widgets/auth_password_field.dart';
import 'reset_password_layout_spec.dart';

import 'widgets/otp_code_input.dart';

/// "Şifremi unuttum" akışının ikinci adımı: kullanıcı email'ine gelen 6
/// haneli kodu ve yeni şifresini girer, [ResetPasswordController.confirmPasswordReset]
/// çağrılır. Başarılıysa Login ekranına yönlendirilir.
///
/// Beklenen argüman: `{'email': String}`.
class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = ResetPasswordLayoutSpec.of(context);
    return AuthScaffold(
      title: 'Şifreni Sıfırla',
      maxContentWidth: spec.maxContentWidth,
      horizontalPadding: spec.horizontalPadding,
      verticalPadding: spec.verticalPadding,
      bottomPadding: spec.bottomPadding,
      child: const _ResetPasswordForm(),
    );
  }
}

class _ResetPasswordForm extends StatefulWidget {
  const _ResetPasswordForm();

  @override
  State<_ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<_ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<OtpCodeInputState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  /// OTP validasyonu (FormField olmadığı için ayrı tutulur).
  String? _otpError;
  bool _submitting = false;

  late final String _email;

  ResetPasswordController get _auth => Get.find<ResetPasswordController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _email = (args?['email'] as String?)?.trim() ?? '';
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  // ── Validators ─────────────────────────────────────────
  String? _validateNewPassword(String? value) {
    final v = value ?? '';
    if (v.length < 6) return 'Şifre en az 6 karakter olmalı.';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _newPasswordController.text) {
      return 'Şifreler birbiriyle uyuşmuyor.';
    }
    return null;
  }

  bool _validateOtp() {
    final code = _otpKey.currentState?.code ?? '';
    if (code.length != OtpCodeInput.length) {
      setState(() => _otpError = 'Lütfen 6 haneli kodu eksiksiz girin.');
      return false;
    }
    setState(() => _otpError = null);
    return true;
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final otpOk = _validateOtp();
    final formOk = _formKey.currentState?.validate() ?? false;

    if (!otpOk || !formOk) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    try {
      await _auth.confirmPasswordReset(
        email: _email,
        otp: _otpKey.currentState!.code,
        newPassword: _newPasswordController.text,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = ResetPasswordLayoutSpec.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Açıklama ─────────────────────────────────
          if (spec.subtitleTopSpacing > 0)
            SizedBox(height: spec.subtitleTopSpacing.h),
          Text(
            _email.isEmpty
                ? 'Email adresinize gönderilen kodu girin'
                : '$_email adresine gönderilen kodu girin',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: spec.subtitleFontSize.sp,
            ),
          ),

          // ── OTP kutuları ─────────────────────────────
          SizedBox(height: spec.otpTopSpacing.h),
          OtpCodeInput(
            key: _otpKey,
            spec: spec.otpSpec,
            // onCompleted yok → reset ekranında otomatik submit istemiyoruz
          ),

          // ── Resend ───────────────────────────────────
          SizedBox(height: spec.resendTopSpacing.h),
          Obx(
            () => OtpResendButton(
              cooldownSeconds: _auth.resetResendCooldown.value,
              isLoading: _auth.isResendingResetOtp.value,
              onResend: () => _auth.resendPasswordResetOtp(email: _email),
              fontSize: spec.resendFontSize,
            ),
          ),

          // ── Yeni şifreler ────────────────────────────
          SizedBox(height: spec.passwordsTopSpacing.h),
          AuthPasswordField(
            controller: _newPasswordController,
            focusNode: _newPasswordFocus,
            label: 'Yeni Şifre',
            obscure: _obscureNew,
            autofillHint: AutofillHints.newPassword,
            textInputAction: TextInputAction.next,
            onToggleObscure: () =>
                setState(() => _obscureNew = !_obscureNew),
            validator: _validateNewPassword,
            onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
            fontSize: spec.fieldFontSize,
            iconSize: spec.fieldIconSize,
            radius: spec.fieldRadius,
            paddingH: spec.fieldPaddingH,
            paddingV: spec.fieldPaddingV,
          ),
          SizedBox(height: spec.fieldSpacing.h),
          AuthPasswordField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            label: 'Yeni Şifre (Tekrar)',
            obscure: _obscureConfirm,
            autofillHint: AutofillHints.newPassword,
            textInputAction: TextInputAction.done,
            onToggleObscure: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            validator: _validateConfirm,
            onFieldSubmitted: (_) => _submit(),
            fontSize: spec.fieldFontSize,
            iconSize: spec.fieldIconSize,
            radius: spec.fieldRadius,
            paddingH: spec.fieldPaddingH,
            paddingV: spec.fieldPaddingV,
          ),

          SizedBox(height: spec.errorTopSpacing.h),

          // ── Hata mesajı (client OTP + server birleşik) ─
          Obx(() {
            // Öncelik: client OTP hatası → server hatası
            final clientError = _otpError;
            final serverError = _auth.errorMessage.value;
            final message = clientError ?? serverError;
            if (message.isEmpty) return const SizedBox.shrink();

            return AuthErrorBanner(
              message: message,
              fontSize: spec.errorFontSize,
              padding: spec.errorPadding,
              radius: spec.errorRadius,
              iconSize: spec.errorIconSize,
              marginBottom: spec.errorMarginBottom,
            );
          }),

          // ── Submit ───────────────────────────────────
          Obx(
            () => AuthGradientButton(
              label: 'Şifreyi Sıfırla',
              loading: _auth.isVerifyingReset.value || _submitting,
              onPressed: _submit,
              height: spec.buttonHeight,
              radius: spec.buttonRadius,
              fontSize: spec.buttonFontSize,
              loaderSize: spec.loaderSize,
              loaderStroke: spec.loaderStroke,
            ),
          ),
        ],
      ),
    );
  }
}