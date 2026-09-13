// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../controllers/auth/login_controller.dart';
import 'login_layout_spec.dart';
import 'widgets/login_email_field.dart';
import 'widgets/login_error_banner.dart';
import 'widgets/login_footer_links.dart';
import 'widgets/login_google_button.dart';
import 'widgets/login_hero_section.dart';
import 'widgets/login_or_divider.dart';
import 'widgets/login_password_field.dart';
import 'widgets/login_submit_button.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = LoginLayoutSpec.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            LoginHeroSection(spec: spec),
            _LoginFormCard(spec: spec),
          ],
        ),
      ),
    );
  }
}

class _LoginFormCard extends StatefulWidget {
  final LoginLayoutSpec spec;
  const _LoginFormCard({required this.spec});

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  LoginController get _auth => Get.find<LoginController>();
  LoginLayoutSpec get _spec => widget.spec;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await _auth.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
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
                  // ── Başlık ────────────────────────────
                  Text(
                    'Hoş Geldiniz',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: spec.welcomeFontSize.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 350.ms),

                  SizedBox(height: 4.h),

                  Text(
                    'Hesabınıza giriş yapın',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: spec.subtitleFontSize.sp,
                    ),
                  ).animate().fadeIn(delay: 480.ms, duration: 350.ms),

                  SizedBox(height: spec.cardTopSpacing.h),

                  // ── Email ─────────────────────────────
                  LoginEmailField(
                    controller: _emailController,
                    spec: spec,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ).animate().fadeIn(delay: 550.ms, duration: 350.ms),

                  SizedBox(height: spec.formSpacing.h),

                  // ── Şifre ─────────────────────────────
                  LoginPasswordField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    spec: spec,
                    obscure: _obscurePassword,
                    onToggleObscure: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    onSubmitted: (_) => _submit(),
                  ).animate().fadeIn(delay: 620.ms, duration: 350.ms),

                  // ── Şifremi unuttum ───────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        minimumSize: Size(0, 32.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Şifremi unuttum',
                        style: TextStyle(
                          fontSize: spec.linkFontSize.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 680.ms, duration: 350.ms),

                  SizedBox(height: spec.fieldSpacing.h * 0.5),

                  // ── Hata mesajı ───────────────────────
                  LoginErrorBanner(spec: spec),

                  // ── Giriş butonu ──────────────────────
                  LoginSubmitButton(spec: spec, onPressed: _submit)
                      .animate()
                      .fadeIn(delay: 750.ms, duration: 350.ms),

                  SizedBox(height: spec.cardTopSpacing.h),

                  // ── Divider ───────────────────────────
                  LoginOrDivider(fontSize: spec.linkFontSize.sp)
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 350.ms),

                  SizedBox(height: spec.cardTopSpacing.h),

                  // ── Google ────────────────────────────
                  LoginGoogleButton(spec: spec)
                      .animate()
                      .fadeIn(delay: 850.ms, duration: 350.ms),

                  SizedBox(height: spec.cardTopSpacing.h),

                  // ── Footer linkler ────────────────────
                  LoginFooterLinks(spec: spec)
                      .animate()
                      .fadeIn(delay: 920.ms, duration: 350.ms),

                  SizedBox(height: 8.h),
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