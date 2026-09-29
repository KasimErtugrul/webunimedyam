// lib/presentation/screens/auth/register_screen/register_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../controllers/auth/register_controller.dart';
import '../forgot_password_screen/widgets/auth_error_banner.dart';
import 'register_layout_spec.dart';
// Akademik Durum kartı geçici olarak devre dışı; kart geri gelirse
// bu import da yorumdan çıkarılmalı.
// import 'widgets/register_campus_card.dart';
import 'widgets/register_email_field.dart';
import 'widgets/register_footer_links.dart';
import 'widgets/register_footer_strip.dart';
import 'widgets/register_header.dart';
import 'widgets/register_password_field.dart';
import 'widgets/register_submit_button.dart';
import 'widgets/register_terms_checkbox.dart';
import 'widgets/register_top_bar.dart';
import 'widgets/register_text_field.dart';
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
  // Kullanıcı adı: yalnızca küçük İngilizce harf, rakam ve alt çizgi;
  // boşluk yasak.
  static final RegExp _usernameRegExp = RegExp(r'^[a-z0-9_]+$');

  // E-posta: genel kabul görmüş "bir şey@bir şey.uzunluk" formatı.
  static final RegExp _emailRegExp =
      RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // Şifre tekrarı alanının FormFieldState'i — canlı yeniden doğrulama
  // için kullanılıyor.
  final _confirmFieldKey = GlobalKey<FormFieldState<String>>();

  // Kullanıcı adı canlı müsaitlik kontrolü (debounce'lu).
  final _usernameAvailability =
      ValueNotifier<UsernameAvailability>(UsernameAvailability.unknown);
  Timer? _usernameDebounce;
  String? _takenUsername;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  bool _termsError = false;

  // İlk submit denemesinden sonra şifre alanları canlı doğrulanır.
  bool _submitAttempted = false;

  // Tasarımdaki Akademik Durum kartının yerel durumu — kart geçici
  // olarak kapatıldığı için bu alanlar da pasif:
  /*
  String _selectedStatus = 'Öğrenci';
  String? _selectedUniversity;
  */

  RegisterController get _auth => Get.find<RegisterController>();
  RegisterSizes get _s => widget.sizes;

  @override
  void initState() {
    super.initState();
    // Şifre ya da tekrar alanı değiştiğinde, daha önce yapılmış başarısız
    // bir denemenin ekranda kalmış "eşleşmiyor" hatası canlı olarak
    // tazelenir; kullanıcı düzeltir düzeltmez hata kaybolur.
    _passwordController.addListener(_revalidateConfirm);
    _confirmPasswordController.addListener(_revalidateConfirm);
    _usernameController.addListener(_onUsernameChanged);
  }

  void _onUsernameChanged() {
    _usernameDebounce?.cancel();
    final v = _usernameController.text.trim();
    if (_validateUsername(v) != null) {
      _takenUsername = null;
      _usernameAvailability.value = UsernameAvailability.unknown;
      return;
    }
    _usernameAvailability.value = UsernameAvailability.checking;
    _usernameDebounce = Timer(
      const Duration(milliseconds: 500),
      () => _checkUsername(v),
    );
  }

  /// Sunucuya sorar. Aynı e-postayla başlanıp doğrulanmamış bir kayıt kendi
  /// kullanıcı adını tutuyorsa "müsait" döner (e-posta geçerliyse gönderilir).
  Future<bool> _checkUsername(String v) async {
    final email = _emailController.text.trim();
    final available = await _auth.isUsernameAvailable(
      v,
      email: _emailRegExp.hasMatch(email) ? email : null,
    );
    if (!mounted || _usernameController.text.trim() != v) return available;
    _takenUsername = available ? null : v;
    _usernameAvailability.value = available
        ? UsernameAvailability.available
        : UsernameAvailability.taken;
    return available;
  }

  void _revalidateConfirm() {
    if (!_submitAttempted) return;
    _confirmFieldKey.currentState?.validate();
  }

  @override
  void dispose() {
    _passwordController.removeListener(_revalidateConfirm);
    _confirmPasswordController.removeListener(_revalidateConfirm);
    _usernameController.removeListener(_onUsernameChanged);
    _usernameDebounce?.cancel();
    _usernameAvailability.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  // ── Validators ─────────────────────────────────────────
  String? _validateUsername(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Kullanıcı adı gerekli';
    if (v.length < 3) return 'Kullanıcı adı en az 3 karakter olmalı';
    if (v.length > 20) return 'Kullanıcı adı en fazla 20 karakter olmalı';
    if (!_usernameRegExp.hasMatch(v)) {
      return 'Yalnızca küçük İngilizce harf, rakam ve alt çizgi; boşluk kullanılmaz';
    }
    if (_takenUsername == v) {
      return 'Bu kullanıcı adı zaten alınmış. Başka bir tane deneyin.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'E-posta adresi gerekli';
    if (!_emailRegExp.hasMatch(v)) {
      return 'Geçerli bir e-posta adresi girin (örn. ogrenci@uni.edu.tr)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    // Başta/sonda görünmez boşluk kalmasın: doğrulama ve kayıt aynı
    // değeri kullansın diye trim'li karşılaştırıyoruz.
    if ((value ?? '').trim().length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Şifre tekrarı gerekli';
    if (v != _passwordController.text.trim()) return 'Şifreler eşleşmiyor';
    return null;
  }

  Future<void> _submit() async {
    _submitAttempted = true;
    final formValid = _formKey.currentState?.validate() ?? false;
    // Kullanım koşulları onayı olmadan kayıt kesinlikle yapılmaz.
    if (!_termsAccepted) {
      setState(() => _termsError = true);
    }
    if (!formValid || !_termsAccepted) return;
    FocusScope.of(context).unfocus();

    // Son söz sunucuda: yarışta (form doldurulurken başkası aldıysa) kayıt
    // isteği atmadan, sebebi net olarak alanın altında göster.
    final nameOk = await _checkUsername(_usernameController.text.trim());
    if (!nameOk) {
      _formKey.currentState?.validate();
      return;
    }

    await _auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
    );
  }

  /// Kullanım Koşulları / Gizlilik Politikası ekranını açar; ekranda
  /// "Okudum, Anladım" denirse onay kutusunu otomatik işaretler.
  /// "İptal" ya da geri dönüşte hiçbir şey değişmez (tik atanmaz).
  /// Not: GetX, getPages'ten rota üretirken `GetPageRoute<dynamic>` oluşturduğu
  /// için `Get.toNamed<bool>(...)` cast hatası veriyor — jenerik'siz çağırıp
  /// sonucu dynamic karşılaştırıyoruz.
  Future<void> _openLegalDocument(String route) async {
    final accepted = await Get.toNamed(route);
    if (accepted != true || !mounted) return;
    setState(() {
      _termsAccepted = true;
      _termsError = false;
    });
  }

  /// Checkbox'a dokununca: işaretlemek isteniyorsa koşullar sayfası açılır,
  /// "Okudum, Anladım" ile dönülürse tik atanır. İşareti kaldırmak
  /// serbesttir; sayfa açılmadan sadece tik kalkar.
  void _onTermsCheckboxTapped(bool tick) {
    if (!tick) {
      setState(() {
        _termsAccepted = false;
        _termsError = false;
      });
      return;
    }
    _openLegalDocument(AppRoutes.terms);
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

          // ── Registration Form (gap-space-md) ──────────
          // Username Field
          RegisterUsernameField(
            controller: _usernameController,
            focusNode: _usernameFocus,
            sizes: s,
            validator: _validateUsername,
            availability: _usernameAvailability,
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
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
          ),
          SizedBox(height: s.formGap),

          // Confirm Password Field
          RegisterTextField(
            sizes: s,
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            formFieldKey: _confirmFieldKey,
            label: 'Şifre Tekrarı',
            icon: Icons.lock_outline_rounded,
            hint: '••••••••',
            obscure: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            enableSuggestions: false,
            autocorrect: false,
            validator: _validateConfirmPassword,
            onSubmitted: (_) => _submit(),
            suffix: Padding(
              padding: EdgeInsets.only(right: s.toggleRight),
              child: IconButton(
                tooltip:
                    _obscureConfirmPassword ? 'Şifreyi göster' : 'Şifreyi gizle',
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: s.toggleSize,
                  minHeight: s.toggleSize,
                ),
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: s.toggleIconSize,
                  color: scheme.outline,
                ),
              ),
            ),
          ),
          SizedBox(height: s.formGap),

          // ── University & Student Status (Smart Expandable Card) ──
          // Akademik Durum kartı geçici olarak kapatıldı; geri getirmek
          // için yorumu ve import satırını açın.
          /*
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
          */

          // Terms & Policies Checkbox — tik atmak koşullar sayfasından
          // geçer; "Okudum, Anladım" olmadan işaretlenmez.
          RegisterTermsCheckbox(
            sizes: s,
            value: _termsAccepted,
            hasError: _termsError,
            onChanged: _onTermsCheckboxTapped,
            onOpenTerms: () => _openLegalDocument(AppRoutes.terms),
            onOpenPrivacy: () => _openLegalDocument(AppRoutes.privacy),
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
