// lib/presentation/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../controllers/auth/register_controller.dart';
import '../forgot_password_screen/widgets/auth_error_banner.dart';
import 'register_layout_spec.dart';
import 'widgets/register_campus_card.dart';
import 'widgets/register_campus_preview.dart';
import 'widgets/register_email_field.dart';
import 'widgets/register_footer_links.dart';
import 'widgets/register_footer_strip.dart';
import 'widgets/register_header.dart';
import 'widgets/register_password_field.dart';
import 'widgets/register_submit_button.dart';
import 'widgets/register_terms_checkbox.dart';
import 'widgets/register_top_bar.dart';
import 'widgets/register_username_field.dart';

// ═══════════════════════════════════════════════════════════
// REGISTER SCREEN — Stitch "Register - ÜniTV" tasarımının bire
// bir karşılığı. Tüm renkler AppTheme/ColorScheme üzerinden
// geldiği için light & dark tema otomatik desteklenir.
// ═══════════════════════════════════════════════════════════

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    final RegisterSizes sizes = Responsive.isTablet(context)
        ? const RegisterTabletSizes()
        : const RegisterPhoneSizes();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: sizes.maxContentWidth),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: sizes.pageHPadding,
                right: sizes.pageHPadding,
                bottom: sizes.pageBottomPadding,
              ),
              child: _RegisterForm(sizes: sizes),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({required this.sizes});

  final RegisterSizes sizes;

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
  bool _termsAccepted = false;

  // Tasarımdaki Akademik Durum kartının yerel durumu
  String _selectedStatus = 'Öğrenci';
  String? _selectedUniversity;

  RegisterController get _auth => Get.find<RegisterController>();
  RegisterSizes get _s => widget.sizes;

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
    if (v.isEmpty) return 'E-posta adresi gerekli';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Geçerli bir e-posta adresi girin';
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
    // Not: _selectedStatus / _selectedUniversity kayıt payload'ına
    // eklenecekse RegisterController.signUp'a parametre olarak geçirin.
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = _s;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Navigation / Back Bar ─────────────────
          RegisterTopBar(sizes: s),

          // ── Header & Dynamic Intro ────────────────────
          SizedBox(height: s.headerTopGap),
          RegisterHeader(sizes: s),

          // ── Campus Atmosphere Preview Pill Badge ──────
          RegisterCampusPreview(sizes: s),

          // ── Registration Form (gap-space-md) ──────────
          // Username Field
          RegisterUsernameField(
            controller: _usernameController,
            focusNode: _usernameFocus,
            sizes: s,
            validator: _validateUsername,
            onSubmitted: (_) => _emailFocus.requestFocus(),
          ),
          SizedBox(height: s.formGap),

          // Email Field
          RegisterEmailField(
            controller: _emailController,
            focusNode: _emailFocus,
            sizes: s,
            validator: _validateEmail,
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          SizedBox(height: s.formGap),

          // Password Field (güç göstergeli)
          RegisterPasswordField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            sizes: s,
            obscure: _obscurePassword,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            validator: _validatePassword,
            onSubmitted: (_) => _submit(),
          ),
          SizedBox(height: s.formGap),

          // University & Student Status (Smart Expandable Card)
          RegisterCampusCard(
            sizes: s,
            selectedStatus: _selectedStatus,
            selectedUniversity: _selectedUniversity,
            onStatusChanged: (status) =>
                setState(() => _selectedStatus = status),
            onUniversityChanged: (uni) =>
                setState(() => _selectedUniversity = uni),
          ),
          SizedBox(height: s.campusTopGap),

          // Terms & Policies Checkbox
          RegisterTermsCheckbox(
            sizes: s,
            value: _termsAccepted,
            onChanged: (v) => setState(() => _termsAccepted = v),
            onOpenTerms: () {/* rotanız: Get.toNamed(...) */},
            onOpenPrivacy: () {/* rotanız: Get.toNamed(...) */},
          ),

          // ── Server hatası ─────────────────────────────
          Obx(() {
            final msg = _auth.errorMessage.value;
            if (msg.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: s.errorMarginBottom),
              child: AuthErrorBanner(
                message: msg,
                fontSize: s.errorFontSize,
                padding: s.errorPadding,
                radius: s.errorRadius,
                iconSize: s.errorIconSize,
                marginBottom: 0,
              ),
            );
          }),

          // ── Main Registration Action Button ───────────
          SizedBox(height: s.submitTopGap),
          RegisterSubmitButton(sizes: s, onPressed: _submit),

          // ── Login Anchor Footer ───────────────────────
          RegisterFooterLinks(sizes: s),

          // ── Micro Campus Visual Footer Strip ──────────
          RegisterFooterStrip(sizes: s),

          // Alt güvenlik boşluğu (klavye açıkken son şerit görünür kalsın)
          SizedBox(height: scheme.outlineVariant.alpha * 0), // no-op
        ],
      ),
    );
  }
}