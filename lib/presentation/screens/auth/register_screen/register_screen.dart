// lib/presentation/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/auth/register_controller.dart';
import '../forgot_password_screen/widgets/auth_error_banner.dart';
import '../forgot_password_screen/widgets/auth_gradient_button.dart';
import '../otp_verification_screen/widgets/auth_header_icon.dart';
import '../otp_verification_screen/widgets/auth_scaffold.dart';
import 'register_layout_spec.dart';
import 'widgets/auth_form_card.dart';
import 'widgets/auth_password_field.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends GetView<RegisterController > {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = RegisterLayoutSpec.of(context);
    return AuthScaffold(
      title: 'Kayıt Ol',
      maxContentWidth: spec.maxContentWidth,
      horizontalPadding: spec.horizontalPadding,
      verticalPadding: spec.topSpacing,
      bottomPadding: spec.bottomSpacing,
      child: const _RegisterForm(),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  RegisterController  get _auth => Get.find<RegisterController >();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ── Validators ─────────────────────────────────────────
  String? _validateUsername(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Kullanıcı adı gerekli';
    if (v.length < 3) return 'Kullanıcı adı en az 3 karakter olmalı';
    if (v.length > 20) return 'Kullanıcı adı en fazla 20 karakter olmalı';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email adresi gerekli';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Geçerli bir email adresi girin';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) return 'Şifre en az 6 karakter olmalı';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await _auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spec = RegisterLayoutSpec.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero ─────────────────────────────────────
          AuthHeaderIcon(
            icon: Icons.person_add_rounded,
            size: spec.heroSize,
            iconSize: spec.heroIconSize,
            radius: spec.heroRadius,
          ),

          // ── Başlık / alt başlık ──────────────────────
          SizedBox(height: spec.headerSpacing.h),
          Text(
            'Hesap Oluştur',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: spec.titleFontSize.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spec.subtitleSpacing.h),
          Text(
            'ÇOMÜ TV\'ye ücretsiz katılın',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: spec.subtitleFontSize.sp,
            ),
          ),
          SizedBox(height: spec.headerSpacing.h),

          // ── Form kartı ───────────────────────────────
          AuthFormCard(
            padding: spec.cardPadding,
            radius: spec.cardRadius,
            child: Column(
              children: [
                AuthTextField(
                  controller: _usernameController,
                  focusNode: _usernameFocus,
                  label: 'Kullanıcı Adı',
                  prefixIcon: Icons.person_outlined,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  validator: _validateUsername,
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                  fontSize: spec.fieldFontSize,
                  iconSize: spec.fieldIconSize,
                  radius: spec.fieldRadius,
                  paddingH: spec.fieldPaddingH,
                  paddingV: spec.fieldPaddingV,
                ),
                SizedBox(height: spec.fieldSpacing.h),
                AuthTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  enableSuggestions: false,
                  autocorrect: false,
                  validator: _validateEmail,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                  fontSize: spec.fieldFontSize,
                  iconSize: spec.fieldIconSize,
                  radius: spec.fieldRadius,
                  paddingH: spec.fieldPaddingH,
                  paddingV: spec.fieldPaddingV,
                ),
                SizedBox(height: spec.fieldSpacing.h),
                AuthPasswordField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  label: 'Şifre',
                  obscure: _obscurePassword,
                  autofillHint: AutofillHints.newPassword,
                  textInputAction: TextInputAction.done,
                  onToggleObscure: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _submit(),
                  fontSize: spec.fieldFontSize,
                  iconSize: spec.fieldIconSize,
                  radius: spec.fieldRadius,
                  paddingH: spec.fieldPaddingH,
                  paddingV: spec.fieldPaddingV,
                ),
              ],
            ),
          ),

          SizedBox(height: spec.fieldSpacing.h),

          // ── Server hatası ────────────────────────────
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

          // ── Submit ───────────────────────────────────
          Obx(
            () => AuthGradientButton(
              label: 'Kayıt Ol',
              loading: _auth.isLoading.value,
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