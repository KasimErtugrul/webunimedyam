// lib/presentation/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/widgets/hover_tap.dart';
import '../../../controllers/auth/forgot_password_controller.dart';
import 'forgot_password_layout_spec.dart';
import 'widgets/auth_error_banner.dart';

/// "Şifremi unuttum" akışının ilk adımı: kullanıcı e-postasını girer,
/// [ForgotPasswordController.sendPasswordResetOtp] çağrılır ve başarılıysa
/// [ResetPasswordScreen]'e yönlendirilir.
///
/// Tasarım birebir uygulanmıştır:
///  - Yuvarlak geri butonu + ortada "Şifre Sıfırlama" başlığı (nav bar)
///  - Glow'lu lock_reset rozeti + verified_user köşe nişanı
///  - "Hesabını Kurtar" başlığı + açıklama
///  - Dış etiketli e-posta alanı (yazınca beliren X temizle butonu ile)
///  - "GÜVENLİK NOTU" bilgi kutusu
///  - "Kod Gönder ⚡" butonu → gönderimde "Gönderiliyor..." → "Tekrar Gönder ↻"
///  - Başarı bildirimi + "Giriş ekranına geri dön" bağlantısı
///
/// Koddaki, tasarımda karşılığı olmayan öğeler KORUNDU: hata bandı,
/// "Kod, kayıtlı email adresinize gönderilir." notu, autofocus ve animasyonlar.
///
/// Not: Bu dosyada bilinçli olarak setState KULLANILMAMIŞTIR. Stateful sınıf
/// yalnızca lifecycle (dispose) içindir; tüm reaktivite Rx + Obx ve
/// FocusNode dinleyicisi (AnimatedBuilder) ile sağlanır.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  /// Ekran-özel form durumu. Sadece bu ekran yaşadığı sürece var olur,
  /// dispose'da temizlenir. (Ana controller'a dokunulmadı.)
  late final _ForgotPasswordForm _form;

  @override
  void initState() {
    super.initState();
    _form = _ForgotPasswordForm();
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = ForgotPasswordLayoutSpec.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NavBar(spec: spec),
                  _HeroSection(spec: spec),
                  _FormSection(form: _form, spec: spec),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════ Form durumu ═══════════════════════════

class _ForgotPasswordForm {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final emailFocus = FocusNode();

  /// Tasarımdaki X temizle butonu: alan doluyken görünür.
  final showClear = false.obs;

  /// Tasarımdaki gönderim-sonrası durum: buton "Tekrar Gönder ↻" olur ve
  /// başarı bildirimi görünür. (Ana controller başarıda sonraki ekrana
  /// yönlendiriyorsa bu durum ekrandan çıkıldığı için görünmez; tasarımdaki
  /// akış yine de birebir desteklenir.)
  final otpSent = false.obs;

  _ForgotPasswordForm() {
    emailCtrl.addListener(_syncClear);
  }

  void _syncClear() => showClear.value = emailCtrl.text.isNotEmpty;

  /// Tasarımdaki clearEmailInput() karşılığı.
  void clearEmail() {
    emailCtrl.clear();
    showClear.value = false;
    emailFocus.requestFocus();
  }

  ForgotPasswordController get _auth => Get.find<ForgotPasswordController>();

  String? validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'E-posta adresinizi girin.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Geçerli bir e-posta adresi girin.';
    }
    return null;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      await _auth.sendPasswordResetOtp(email: emailCtrl.text.trim());
      otpSent.value = true;
    } catch (_) {
      // Hata mesajı ana controller tarafından errorMessage'a yazılır;
      // hata bandı Obx ile otomatik görünür. Ekstra işlem gerekmez.
    }
  }

  void dispose() {
    emailCtrl.dispose();
    emailFocus.dispose();
  }
}

// ═══════════════════════════ Nav bar ═══════════════════════════

/// Tasarım: [yuvarlak geri] ---- "Şifre Sıfırlama" ---- [40x40 boş yer tutucu]
class _NavBar extends StatelessWidget {
  final ForgotPasswordLayoutSpec spec;
  const _NavBar({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spec.navVerticalPadding),
      child: Row(
        children: [
          // ── bg-surface-container rounded-full geri butonu ──
          Material(
            color: scheme.surfaceContainer,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: Get.back,
              child: SizedBox(
                width: spec.navButtonSize,
                height: spec.navButtonSize,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: spec.navIconSize,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Şifre Sıfırlama',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          // Tasarımdaki sağdaki boş kutu → başlığın gerçekten ortalanması için.
          SizedBox(width: spec.navButtonSize),
        ],
      ),
    );
  }
}

// ═══════════════════════════ Hero ═══════════════════════════

class _HeroSection extends StatelessWidget {
  final ForgotPasswordLayoutSpec spec;
  const _HeroSection({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        top: spec.heroTopSpacing,
        bottom: spec.heroBottomSpacing,
      ),
      child: Column(
        children: [
          // ── Rozet: primary/10 blur glow + dış/iç daire + nişan ──
          Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // bg-primary/10 blur-xl
                  Container(
                    width: spec.heroGlowSize,
                    height: spec.heroGlowSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.10),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.28),
                          blurRadius: 48,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // w-20 h-20 bg-surface-container shadow-lg
                  Container(
                    width: spec.heroOuterSize,
                    height: spec.heroOuterSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.surfaceContainer,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    // w-14 h-14 bg-surface-container-high + lock_reset (FILL 1)
                    child: Container(
                      width: spec.heroInnerSize,
                      height: spec.heroInnerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.surfaceContainerHigh,
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: spec.heroLockIconSize,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  // -bottom-1 -right-1 → bg-primary, verified_user 14px
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: spec.heroBadgeSize,
                      height: spec.heroBadgeSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: spec.heroBadgeIconSize,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scaleXY(
                begin: 0.7,
                end: 1,
                duration: 550.ms,
                curve: Curves.easeOutBack,
              ),

          SizedBox(height: spec.heroStackToTitleSpacing),

          // ── "Hesabını Kurtar" (headline-lg) ──
          Text(
                'Hesabını Kurtar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              )
              .animate()
              .fadeIn(delay: 180.ms, duration: 400.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                curve: Curves.easeOut,
                duration: 400.ms,
              ),

          SizedBox(height: spec.heroTitleToSubtitleSpacing),

          // ── Açıklama (body-md, on-surface-variant, max-w-xs) ──
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: spec.heroSubtitleMaxWidth),
            child: Text(
              'Kayıtlı e-posta adresinizi girin. Size şifrenizi yenilemeniz '
              'için 6 haneli bir doğrulama kodu göndereceğiz.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 320.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

// ═══════════════════════════ Form bölümü ═══════════════════════════

class _FormSection extends StatelessWidget {
  final _ForgotPasswordForm form;
  final ForgotPasswordLayoutSpec spec;
  const _FormSection({required this.form, required this.spec});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<ForgotPasswordController>();
    return Form(
          key: form.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── E-posta alanı (etiket dışarıda + temizle butonu) ──
              _EmailField(
                form: form,
                spec: spec,
              ).animate().fadeIn(delay: 550.ms, duration: 350.ms),

              // ── Server hatası (koddaki öğe; tasarımda yok → alanın altına) ──
              Obx(() {
                final msg = auth.errorMessage.value;
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

              SizedBox(height: spec.formGap),

              // ── GÜVENLİK NOTU kutusu ──
              _SecurityNote(spec: spec),

              SizedBox(height: spec.formGap),

              // ── "Kod Gönder ⚡" ──
              _SubmitButton(form: form, spec: spec),

              // ── Koddaki bilgi notu (tasarımda yok → butonun altında korundu) ──
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Kod, kayıtlı email adresinize gönderilir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSec(context).withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 350.ms),

              // ── Başarı bildirimi (gönderim sonrası) ──
              _SuccessAlert(form: form, spec: spec),

              SizedBox(height: spec.bottomLinkSpacing),

              // ── "Giriş ekranına geri dön" ──
              Center(child: _BackToLoginLink(spec: spec)),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 250.ms, duration: 400.ms)
        .slideY(
          begin: 0.06,
          end: 0,
          curve: Curves.easeOutCubic,
          duration: 500.ms,
        );
  }
}

// ═══════════════════════════ E-posta alanı ═══════════════════════════

class _EmailField extends StatelessWidget {
  final _ForgotPasswordForm form;
  final ForgotPasswordLayoutSpec spec;
  const _EmailField({required this.form, required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tasarım: label-md, on-surface-variant, ml-1
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: spec.fieldLabelGap),
          child: Text(
            'Üniversite E-postası',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        // Tasarım: rounded-xl, bg-surface-container,
        // focus-within:bg-surface-container-high
        AnimatedBuilder(
          animation: form.emailFocus, // FocusNode bir ChangeNotifier'dır
          builder: (context, _) {
            final focused = form.emailFocus.hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: focused
                    ? scheme.surfaceContainerHigh
                    : scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(spec.fieldRadius),
              ),
              child: TextFormField(
                controller: form.emailCtrl,
                focusNode: form.emailFocus,
                autofocus: true, // eski koddaki davranış korundu
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                enableSuggestions: false,
                autocorrect: false,
                onFieldSubmitted: (_) => form.submit(),
                validator: form.validateEmail,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: spec.fieldFontSize,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: false, // arka plan AnimatedContainer'dan gelir
                  hintText: 'ornek@universite.edu.tr',
                  hintStyle: TextStyle(
                    color: scheme.outline, // placeholder:text-outline
                    fontSize: spec.fieldFontSize,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    color: scheme.onSurfaceVariant,
                    size: spec.fieldIconSize,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 24,
                  ),
                  // Tasarımdaki X temizle butonu (alan doluyken görünür)
                  suffixIcon: Obx(() {
                    if (!form.showClear.value) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TapCursor(
                        onTap: form.clearEmail,
                        child: Container(
                          width: spec.clearButtonSize,
                          height: spec.clearButtonSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.surfaceContainerHighest,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: spec.clearIconSize,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: spec.fieldPaddingV,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(spec.fieldRadius),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(spec.fieldRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(spec.fieldRadius),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(spec.fieldRadius),
                    borderSide: BorderSide(color: scheme.error, width: 1.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(spec.fieldRadius),
                    borderSide: BorderSide(color: scheme.error, width: 1.5),
                  ),
                  errorStyle: TextStyle(
                    color: scheme.error,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════ Güvenlik notu ═══════════════════════════

class _SecurityNote extends StatelessWidget {
  final ForgotPasswordLayoutSpec spec;
  const _SecurityNote({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(spec.notePadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow, // bg-surface-container-low
        borderRadius: BorderRadius.circular(spec.noteRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_rounded, // FILL 1
            color: scheme.secondary,
            size: spec.noteIconSize,
          ),
          SizedBox(width: spec.noteGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GÜVENLİK NOTU',
                  style: TextStyle(
                    color: scheme.secondary,
                    fontSize: spec.noteTitleFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8, // tracking-wider
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Doğrulama kodu e-posta adresinizin spam/gereksiz '
                  'klasörüne de düşebilir. Lütfen kontrol ediniz.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: spec.noteTextFontSize,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════ Buton ═══════════════════════════

class _SubmitButton extends StatelessWidget {
  final _ForgotPasswordForm form;
  final ForgotPasswordLayoutSpec spec;
  const _SubmitButton({required this.form, required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final auth = Get.find<ForgotPasswordController>();
    return Obx(() {
      final loading = auth.isSendingResetOtp.value;
      final sent = form.otpSent.value;
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(spec.buttonRadius),
          boxShadow: loading
              ? const []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : form.submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary, // bg-primary
            foregroundColor: scheme.onPrimary, // text-on-primary
            disabledBackgroundColor: scheme.primary.withValues(alpha: 0.60),
            disabledForegroundColor: scheme.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: Size(double.infinity, spec.buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(spec.buttonRadius),
            ),
          ),
          child: loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: spec.loaderSize,
                      height: spec.loaderSize,
                      child: CircularProgressIndicator(
                        strokeWidth: spec.loaderStroke,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Gönderiliyor...', style: _labelStyle(scheme)),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      sent ? 'Tekrar Gönder' : 'Kod Gönder',
                      style: _labelStyle(scheme),
                    ),
                    SizedBox(width: spec.buttonGap),
                    Icon(
                      // Tasarım: ilk gönderim bolt, sonrasında refresh
                      sent ? Icons.refresh_rounded : Icons.bolt_rounded,
                      size: spec.buttonIconSize,
                      color: scheme.onPrimary,
                    ),
                  ],
                ),
        ),
      );
    });
  }

  TextStyle _labelStyle(ColorScheme scheme) => TextStyle(
    color: scheme.onPrimary,
    fontSize: spec.buttonFontSize,
    fontWeight: FontWeight.w600, // label-lg
    letterSpacing: 0.2,
  );
}

// ═══════════════════════════ Başarı bildirimi ═══════════════════════════

class _SuccessAlert extends StatelessWidget {
  final _ForgotPasswordForm form;
  final ForgotPasswordLayoutSpec spec;
  const _SuccessAlert({required this.form, required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      if (!form.otpSent.value) return const SizedBox.shrink();
      return Container(
            margin: const EdgeInsets.only(top: 16), // mt-space-md
            padding: EdgeInsets.all(spec.alertPadding),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh, // bg-surface-container-high
              borderRadius: BorderRadius.circular(spec.alertRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  color: scheme.primary,
                  size: spec.alertIconSize,
                ),
                SizedBox(width: spec.alertGap),
                Expanded(
                  child: Text(
                    'Doğrulama kodu başarıyla e-postanıza iletildi.',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: spec.alertTextFontSize,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: -0.1, end: 0, curve: Curves.easeOut);
    });
  }
}

// ═══════════════════════════ Alt bağlantı ═══════════════════════════

class _BackToLoginLink extends StatelessWidget {
  final ForgotPasswordLayoutSpec spec;
  const _BackToLoginLink({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: Get.back, // giriş ekranına dönüş
      style: TextButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: spec.linkVerticalPadding,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back_ios_new_rounded,
            size: spec.linkIconSize,
            color: scheme.onSurfaceVariant,
          ),
          SizedBox(width: spec.linkGap),
          Text(
            'Giriş ekranına geri dön',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: spec.linkFontSize,
              fontWeight: FontWeight.w600, // label-md
            ),
          ),
        ],
      ),
    );
  }
}
