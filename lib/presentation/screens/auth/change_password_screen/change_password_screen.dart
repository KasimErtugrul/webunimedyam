// lib/presentation/screens/auth/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/change_password_controller.dart';
import 'change_password_layout_spec.dart';

/// Oturum açık kullanıcının şifresini değiştirdiği ekran.
/// Ayarlar → Hesap → "Şifre Değiştir" üzerinden açılır.
///
/// Tasarımdaki tüm öğeler birebir: kalkan+glow başlık, "Şifremi Unuttum?",
/// şifre gücü göstergesi, 2x2 ölçüt listesi, "Diğer oturumları sonlandır"
/// anahtarı ve Güncelle/Vazgeç buton çifti. Eksta widget dosyası yok.
class ChangePasswordScreen extends GetView<ChangePassController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = ChangePasswordLayoutSpec.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: _buildAppBar(context, spec),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: spec.horizontalPadding,
                vertical: spec.verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  SizedBox(height: spec.sectionSpacing),
                  _FormCard(spec: spec),
                  // Sunucu hatası (client validator'lar geçildikten sonra)
                  Obx(() {
                    final msg = controller.errorMessage.value;
                    if (msg.isEmpty) return const SizedBox.shrink();
                    final scheme = Theme.of(context).colorScheme;
                    return Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: scheme.error.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(spec.radius),
                          border: Border.all(
                            color: scheme.error.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: scheme.error,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                msg,
                                style: TextStyle(
                                  color: scheme.error,
                                  fontSize: spec.errorFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: spec.sectionSpacing),
                  _SubmitButton(spec: spec),
                  SizedBox(height: 12),
                  _CancelButton(spec: spec),
                  SizedBox(height: spec.bottomSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── AppBar: kare geri butonu + başlık + profil avatarı ────────────
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ChangePasswordLayoutSpec spec,
  ) {
    return AppBar(
      backgroundColor: AppTheme.bg(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: 72,
      titleSpacing: spec.horizontalPadding,
      title: Row(
        children: [
          const _BackButton(),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Şifre Değiştir',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          SizedBox(width: 12),
          const _ProfileAvatar(),
        ],
      ),
    );
  }
}

// ═══════════════════════ AppBar parçaları ═══════════════════════
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(AppTheme.radiusLg);
    return Material(
      color: AppTheme.card(context),
      borderRadius: r,
      child: InkWell(
        borderRadius: r,
        onTap: Get.back,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppTheme.textPri(context),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 22,
        color: Colors.white, // tasarımdaki gibi beyaz ikon
      ),
    );
  }
}

// ═══════════════════════ Başlık (kalkan + glow) ═══════════════════════
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary.withValues(alpha: 0.08),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.25),
                blurRadius: 48,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 46, color: scheme.primary),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.lock_rounded,
                  size: 14,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Hesap Güvenliği',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        SizedBox(height: 10),
        Text(
          'Şifreniz en az 8 karakterden oluşmalı, harf ve rakam içermelidir.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSec(context),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════ Form kartı ═══════════════════════
class _FormCard extends StatelessWidget {
  final ChangePasswordLayoutSpec spec;
  const _FormCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChangePassController>();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Form(
        key: c.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Field(
              spec: spec,
              label: 'Mevcut Şifre',
              trailing: const _ForgotLink(),
              ctrl: c.currentCtrl,
              focusNode: c.currentFocus,
              icon: Icons.lock_outline_rounded,
              hint: 'Mevcut şifrenizi girin',
              obscure: c.obscureCurrent,
              toggle: c.toggleObscureCurrent,
              autofillHint: AutofillHints.password,
              validator: c.validateCurrent,
              onSubmitted: (_) => c.newFocus.requestFocus(),
            ),
            SizedBox(height: spec.fieldSpacing),
            _Field(
              spec: spec,
              label: 'Yeni Şifre',
              ctrl: c.newCtrl,
              focusNode: c.newFocus,
              icon: Icons.vpn_key_outlined,
              hint: 'En az 8 karakterli yeni şifre',
              obscure: c.obscureNew,
              toggle: c.toggleObscureNew,
              autofillHint: AutofillHints.newPassword,
              validator: c.validateNew,
              onSubmitted: (_) => c.confirmFocus.requestFocus(),
            ),
            SizedBox(height: 16),
            _StrengthMeter(spec: spec),
            SizedBox(height: 16),
            const _Checklist(),
            SizedBox(height: spec.fieldSpacing),
            // Tasarımda bu alanın göz ikonu yok → düz metin doğrulama.
            _Field(
              spec: spec,
              label: 'Yeni Şifre (Tekrar)',
              ctrl: c.confirmCtrl,
              focusNode: c.confirmFocus,
              icon: Icons.refresh_rounded,
              hint: 'Yeni şifreyi doğrulayın',
              autofillHint: AutofillHints.newPassword,
              validator: c.validateConfirm,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => c.submit(),
            ),
            SizedBox(height: 20),
            const _EndSessionsToggle(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════ "Şifremi Unuttum?" ═══════════════════════
class _ForgotLink extends StatelessWidget {
  const _ForgotLink();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChangePassController>();
    return TextButton(
      onPressed: c.forgotPassword,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        minimumSize: Size(44, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        'Şifremi Unuttum?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ═══════════════════════ Alan (etiket dışarıda) ═══════════════════════
class _Field extends StatelessWidget {
  final ChangePasswordLayoutSpec spec;
  final String label;
  final Widget? trailing;
  final TextEditingController ctrl;
  final FocusNode? focusNode;
  final IconData icon;
  final String hint;

  /// Verilirse göz ikonu gösterilir ve alan maskelenir.
  /// null → düz metin (tasarımda "Tekrar" alanında ikon yok).
  final RxBool? obscure;
  final VoidCallback? toggle;
  final String? autofillHint;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _Field({
    required this.spec,
    required this.label,
    required this.ctrl,
    required this.icon,
    required this.hint,
    this.trailing,
    this.focusNode,
    this.obscure,
    this.toggle,
    this.autofillHint,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final hasEye = obscure != null && toggle != null;
    final Widget field;
    if (hasEye) {
      field = Obx(
        () =>
            _buildTextField(context, isObscured: obscure!.value, showEye: true),
      );
    } else {
      field = _buildTextField(context, isObscured: false, showEye: false);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
        SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required bool isObscured,
    required bool showEye,
  }) {
    return TextFormField(
      controller: ctrl,
      focusNode: focusNode,
      obscureText: isObscured,
      autofillHints: autofillHint == null ? null : [autofillHint!],
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: spec.fontSize,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: spec.iconSize,
          color: AppTheme.textSec(context),
        ),
        suffixIcon: showEye
            ? IconButton(
                tooltip: isObscured ? 'Şifreyi göster' : 'Şifreyi gizle',
                onPressed: toggle,
                icon: Icon(
                  isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: spec.iconSize,
                  color: AppTheme.textSec(context),
                ),
              )
            : null,
      ),
    );
  }
}

// ═══════════════════════ Şifre gücü göstergesi ═══════════════════════
class _StrengthMeter extends StatelessWidget {
  final ChangePasswordLayoutSpec spec;
  const _StrengthMeter({required this.spec});

  static Color _color(BuildContext context, int s) {
    switch (s) {
      case 4:
        return AppTheme.primaryColor; // #4EDEA3 — marka
      case 3:
        return const Color(0xFFA3E635); // lime
      case 2:
        return const Color(0xFFFBBF24); // amber
      case 1:
        return const Color(0xFFEF4444); // red
      default:
        return AppTheme.textSec(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChangePassController>();
    return Obx(() {
      final s = c.strength.value;
      final color = _color(context, s);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Şifre Gücü',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                c.strengthLabel,
                style: TextStyle(
                  color: s == 0 ? AppTheme.textPri(context) : color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(4, (i) {
              final active = i < s;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: active
                        ? color
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }
}

// ═══════════════════════ 2x2 ölçüt listesi ═══════════════════════
class _Checklist extends StatelessWidget {
  const _Checklist();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChangePassController>();
    return Obx(() {
      Widget item(bool met, String label) => Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 18,
            color: met
                ? Theme.of(context).colorScheme.primary
                : AppTheme.textSec(context),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: met
                    ? AppTheme.textPri(context)
                    : AppTheme.textSec(context),
                fontWeight: met ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      );

      return Column(
        children: [
          Row(
            children: [
              Expanded(child: item(c.hasMinLength.value, 'En az 8 karakter')),
              SizedBox(width: 16),
              Expanded(child: item(c.hasUppercase.value, 'Büyük harf (A-Z)')),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: item(c.hasDigit.value, 'Rakam (0-9)')),
              SizedBox(width: 16),
              Expanded(child: item(c.hasSpecial.value, 'Özel sembol (!@#\$)')),
            ],
          ),
        ],
      );
    });
  }
}

// ═══════════════════════ Oturum sonlandırma anahtarı ═══════════════════════
class _EndSessionsToggle extends StatelessWidget {
  const _EndSessionsToggle();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChangePassController>();
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diğer oturumları sonlandır',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tüm diğer mobil ve web oturumları kapatılır',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Switch(
            value: c.endOtherSessions.value,
            onChanged: c.setEndOtherSessions,
            // Tasarımdaki gibi: primary track + beyaz thumb
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      );
    });
  }
}

// ═══════════════════════ Butonlar ═══════════════════════
class _SubmitButton extends StatelessWidget {
  final ChangePasswordLayoutSpec spec;
  const _SubmitButton({required this.spec});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ChangePassController>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final loading = c.isChangingPassword.value;
      return ElevatedButton(
        onPressed: loading ? null : c.submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.55),
          disabledForegroundColor: scheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size(double.infinity, spec.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spec.radius),
          ),
        ),
        child: loading
            ? SizedBox(
                width: spec.loaderSize,
                height: spec.loaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: spec.loaderStroke,
                  color: scheme.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: spec.iconSize,
                    color: scheme.onPrimary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Şifre Güncelle',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: spec.fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      );
    });
  }
}

class _CancelButton extends StatelessWidget {
  final ChangePasswordLayoutSpec spec;
  const _CancelButton({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: Get.back,
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.surfaceContainerHigh,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: Size(double.infinity, spec.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spec.radius),
        ),
      ),
      child: Text(
        'Vazgeç',
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: spec.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
