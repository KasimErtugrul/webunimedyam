// lib/presentation/screens/auth/otp_verification_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/auth/otp_verification_controller.dart';
import '../forgot_password_screen/widgets/auth_error_banner.dart';
import 'otp_verification_layout_spec.dart';

/// Kayıt sonrası email'e gönderilen 6 haneli OTP'yi doğruladığımız ekran.
///
/// Beklenen argüman: `{'email': String}`.
///
/// Tasarım birebir: glow'lu avatar header'ı, gradient hero + verified nişanı,
/// ping'li "Akademik Kimlik Doğrulama" pill'i, iki renkli "Kodu Girin",
/// bold e-postalı açıklama + "E-postayı Değiştir", sayaç + "Panodan Yapıştır"
/// çipli OTP kartı, aktif kutuda yanıp sönen imleç, "256-Bit..." satırı,
/// "Kodu almadınız mı?" kartı, "Doğrula & Kampüse Bağlan →", özel sayısal
/// tuş takımı ve "Öğrenci Destek Masası" footer'ı.
///
/// Koddaki, tasarımda olmayan öğeler KORUNDU: hata bandı, kod dolunca
/// otomatik doğrulama, loading durumları, donanım klavyesi desteği.
/// Bu dosyada bilinçli olarak setState KULLANILMAMIŞTIR — tüm reaktivite
/// controller'daki Rx'ler + Obx ile sağlanır.
class OtpVerificationScreen extends GetView<OtpVerificationController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = OtpVerificationLayoutSpec.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _Header(spec: spec),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  spec.horizontalPadding.w,
                  spec.heroTopSpacing.h,
                  spec.horizontalPadding.w,
                  spec.bottomPadding.h,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Hero(),
                        SizedBox(height: spec.formTopSpacing.h),
                        _OtpCard(spec: spec),
                        // ── Server hatası (koddaki öğe — korundu) ──
                        Obx(() {
                          final msg = _auth.errorMessage.value;
                          if (msg.isEmpty) return SizedBox(height: 16.h);
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: AuthErrorBanner(
                              message: msg,
                              fontSize: spec.errorFontSize,
                              padding: spec.errorPadding,
                              radius: spec.errorRadius,
                              iconSize: spec.errorIconSize,
                              marginBottom: 0,
                            ),
                          );
                        }),
                        // ── EKLENDİ: "Kodu almadınız mı?" kartı ──
                        _ResendCard(spec: spec),
                        SizedBox(
                          height: spec.resendCardBottomSpacing.h,
                        ), // tasarım: mb-5 = 20
                        _SubmitButton(spec: spec),
                        SizedBox(height: spec.buttonBottomSpacing.h),
                        _Keypad(spec: spec),
                        SizedBox(height: spec.keypadBottomSpacing.h),
                        const _SupportFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════ Akış yardımcıları (top-level) ═══════════════════════

OtpVerificationController get _auth => Get.find<OtpVerificationController>();

String get _email =>
    ((Get.arguments as Map<String, dynamic>?)?['email'] as String?)?.trim() ??
    '';

Future<void> _submitCode(String code) async {
  final auth = _auth;
  if (auth.isVerifyingOtp.value) return;
  if (code.length != OtpVerificationController.codeLength) return;
  FocusManager.instance.primaryFocus?.unfocus();
  await auth.verifyOtp(email: _email, otp: code);
}

void _onDigit(String digit) {
  final auth = _auth;
  if (auth.isVerifyingOtp.value) return;
  final completed = auth.appendDigit(digit);
  if (completed) unawaited(_submitCode(auth.code));
}

void _onBackspace() {
  if (_auth.isVerifyingOtp.value) return;
  _auth.backspace();
}

void _onClear() {
  if (_auth.isVerifyingOtp.value) return;
  _auth.clearCode();
}

Future<void> _onPaste() async {
  final auth = _auth;
  if (auth.isVerifyingOtp.value) return;
  unawaited(auth.flashPasteFeedback());
  final completed = await auth.pasteFromClipboard();
  if (completed) await _submitCode(auth.code);
}

// ═══════════════════════ Header ═══════════════════════

/// Tasarım: [← geri] — ortada "Email Onayı" — [glow'lu avatar]
class _Header extends StatelessWidget {
  final OtpVerificationLayoutSpec spec;
  const _Header({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: spec.headerHeight.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ortada başlık (headline-sm, max 200px, truncate)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200.w),
            child: Text(
              'Email Onayı',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: spec.headerTitleFontSize.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.01 * spec.headerTitleFontSize,
              ),
            ),
          ),
          // Sol: sade geri oku (tasarımda bg yok)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: Get.back,
              icon: Icon(
                Icons.arrow_back_rounded,
                size: spec.headerBackIconSize.sp,
                color: scheme.onSurfaceVariant,
              ),
              constraints: BoxConstraints(
                minWidth: spec.headerBackSize.w,
                minHeight: spec.headerBackSize.h,
              ),
            ),
          ),
          // Sağ: primary avatar + glow (tasarımdaki shadow[0_0_16px])
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: spec.headerAvatarSize.w,
              height: spec.headerAvatarSize.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16.r,
                  ),
                ],
              ),
              child: Icon(
                Icons.person_rounded,
                size: spec.headerAvatarIconSize.sp,
                color: scheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════ Hero ═══════════════════════

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final spec = OtpVerificationLayoutSpec.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Rozet: glow + gradient ring + gradient daire + verified nişanı ──
        SizedBox(
          width: spec.heroGlowSize.w,
          height: spec.heroGlowSize.w,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // bg-primary/20 blur-xl animate-pulse
              Container(
                    width: spec.heroGlowSize.w,
                    height: spec.heroGlowSize.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.20),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.4, end: 1, duration: 1200.ms),
              // -inset-1.5 gradient ring, opacity-40, blur-sm
              Container(
                width: spec.heroRingSize.w,
                height: spec.heroRingSize.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.darkSecondaryContainer,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.40),
                      blurRadius: 4.r,
                    ),
                  ],
                ),
              ),
              // w-16 gradient daire + glow
              Container(
                width: spec.heroCircleSize.w,
                height: spec.heroCircleSize.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.darkSecondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.45),
                      blurRadius: 24.r,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mark_email_read_rounded, // FILL 1
                  size: spec.heroGlyphSize.sp,
                  color: scheme.onPrimary,
                ),
              ),
              // -bottom-1 -right-1 nişan: koyu daire + verified
              Positioned(
                right: -4.w,
                bottom: -4.h,
                child: Container(
                  width: spec.heroBadgeSize.w,
                  height: spec.heroBadgeSize.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surfaceContainerHigh,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.verified_rounded, // FILL 1
                    size: spec.heroBadgeIconSize.sp,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: spec.heroToPillSpacing.h),

        // ── "• AKADEMİK KİMLİK DOĞRULAMA" pill'i ──
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spec.pillPaddingH.w,
            vertical: spec.pillPaddingV.h,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                    width: spec.pillDotSize.w,
                    height: spec.pillDotSize.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.2, end: 1, duration: 900.ms),
              SizedBox(width: spec.pillGap.w),
              Text(
                'AKADEMİK KİMLİK DOĞRULAMA',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: spec.pillFontSize.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8, // tracking-wider
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: spec.titleTopSpacing.h),

        // ── "Kodu Girin" — "Girin" primary renkte ──
        Text.rich(
          TextSpan(
            text: 'Kodu ',
            children: [
              TextSpan(
                text: 'Girin',
                style: TextStyle(color: scheme.primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: spec.titleFontSize.sp,
            fontWeight: FontWeight.w800,
            height: 34 / 26,
            letterSpacing: -0.025 * spec.titleFontSize,
          ),
        ),

        SizedBox(height: spec.subtitleTopSpacing.h),

        // ── Açıklama: e-posta bold + kalan metin ──
        _Subtitle(spec: spec),

        // ── "E-postayı Değiştir" ──
        SizedBox(height: spec.changeEmailTopSpacing.h),
        TextButton(
          onPressed: Get.back, // önceki ekrandan e-posta değiştirilir
          style: TextButton.styleFrom(
            foregroundColor: scheme.primary,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            minimumSize: Size(0, 32.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: spec.changeEmailIconSize.sp),
              SizedBox(width: spec.pillGap.w),
              Text(
                'E-postayı Değiştir',
                style: TextStyle(
                  fontSize: spec.changeEmailFontSize.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Subtitle extends StatelessWidget {
  final OtpVerificationLayoutSpec spec;
  const _Subtitle({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final email = _email;

    final baseStyle = TextStyle(
      color: scheme.onSurfaceVariant,
      fontSize: spec.subtitleFontSize.sp,
      height: 20 / 14,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: spec.subtitleMaxWidth.w),
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            if (email.isNotEmpty) ...[
              TextSpan(
                text: email,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: spec.subtitleFontSize.sp,
                ),
              ),
              const TextSpan(text: ' adresine gönderilen '),
            ] else
              const TextSpan(text: 'Email adresinize gönderilen '),
            const TextSpan(text: '6 haneli güvenlik kodunu girin.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ═══════════════════════ OTP kartı ═══════════════════════

class _OtpCard extends StatelessWidget {
  final OtpVerificationLayoutSpec spec;
  const _OtpCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(spec.cardPadding.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow, // bg-surface-container-low
        borderRadius: BorderRadius.circular(spec.otpBoxRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Üst satır: Kalan Süre çipi + Panodan Yapıştır ──
          Row(
            children: [
              const _TimerChip(),
              const Spacer(),
              _PasteButton(spec: spec),
            ],
          ),
          SizedBox(height: spec.cardRowGap.h),
          // ── 6 kutu ──
          const _OtpBoxes(),
          SizedBox(height: spec.gridBottomSpacing.h),
          // ── 256-Bit satırı ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: spec.securityIconSize.sp,
                color: scheme.primary,
              ),
              SizedBox(width: spec.chipGap.w),
              Text(
                '256-Bit Uçtan Uca Kampüs Doğrulaması',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: spec.securityFontSize.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip();

  @override
  Widget build(BuildContext context) {
    final spec = OtpVerificationLayoutSpec.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(
          horizontal: spec.chipPaddingH.w,
          vertical: spec.chipPaddingV.h,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: spec.timerIconSize.sp,
              color: scheme.primary,
            ),
            SizedBox(width: spec.chipGap.w),
            Text(
              'Kalan Süre:',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: spec.timerLabelFontSize.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              _auth.formattedCodeExpiry,
              style: TextStyle(
                color: scheme.primary,
                fontSize: spec.timerValueFontSize.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasteButton extends StatelessWidget {
  final OtpVerificationLayoutSpec spec;
  const _PasteButton({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final flashing = _auth.pasteFlash.value;
      final busy = _auth.isVerifyingOtp.value;
      return Material(
        color: flashing ? scheme.primary : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(999.r),
          onTap: busy ? null : _onPaste,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spec.chipPaddingH.w,
              vertical: spec.chipPaddingV.h,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.content_paste_rounded,
                  size: spec.timerIconSize.sp,
                  color: flashing ? scheme.onPrimary : scheme.primary,
                ),
                SizedBox(width: spec.chipGap.w),
                Text(
                  'Panodan Yapıştır',
                  style: TextStyle(
                    color: flashing ? scheme.onPrimary : scheme.onSurface,
                    fontSize: spec.timerLabelFontSize.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════ 6 kutu + donanım klavyesi ═══════════════════════

final Map<LogicalKeyboardKey, String> _hardwareDigitKeys = {
  LogicalKeyboardKey.digit0: '0',
  LogicalKeyboardKey.digit1: '1',
  LogicalKeyboardKey.digit2: '2',
  LogicalKeyboardKey.digit3: '3',
  LogicalKeyboardKey.digit4: '4',
  LogicalKeyboardKey.digit5: '5',
  LogicalKeyboardKey.digit6: '6',
  LogicalKeyboardKey.digit7: '7',
  LogicalKeyboardKey.digit8: '8',
  LogicalKeyboardKey.digit9: '9',
  LogicalKeyboardKey.numpad0: '0',
  LogicalKeyboardKey.numpad1: '1',
  LogicalKeyboardKey.numpad2: '2',
  LogicalKeyboardKey.numpad3: '3',
  LogicalKeyboardKey.numpad4: '4',
  LogicalKeyboardKey.numpad5: '5',
  LogicalKeyboardKey.numpad6: '6',
  LogicalKeyboardKey.numpad7: '7',
  LogicalKeyboardKey.numpad8: '8',
  LogicalKeyboardKey.numpad9: '9',
};

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes();

  KeyEventResult _handleHardwareKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final digit = _hardwareDigitKeys[event.logicalKey];
      if (digit != null) {
        _onDigit(digit);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.backspace ||
          event.logicalKey == LogicalKeyboardKey.delete) {
        _onBackspace();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleHardwareKey,
      child: Obx(() {
        return Row(
          children: [
            for (var i = 0; i < OtpVerificationController.codeLength; i++) ...[
              if (i > 0) SizedBox(width: 8.w),
              Expanded(child: _box(context, i)),
            ],
          ],
        );
      }),
    );
  }

  Widget _box(BuildContext context, int index) {
    final spec = OtpVerificationLayoutSpec.of(context);
    final auth = _auth;
    final scheme = Theme.of(context).colorScheme;

    final digit = auth.digits[index];
    final isActive = index == auth.activeDigitIndex;
    final hasDigit = digit.isNotEmpty;

    final BoxDecoration decoration = isActive
        ? BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(spec.otpBoxRadius.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.25),
                blurRadius: 16.r,
              ),
            ],
          )
        : BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(spec.otpBoxRadius.r),
          );

    Widget content;
    if (hasDigit) {
      content = Text(
        digit,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: spec.otpFontSize.sp,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      );
    } else if (isActive) {
      // Yanıp sönen primary imleç (animate-pulse)
      content =
          Container(
                width: spec.boxCursorWidth.w,
                height: spec.boxCursorHeight.h,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.25, end: 1, duration: 800.ms);
    } else {
      // Boş gelecek kutular: küçük gri nokta
      content = Container(
        width: spec.boxDotSize.w,
        height: spec.boxDotSize.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.outlineVariant,
        ),
      );
    }

    return Opacity(
      opacity: (!hasDigit && !isActive) ? 0.6 : 1,
      child: Container(
        height: spec.otpBoxHeight.h,
        decoration: decoration,
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}

// ═══════════════════════ "Kodu almadınız mı?" kartı ═══════════════════════

class _ResendCard extends StatelessWidget {
  final OtpVerificationLayoutSpec spec;
  const _ResendCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(spec.resendCardPadding.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(spec.otpBoxRadius.r),
      ),
      child: Row(
        children: [
          // ── Sol: ikon kutusu + metinler ──
          Container(
            width: spec.resendIconBoxSize.w,
            height: spec.resendIconBoxSize.w,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(spec.resendIconBoxRadius.r),
            ),
            child: Icon(
              Icons.mark_email_unread_outlined,
              size: spec.resendIconBoxIconSize.sp,
              color: scheme.primary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kodu almadınız mı?',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: spec.resendTitleFontSize.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Spam klasörünü kontrol edin',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: spec.resendSubtitleFontSize.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // ── Sağ: Tekrar Gönder (48s) / Kodu Şimdi Gönder ──
          const _ResendAction(),
        ],
      ),
    );
  }
}

class _ResendAction extends StatelessWidget {
  const _ResendAction();

  @override
  Widget build(BuildContext context) {
    final spec = OtpVerificationLayoutSpec.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final cooldown = _auth.resendCooldown.value;
      final loading = _auth.isResendingOtp.value;
      final canResend = cooldown == 0 && !loading;

      final String label;
      if (loading) {
        label = 'Gönderiliyor...';
      } else if (cooldown > 0) {
        label = 'Tekrar Gönder (${cooldown}s)';
      } else {
        label = 'Kodu Şimdi Gönder';
      }

      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(spec.keyRadius.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(spec.keyRadius.r),
          onTap: canResend ? () => _auth.resendOtp(email: _email) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!loading) ...[
                  Icon(
                    Icons.replay_rounded,
                    size: spec.resendActionIconSize.sp,
                    color: canResend ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                ] else ...[
                  SizedBox(
                    width: spec.loaderSize.w,
                    height: spec.loaderSize.w,
                    child: CircularProgressIndicator(
                      strokeWidth: spec.loaderStroke,
                      color: scheme.primary,
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 110.w),
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: canResend
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontSize: spec.resendFontSize.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════ Doğrula butonu ═══════════════════════

class _SubmitButton extends StatelessWidget {
  final OtpVerificationLayoutSpec spec;
  const _SubmitButton({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final loading = _auth.isVerifyingOtp.value;
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(spec.buttonRadius.r),
          boxShadow: loading
              ? const []
              : [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 20.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : () => _submitCode(_auth.code),
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary, // bg-primary
            foregroundColor: scheme.onPrimary,
            disabledBackgroundColor: scheme.primary.withValues(alpha: 0.55),
            disabledForegroundColor: scheme.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: Size(double.infinity, spec.buttonHeight.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(spec.buttonRadius.r),
            ),
          ),
          child: loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: spec.loaderSize.w,
                      height: spec.loaderSize.w,
                      child: CircularProgressIndicator(
                        strokeWidth: spec.loaderStroke,
                        color: scheme.onPrimary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Doğrulanıyor...',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: spec.buttonFontSize.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Doğrula & Kampüse Bağlan',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontSize: spec.buttonFontSize.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: spec.buttonIconSize.sp,
                      color: scheme.onPrimary,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

// ═══════════════════════ Özel sayısal tuş takımı ═══════════════════════

class _Keypad extends StatelessWidget {
  final OtpVerificationLayoutSpec spec;
  const _Keypad({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = _auth.isVerifyingOtp.value;
      return Container(
        padding: EdgeInsets.all(spec.keypadPadding.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(
            alpha: 0.7,
          ), // bg-surface-container-low/70
          borderRadius: BorderRadius.circular(spec.keypadRadius.r),
        ),
        child: Column(
          children: [
            _row(context, busy, ['1', '2', '3']),
            SizedBox(height: spec.keypadGap.h),
            _row(context, busy, ['4', '5', '6']),
            SizedBox(height: spec.keypadGap.h),
            _row(context, busy, ['7', '8', '9']),
            SizedBox(height: spec.keypadGap.h),
            _row(context, busy, ['C', '0', 'backspace']),
          ],
        ),
      );
    });
  }

  Widget _row(BuildContext context, bool busy, List<String> keys) {
    return Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) SizedBox(width: spec.keypadGap.w),
          Expanded(child: _key(context, keys[i], busy)),
        ],
      ],
    );
  }

  Widget _key(BuildContext context, String key, bool busy) {
    final scheme = Theme.of(context).colorScheme;

    final Widget child;
    final Color? color;

    if (key == 'C') {
      // Temizle: şeffaf zemin, soluk metin
      color = Colors.transparent;
      child = Text(
        'C',
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: spec.resendTitleFontSize.sp,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (key == 'backspace') {
      color = Colors.transparent;
      child = Icon(
        Icons.backspace_outlined,
        size: 20.sp,
        color: scheme.onSurface,
      );
    } else {
      color = null; // surfaceContainer
      child = Text(
        key,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: spec.keyFontSize.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01 * spec.keyFontSize,
        ),
      );
    }

    void onTap() {
      if (key == 'C') {
        _onClear();
      } else if (key == 'backspace') {
        _onBackspace();
      } else {
        _onDigit(key);
      }
    }

    return Material(
      color: color ?? scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(spec.keyRadius.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(spec.keyRadius.r),
        onTap: busy ? null : onTap,
        child: SizedBox(
          height: spec.keyHeight.h,
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ═══════════════════════ Destek footer'ı ═══════════════════════

class _SupportFooter extends StatelessWidget {
  const _SupportFooter();

  @override
  Widget build(BuildContext context) {
    final spec = OtpVerificationLayoutSpec.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sorun mu yaşıyorsunuz?',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: spec.supportFontSize.sp,
          ),
        ),
        SizedBox(width: spec.supportGap.w),
        InkWell(
          borderRadius: BorderRadius.circular(6.r),
          // TODO: destek masası bağlantısı (URL/route)
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: Text(
              'Öğrenci Destek Masası',
              style: TextStyle(
                color: scheme.primary,
                fontSize: spec.supportLinkFontSize.sp,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
