import 'dart:developer';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
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

  /// Eski API uyumu.
  RxInt get resetResendCooldown => cooldown.seconds;

  @override
  void onClose() {
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
      await _repo.confirmPasswordReset(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      AnalyticsService.instance.logEvent('password_reset_completed');

      await _repo.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e, st) {
      log('confirmPasswordReset failed: $e', error: e, stackTrace: st);
      errorMessage.value =
          'Kod hatalı veya süresi dolmuş. Lütfen tekrar deneyin.';
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
      cooldown.start();
    } catch (e, st) {
      log('resendPasswordResetOtp failed: $e', error: e, stackTrace: st);
      errorMessage.value = 'Kod gönderilemedi. Lütfen tekrar deneyin.';
    } finally {
      isResendingResetOtp.value = false;
    }
  }
}