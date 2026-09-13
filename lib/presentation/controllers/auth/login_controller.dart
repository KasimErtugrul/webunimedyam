import 'dart:developer';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/google_sign_in_cancelled_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/analytics_service.dart';
import '../../../services/session_service.dart';

class LoginController extends GetxController {
  LoginController({
    required AuthRepository authRepository,
    required SessionService sessionService,
  })  : _repo = authRepository,
        _session = sessionService;

  final AuthRepository _repo;
  final SessionService _session;

  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _repo.signIn(email: email, password: password);
      await _session.onLogin();
      AnalyticsService.instance.logLogin(method: 'email');
      Get.offAllNamed(AppRoutes.home);
    } catch (e, st) {
      log('signIn failed: $e', error: e, stackTrace: st);
      errorMessage.value = 'Giriş başarısız. Email ve şifrenizi kontrol edin.';
      AnalyticsService.instance.logEvent(
        'login_failed',
        parameters: {'method': 'email'},
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (isGoogleLoading.value) return;
    isGoogleLoading.value = true;
    errorMessage.value = '';

    try {
      final isNewUser = await _repo.signInWithGoogle();
      await _session.onLogin();

      if (isNewUser) {
        Get.offAllNamed(AppRoutes.signupPreferences);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } on GoogleSignInCancelledException {
      // Kullanıcı iptal etti — sessiz geç.
    } catch (e, st) {
      log('google sign-in failed: $e', error: e, stackTrace: st);
      errorMessage.value = 'Google ile giriş başarısız. Lütfen tekrar deneyin.';
      AnalyticsService.instance.logEvent(
        'login_failed',
        parameters: {'method': 'google'},
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }
}