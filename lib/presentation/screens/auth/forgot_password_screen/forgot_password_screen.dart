// lib/presentation/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/auth/forgot_password_controller.dart';
import 'forgot_password_layout_spec.dart';
import 'widgets/auth_email_field.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_gradient_button.dart';
import 'widgets/auth_hero_section.dart';

/// "Şifremi unuttum" akışının ilk adımı: kullanıcı email'ini girer,
/// [ForgotPasswordController.sendPasswordResetOtp] çağrılır ve başarılıysa
/// [ResetPasswordScreen]'e yönlendirilir.
class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = ForgotPasswordLayoutSpec.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            AuthHeroSection(
              height: spec.heroHeight,
              iconBoxSize: spec.heroIconBoxSize,
              iconSize: spec.heroIconSize,
              iconRadius: spec.heroIconRadius,
              icon: Icons.lock_reset_rounded,
              title: 'Şifreni mi unuttun?',
              subtitle:
                  'Email adresini gir, sana 6 haneli bir sıfırlama kodu gönderelim.',
              titleFontSize: spec.heroTitleFontSize,
              subtitleFontSize: spec.heroSubtitleFontSize,
              titleSpacing: spec.heroTitleSpacing,
              subtitleSpacing: spec.heroSubtitleSpacing,
              backButtonSize: spec.backButtonSize,
              backButtonPadding: spec.backButtonPadding,
            ),
            _ForgotPasswordFormCard(spec: spec),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordFormCard extends StatefulWidget {
  final ForgotPasswordLayoutSpec spec;
  const _ForgotPasswordFormCard({required this.spec});

  @override
  State<_ForgotPasswordFormCard> createState() =>
      _ForgotPasswordFormCardState();
}

class _ForgotPasswordFormCardState extends State<_ForgotPasswordFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  ForgotPasswordController get _auth => Get.find<ForgotPasswordController>();
  ForgotPasswordLayoutSpec get _spec => widget.spec;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email adresinizi girin.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Geçerli bir email adresi girin.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await _auth.sendPasswordResetOtp(email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final spec = _spec;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.bg(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(spec.cardRadius.r),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              spec.cardPaddingH.w,
              spec.cardPaddingV.h,
              spec.cardPaddingH.w,
              spec.cardPaddingV.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Alan ────────────────────────────
                  AuthEmailField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: 'Email',
                    hintText: 'ornek@comu.edu.tr',
                    fontSize: spec.fieldFontSize,
                    iconSize: spec.fieldIconSize,
                    radius: spec.fieldRadius,
                    paddingH: spec.fieldPaddingH,
                    paddingV: spec.fieldPaddingV,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    validator: _validateEmail,
                    onFieldSubmitted: (_) => _submit(),
                  ).animate().fadeIn(delay: 550.ms, duration: 350.ms),

                  SizedBox(height: spec.cardTopSpacing.h),

                  // ── Server hatası ───────────────────
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

                  // ── Submit ──────────────────────────
                  Obx(
                    () => AuthGradientButton(
                      label: 'Kod Gönder',
                      loading: _auth.isSendingResetOtp.value,
                      onPressed: _submit,
                      height: spec.buttonHeight,
                      radius: spec.buttonRadius,
                      fontSize: spec.buttonFontSize,
                      loaderSize: spec.loaderSize,
                      loaderStroke: spec.loaderStroke,
                    ),
                  ).animate().fadeIn(delay: 620.ms, duration: 350.ms),

                  SizedBox(height: 12.h),

                  // ── Bilgi notu ──────────────────────
                  Center(
                    child: Text(
                      'Kod, kayıtlı email adresinize gönderilir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSec(context).withValues(alpha: 0.7),
                        fontSize: (spec.fieldFontSize - 2).sp,
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 350.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 400.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          curve: Curves.easeOutCubic,
          duration: 500.ms,
        );
  }
}