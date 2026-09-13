// lib/presentation/screens/auth/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/auth/change_password_controller.dart';
import 'change_password_layout_spec.dart';
import 'widgets/change_password_error_banner.dart';
import 'widgets/change_password_field.dart';
import 'widgets/change_password_submit_button.dart';

/// Oturum açık kullanıcının şifresini değiştirdiği ekran.
/// Ayarlar → Hesap → "Şifre Değiştir" üzerinden açılır.
class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = ChangePasswordLayoutSpec.of(context);
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
          onPressed: Get.back,
        ),
        title: const Text('Şifre Değiştir'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
          child: const _ChangePasswordForm(),
        ),
      ),
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm();

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  final _currentFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  ChangePasswordController get _auth => Get.find<ChangePasswordController>();

  @override
  void initState() {
    super.initState();
    _auth.resetState();
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _currentFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    await _auth.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
  }

  // ── Validators ─────────────────────────────────────────
  String? _validateCurrent(String? value) {
    if (value == null || value.isEmpty) return 'Mevcut şifrenizi girin.';
    return null;
  }

  String? _validateNew(String? value) {
    final v = value ?? '';
    if (v.length < 6) return 'Yeni şifre en az 6 karakter olmalı.';
    if (v == _currentController.text) {
      return 'Yeni şifre eskisiyle aynı olamaz.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _newController.text) {
      return 'Yeni şifreler birbiriyle uyuşmuyor.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final spec = ChangePasswordLayoutSpec.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: spec.horizontalPadding.w,
        vertical: spec.verticalPadding.h,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: spec.topSpacing.h),

            ChangePasswordField(
              controller: _currentController,
              focusNode: _currentFocus,
              spec: spec,
              label: 'Mevcut Şifre',
              obscure: _obscureCurrent,
              autofillHint: AutofillHints.password,
              onToggleObscure: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              validator: _validateCurrent,
              onFieldSubmitted: (_) => _newFocus.requestFocus(),
            ),
            SizedBox(height: spec.fieldSpacing.h),

            ChangePasswordField(
              controller: _newController,
              focusNode: _newFocus,
              spec: spec,
              label: 'Yeni Şifre',
              obscure: _obscureNew,
              autofillHint: AutofillHints.newPassword,
              onToggleObscure: () =>
                  setState(() => _obscureNew = !_obscureNew),
              validator: _validateNew,
              onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
            ),
            SizedBox(height: spec.fieldSpacing.h),

            ChangePasswordField(
              controller: _confirmController,
              focusNode: _confirmFocus,
              spec: spec,
              label: 'Yeni Şifre (Tekrar)',
              obscure: _obscureConfirm,
              autofillHint: AutofillHints.newPassword,
              textInputAction: TextInputAction.done,
              onToggleObscure: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: _validateConfirm,
              onFieldSubmitted: (_) => _submit(),
            ),

            SizedBox(height: spec.sectionSpacing.h),

            // Server hatası (client validator'lar geçtikten sonra)
            Obx(() {
              final msg = _auth.errorMessage.value;
              if (msg.isEmpty) return const SizedBox.shrink();
              return ChangePasswordErrorBanner(message: msg, spec: spec);
            }),

            ChangePasswordSubmitButton(spec: spec, onPressed: _submit),
            SizedBox(height: spec.bottomSpacing.h),
          ],
        ),
      ),
    );
  }
}