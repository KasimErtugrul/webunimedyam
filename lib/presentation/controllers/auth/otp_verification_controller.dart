import 'dart:developer';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/analytics_service.dart';
import '../../../services/session_service.dart';
import '../utils/resend_cooldown.dart';

class OtpVerificationController extends GetxController {
  OtpVerificationController({
    required AuthRepository authRepository,
    required SessionService sessionService,
  })  : _repo = authRepository,
        _session = sessionService;

  final AuthRepository _repo;
  final SessionService _session;

  final isVerifyingOtp = false.obs;
  final isResendingOtp = false.obs;
  final errorMessage = ''.obs;
  final cooldown = ResendCooldown();

  /// `OtpResendButton` eski API'si için (sayısal alan).
  RxInt get resendCooldown => cooldown.seconds;

  @override
  void onClose() {
    cooldown.dispose();
    super.onClose();
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    if (isVerifyingOtp.value) return;
    isVerifyingOtp.value = true;
    errorMessage.value = '';

    try {
      await _repo.verifyEmailOtp(email: email, token: otp);
      await _session.onLogin();
      Get.offAllNamed(AppRoutes.signupPreferences);
    } catch (e, st) {
      log('verifyOtp failed: $e', error: e, stackTrace: st);
      errorMessage.value =
          'Kod hatalı veya süresi dolmuş. Lütfen tekrar deneyin.';
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
    } catch (e, st) {
      log('resendOtp failed: $e', error: e, stackTrace: st);
      errorMessage.value = 'Kod gönderilemedi. Lütfen tekrar deneyin.';
    } finally {
      isResendingOtp.value = false;
    }
  }
}