import 'dart:developer';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/username_taken_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/analytics_service.dart';
import '../../../services/session_service.dart';

const String _kAuthMethod = 'email';

class RegisterController extends GetxController {
  RegisterController({
    required AuthRepository authRepository,
    required SessionService sessionService,
  })  : _repo = authRepository,
        _session = sessionService;

  final AuthRepository _repo;
  final SessionService _session;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final needsVerification = await _repo.signUp(
        email: email,
        password: password,
        username: username,
      );

      if (needsVerification) {
        Get.toNamed(AppRoutes.otpVerification, arguments: {'email': email});
        return;
      }

      await _session.onLogin();
      AnalyticsService.instance.logSignUp(method: _kAuthMethod);
      Get.offAllNamed(AppRoutes.home);
    } on UsernameTakenException {
      errorMessage.value =
          'Bu kullanıcı adı zaten alınmış. Lütfen başka bir tane deneyin.';
      AnalyticsService.instance.logEvent(
        'sign_up_failed',
        parameters: {'method': _kAuthMethod, 'reason': 'username_taken'},
      );
    } catch (e, st) {
      log('signUp failed: $e', error: e, stackTrace: st);
      errorMessage.value = 'Kayıt başarısız. Bilgilerinizi kontrol edin.';
      AnalyticsService.instance.logEvent(
        'sign_up_failed',
        parameters: {'method': _kAuthMethod},
      );
    } finally {
      isLoading.value = false;
    }
  }
}