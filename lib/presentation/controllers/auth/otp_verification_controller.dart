// lib/presentation/controllers/auth/otp_verification_controller.dart
import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/auth_exceptions.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/analytics_service.dart';
import '../../../services/session_service.dart';
import '../utils/resend_cooldown.dart';

class OtpVerificationController extends GetxController {
  /// 6 haneli kod ve 10:00 (600 sn) geçerlilik sayacı.
  static const int codeLength = 6;
  static const int codeExpirySeconds = 600; // Supabase OTP expiry ile aynı olmalı

  OtpVerificationController({
    required AuthRepository authRepository,
    required SessionService sessionService,
  })  : _repo = authRepository,
        _session = sessionService;

  final AuthRepository _repo;
  final SessionService _session;

  // ── Eski üyeler (aynen korundu) ────────────────────────────────────
  final isVerifyingOtp = false.obs;
  final isResendingOtp = false.obs;
  final errorMessage = ''.obs;
  final cooldown = ResendCooldown();

  /// `OtpResendButton` eski API'si için (sayısal alan).
  RxInt get resendCooldown => cooldown.seconds;

  // ── Yeni: kod haneleri (tasarımdaki 6 kutu + tuş takımı kaynağı) ──
  final digits = List<String>.filled(codeLength, '').obs;

  // ── Yeni: kod geçerlilik sayacı ("Kalan Süre: 02:45") ──────────────
  final codeExpiresInSeconds = codeExpirySeconds.obs;
  Timer? _expiryTimer;

  // ── Yeni: "Panodan Yapıştır" geri bildirimi (300ms flash) ──────────
  final pasteFlash = false.obs;

  String get code => digits.join();

  bool get isCodeComplete {
    for (var i = 0; i < digits.length; i++) {
      if (digits[i].isEmpty) return false;
    }
    return true;
  }

  /// aktif (imleçli) kutu; kod tamamsa -1.
  int get activeDigitIndex =>
      isCodeComplete ? -1 : digits.indexWhere((d) => d.isEmpty);

  /// "02:45" biçiminde gösterim.
  String get formattedCodeExpiry {
    final total = codeExpiresInSeconds.value.clamp(0, 5999).toInt();
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Kod state işlemleri ────────────────────────────────────────────
  /// Hane ekler; kod tamamlandığında true döner (otomatik submit için).
  bool appendDigit(String digit) {
    if (isVerifyingOtp.value) return false;
    final i = activeDigitIndex;
    if (i == -1) return false;
    digits[i] = digit;
    return isCodeComplete;
  }

  void backspace() {
    if (isVerifyingOtp.value) return;
    for (var i = digits.length - 1; i >= 0; i--) {
      if (digits[i].isNotEmpty) {
        digits[i] = '';
        return;
      }
    }
  }

  void clearCode() {
    if (isVerifyingOtp.value) return;
    for (var i = 0; i < digits.length; i++) {
      digits[i] = '';
    }
  }

  /// Panodaki metinden sadece rakamları alıp kutulara doldurur.
  /// Dönüş: kod tamamlandı mı?
  Future<bool> pasteFromClipboard() async {
    if (isVerifyingOtp.value) return false;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final raw = data?.text ?? '';
    final onlyDigits = raw.replaceAll(RegExp(r'\D'), '');
    if (onlyDigits.isEmpty) return false;
    clearCode();
    for (var i = 0; i < onlyDigits.length && i < codeLength; i++) {
      digits[i] = onlyDigits[i];
    }
    return isCodeComplete;
  }

  /// Tasarımdaki JS davranışı: buton 300ms primary renkte parlar.
  Future<void> flashPasteFeedback() async {
    pasteFlash.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    pasteFlash.value = false;
  }

  /// 165 sn'den geriye sayar; 0'da durur ("00:00").
  void startCodeExpiry() {
    _expiryTimer?.cancel();
    codeExpiresInSeconds.value = codeExpirySeconds;
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (codeExpiresInSeconds.value <= 0) {
        t.cancel();
        return;
      }
      codeExpiresInSeconds.value--;
    });
  }

  @override
  void onInit() {
    super.onInit();
    startCodeExpiry();
  }

  @override
  void onClose() {
    _expiryTimer?.cancel();
    cooldown.dispose();
    super.onClose();
  }

  // ── Eski API'ler (aynen korundu) ───────────────────────────────────
  Future<void> verifyOtp({required String email, required String otp}) async {
    if (isVerifyingOtp.value) return;
    isVerifyingOtp.value = true;
    errorMessage.value = '';

    try {
      await _repo.verifyEmailOtp(email: email, token: otp);
      // İzin dialogu burada AÇILMAZ; tercih ekranında kullanıcının
      // seçimine göre istenir.
      await _session.onLogin(requestNotificationPermission: false);
      Get.offAllNamed(AppRoutes.signupPreferences);
    } on AuthRateLimitException catch (e) {
      errorMessage.value = e.toString();
    } on AuthNetworkException catch (e) {
      errorMessage.value = e.toString();
    } catch (e, st) {
      log('verifyOtp failed: $e', error: e, stackTrace: st);
      errorMessage.value =
          'Kod hatalı veya süresi dolmuş. Lütfen tekrar deneyin.';
      clearCode(); // yanlış kodu temizle, kullanıcı baştan girsin
      AnalyticsService.instance.logEvent('otp_verification_failed');
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  Future<void> resendOtp({required String email}) async {
    if (cooldown.isActive || isResendingOtp.value) return;
    isResendingOtp.value = true;
    errorMessage.value = '';

    try {
      await _repo.resendVerificationOtp(email: email);
      cooldown.start();
      startCodeExpiry(); // yeni kodun geçerlilik süresi yeniden başlar
    } on AuthRateLimitException catch (e) {
      errorMessage.value = e.toString();
    } catch (e, st) {
      log('resendOtp failed: $e', error: e, stackTrace: st);
      errorMessage.value = 'Kod gönderilemedi. Lütfen tekrar deneyin.';
    } finally {
      isResendingOtp.value = false;
    }
  }
}