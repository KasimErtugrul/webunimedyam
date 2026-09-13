import 'dart:developer';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({required AuthRepository authRepository})
      : _repo = authRepository;

  final AuthRepository _repo;

  final isLoading = false.obs;
  final isSendingResetOtp = false.obs;
  final errorMessage = ''.obs;

  Future<void> sendPasswordResetOtp({required String email}) async {
    if (isSendingResetOtp.value) return;
    isSendingResetOtp.value = true;
    errorMessage.value = '';

    try {
      await _repo.sendPasswordResetOtp(email: email);
      Get.toNamed(AppRoutes.resetPassword, arguments: {'email': email});
    } catch (e, st) {
      log('sendPasswordResetOtp failed: $e', error: e, stackTrace: st);
      errorMessage.value =
          'Kod gönderilemedi. Email adresinizi kontrol edin.';
    } finally {
      isSendingResetOtp.value = false;
    }
  }
}