import 'dart:developer';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/auth_exceptions.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/analytics_service.dart';
import '../utils/resend_cooldown.dart';

class ResetPasswordController extends GetxController {
  ResetPasswordController({required AuthRepository authRepository})
      : _repo = authRepository;

  final AuthRepository _repo;

  final isVerifyingReset = false.obs;
  final isResendingResetOtp = false.obs;
  final errorMessage = ''.obs;
  final cooldown = ResendCooldown();

  // Kod doğrulandı (recovery session açık) ama yeni şifre henüz
  // ayarlanamadı. true iken tekrar denemede KOD YENİDEN DOĞRULANMAZ —
  // Supabase kodu tek kullanımlık; tekrar doğrulamak "kod hatalı" sanılırdı.
  bool _codeVerified = false;
  bool _completed = false;

  /// Eski API uyumu.
  RxInt get resetResendCooldown => cooldown.seconds;

  @override
  void onClose() {
    // Kod doğrulanıp şifre belirlenmeden ekran terk edilirse geçici
    // recovery oturumu açık kalmasın.
    if (_codeVerified && !_completed) {
      _repo.signOut().catchError((_) {});
    }
    cooldown.dispose();
    super.onClose();
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    if (isVerifyingReset.value) return;
    isVerifyingReset.value = true;
    errorMessage.value = '';

    try {
      if (!_codeVerified) {
        await _repo.verifyPasswordResetCode(email: email, otp: otp);
        _codeVerified = true;
      }
      await _repo.setNewPasswordAfterReset(newPassword: newPassword);
      _completed = true;
      AnalyticsService.instance.logEvent('password_reset_completed');

      await _repo.signOut();
      Get.offAllNamed(AppRoutes.login);
    } on PasswordRejectedException catch (e) {
      // Kod doğru; sadece yeni şifre reddedildi. Kullanıcı şifreyi düzeltip
      // tekrar bassın, kod tekrar sorulmayacak.
      errorMessage.value = e.message;
      AnalyticsService.instance.logEvent(
        'password_reset_failed',
        parameters: {'reason': 'password_rejected'},
      );
    } on AuthRateLimitException catch (e) {
      errorMessage.value = e.toString();
    } on AuthNetworkException catch (e) {
      errorMessage.value = e.toString();
    } catch (e, st) {
      log('confirmPasswordReset failed: $e', error: e, stackTrace: st);
      errorMessage.value = _codeVerified
          ? 'Şifre güncellenemedi. Lütfen tekrar deneyin.'
          : 'Kod hatalı veya süresi dolmuş. Lütfen tekrar deneyin.';
      AnalyticsService.instance.logEvent('password_reset_failed');
    } finally {
      isVerifyingReset.value = false;
    }
  }

  Future<void> resendPasswordResetOtp({required String email}) async {
    if (cooldown.isActive || isResendingResetOtp.value) return;
    isResendingResetOtp.value = true;
    errorMessage.value = '';

    try {
      await _repo.resendPasswordResetOtp(email: email);
      _codeVerified = false; // yeni kod gönderildi; bir sonraki denemede yeniden doğrula
      cooldown.start();
    } catch (e, st) {
      log('resendPasswordResetOtp failed: $e', error: e, stackTrace: st);
      errorMessage.value = 'Kod gönderilemedi. Lütfen tekrar deneyin.';
    } finally {
      isResendingResetOtp.value = false;
    }
  }
}