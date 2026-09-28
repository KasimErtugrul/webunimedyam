// lib/presentation/screens/auth/otp_verification_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                  spec.horizontalPadding,
                  spec.heroTopSpacing,
                  spec.horizontalPadding,
                  spec.bottomPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Hero(),
                        SizedBox(height: spec.formTopSpacing),
                        _OtpCard(spec: spec),
                        // ── Server hatası (koddaki öğe — korundu) ──
                        Obx(() {
                          final msg = _auth.errorMessage.value;
                          if (msg.isEmpty) return const SizedBox(height: 16);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
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
                          height: spec.resendCardBottomSpacing,
                        ), // tasarım: mb-5 = 20
                        _SubmitButton(spec: spec),
                        SizedBox(height: spec.buttonBottomSpacing),
                        _Keypad(spec: spec),
                        SizedBox(height: spec.keypadBottomSpacing),
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
      height: spec.headerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ortada başlık (headline-sm, max 200px, truncate)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              'Email Onayı',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: spec.headerTitleFontSize,
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
                size: spec.headerBackIconSize,
                color: scheme.onSurfaceVariant,
              ),
              constraints: BoxConstraints(
                minWidth: spec.headerBackSize,
                minHeight: spec.headerBackSize,
              ),
            ),
          ),
          // Sağ: primary avatar + glow (tasarımdaki shadow[0_0_16px])
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: spec.headerAvatarSize,
              height: spec.headerAvatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                Icons.person_rounded,
                size: spec.headerAvatarIconSize,
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
          width: spec.heroGlowSize,
          height: spec.heroGlowSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // bg-primary/20 blur-xl animate-pulse
              Container(
                    width: spec.heroGlowSize,
                    height: spec.heroGlowSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.20),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.4, end: 1, duration: 1200.ms),
              // -inset-1.5 gradient ring, opacity-40, blur-sm
              Container(
                width: spec.heroRingSize,
                height: spec.heroRingSize,
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
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              // w-16 gradient daire + glow
              Container(
                width: spec.heroCircleSize,
                height: spec.heroCircleSize,
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
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mark_email_read_rounded, // FILL 1
                  size: spec.heroGlyphSize,
                  color: scheme.onPrimary,
                ),
              ),
              // -bottom-1 -right-1 nişan: koyu daire + verified
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: spec.heroBadgeSize,
                  height: spec.heroBadgeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surfaceContainerHigh,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.verified_rounded, // FILL 1
                    size: spec.heroBadgeIconSize,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: spec.heroToPillSpacing),

        // ── "• AKADEMİK KİMLİK DOĞRULAMA" pill'i ──
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: spec.pillPaddingH,
            vertical: spec.pillPaddingV,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                    width: spec.pillDotSize,
                    height: spec.pillDotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.2, end: 1, duration: 900.ms),
              SizedBox(width: spec.pillGap),
              Text(
                'AKADEMİK KİMLİK DOĞRULAMA',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: spec.pillFontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8, // tracking-wider
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: spec.titleTopSpacing),

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
            fontSize: spec.titleFontSize,
            fontWeight: FontWeight.w800,
            height: 34 / 26,
            letterSpacing: -0.025 * spec.titleFontSize,
          ),
        ),

        SizedBox(height: spec.subtitleTopSpacing),

        // ── Açıklama: e-posta bold + kalan metin ──
        _Subtitle(spec: spec),

        // ── "E-postayı Değiştir" ──
        SizedBox(height: spec.changeEmailTopSpacing),
        TextButton(
          onPressed: Get.back, // önceki ekrandan e-posta değiştirilir
          style: TextButton.styleFrom(
            foregroundColor: scheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: spec.changeEmailIconSize),
              SizedBox(width: spec.pillGap),
              Text(
                'E-postayı Değiştir',
                style: TextStyle(
                  fontSize: spec.changeEmailFontSize,
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
      fontSize: spec.subtitleFontSize,
      height: 20 / 14,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: spec.subtitleMaxWidth),
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
                  fontSize: spec.subtitleFontSize,
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
      padding: EdgeInsets.all(spec.cardPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow, // bg-surface-container-low
        borderRadius: BorderRadius.circular(spec.otpBoxRadius),
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
          SizedBox(height: spec.cardRowGap),
          // ── 6 kutu ──
          const _OtpBoxes(),
          SizedBox(height: spec.gridBottomSpacing),
          // ── 256-Bit satırı ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: spec.securityIconSize,
                color: scheme.primary,
              ),
              SizedBox(width: spec.chipGap),
              Text(
                '256-Bit Uçtan Uca Kampüs Doğrulaması',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: spec.securityFontSize,
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
          horizontal: spec.chipPaddingH,
          vertical: spec.chipPaddingV,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: spec.timerIconSize,
              color: scheme.primary,
            ),
            SizedBox(width: spec.chipGap),
            Text(
              'Kalan Süre:',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: spec.timerLabelFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _auth.formattedCodeExpiry,
              style: TextStyle(
                color: scheme.primary,
                fontSize: spec.timerValueFontSize,
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
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: busy ? null : _onPaste,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spec.chipPaddingH,
              vertical: spec.chipPaddingV,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.content_paste_rounded,
                  size: spec.timerIconSize,
                  color: flashing ? scheme.onPrimary : scheme.primary,
                ),
                SizedBox(width: spec.chipGap),
                Text(
                  'Panodan Yapıştır',
                  style: TextStyle(
                    color: flashing ? scheme.onPrimary : scheme.onSurface,
                    fontSize: spec.timerLabelFontSize,
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
              if (i > 0) const SizedBox(width: 8),
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
            borderRadius: BorderRadius.circular(spec.otpBoxRadius),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.25),
                blurRadius: 16,
              ),
            ],
          )
        : BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(spec.otpBoxRadius),
          );

    Widget content;
    if (hasDigit) {
      content = Text(
        digit,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: spec.otpFontSize,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      );
    } else if (isActive) {
      // Yanıp sönen primary imleç (animate-pulse)
      content =
          Container(
                width: spec.boxCursorWidth,
                height: spec.boxCursorHeight,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.25, end: 1, duration: 800.ms);
    } else {
      // Boş gelecek kutular: küçük gri nokta
      content = Container(
        width: spec.boxDotSize,
        height: spec.boxDotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.outlineVariant,
        ),
      );
    }

    return Opacity(
      opacity: (!hasDigit && !isActive) ? 0.6 : 1,
      child: Container(
        height: spec.otpBoxHeight,
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
      padding: EdgeInsets.all(spec.resendCardPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(spec.otpBoxRadius),
      ),
      child: Row(
        children: [
          // ── Sol: ikon kutusu + metinler ──
          Container(
            width: spec.resendIconBoxSize,
            height: spec.resendIconBoxSize,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(spec.resendIconBoxRadius),
            ),
            child: Icon(
              Icons.mark_email_unread_outlined,
              size: spec.resendIconBoxIconSize,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kodu almadınız mı?',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: spec.resendTitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Spam klasörünü kontrol edin',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: spec.resendSubtitleFontSize,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
        borderRadius: BorderRadius.circular(spec.keyRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(spec.keyRadius),
          onTap: canResend ? () => _auth.resendOtp(email: _email) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!loading) ...[
                  Icon(
                    Icons.replay_rounded,
                    size: spec.resendActionIconSize,
                    color: canResend ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                ] else ...[
                  SizedBox(
                    width: spec.loaderSize,
                    height: spec.loaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: spec.loaderStroke,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: canResend
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontSize: spec.resendFontSize,
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
          borderRadius: BorderRadius.circular(spec.buttonRadius),
          boxShadow: loading
              ? const []
              : [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
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
                    Text(
                      'Doğrulanıyor...',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: spec.buttonFontSize,
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
                          fontSize: spec.buttonFontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: spec.buttonIconSize,
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
        padding: EdgeInsets.all(spec.keypadPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(
            alpha: 0.7,
          ), // bg-surface-container-low/70
          borderRadius: BorderRadius.circular(spec.keypadRadius),
        ),
        child: Column(
          children: [
            _row(context, busy, ['1', '2', '3']),
            SizedBox(height: spec.keypadGap),
            _row(context, busy, ['4', '5', '6']),
            SizedBox(height: spec.keypadGap),
            _row(context, busy, ['7', '8', '9']),
            SizedBox(height: spec.keypadGap),
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
          if (i > 0) SizedBox(width: spec.keypadGap),
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
          fontSize: spec.resendTitleFontSize,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (key == 'backspace') {
      color = Colors.transparent;
      child = Icon(
        Icons.backspace_outlined,
        size: 20,
        color: scheme.onSurface,
      );
    } else {
      color = null; // surfaceContainer
      child = Text(
        key,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: spec.keyFontSize,
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
      borderRadius: BorderRadius.circular(spec.keyRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(spec.keyRadius),
        onTap: busy ? null : onTap,
        child: SizedBox(
          height: spec.keyHeight,
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
            fontSize: spec.supportFontSize,
          ),
        ),
        SizedBox(width: spec.supportGap),
        InkWell(
          borderRadius: BorderRadius.circular(6),
          // TODO: destek masası bağlantısı (URL/route)
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'Öğrenci Destek Masası',
              style: TextStyle(
                color: scheme.primary,
                fontSize: spec.supportLinkFontSize,
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
