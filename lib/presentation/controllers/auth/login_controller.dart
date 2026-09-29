import 'dart:developer';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/auth_exceptions.dart';
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
      // Kayıt akışı yarım kaldıysa (tercihler / üniversite seçimi) kaldığı
      // yerden devam et; bu durumda bildirim izni tercih ekranında sorulur.
      final completed = await _repo.isSignupCompleted();
      await _session.onLogin(requestNotificationPermission: completed);
      AnalyticsService.instance.logLogin(method: 'email');
      Get.offAllNamed(
        completed ? AppRoutes.home : AppRoutes.signupPreferences,
      );
    } on EmailNotConfirmedException {
      // Şifre doğru ama e-posta kodu hiç girilmemiş: hesabı doğrulatmadan
      // içeri almıyoruz. Yeni kod gönderip doğrudan OTP ekranına götür.
      AnalyticsService.instance.logEvent('login_unverified_redirect');
      try {
        await _repo.resendVerificationOtp(email: email);
      } catch (e, st) {
        // Rate limit vb. — OTP ekranında zaten "Tekrar gönder" var.
        log('unverified resend failed: $e', error: e, stackTrace: st);
      }
      Get.toNamed(AppRoutes.otpVerification, arguments: {'email': email});
    } on InvalidCredentialsException {
      errorMessage.value = 'E-posta veya şifre hatalı.';
      AnalyticsService.instance.logEvent(
        'login_failed',
        parameters: {'method': 'email', 'reason': 'invalid_credentials'},
      );
    } on AuthRateLimitException catch (e) {
      errorMessage.value = e.toString();
    } on AuthNetworkException catch (e) {
      errorMessage.value = e.toString();
    } catch (e, st) {
      log('signIn failed: $e', error: e, stackTrace: st);
      errorMessage.value = 'Giriş başarısız. Lütfen tekrar deneyin.';
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
      await _repo.signInWithGoogle();
      // Yeni (ya da akışı yarım bırakmış) kullanıcıda bildirim izni
      // SignupPreferences ekranında sorulur. Karar `isNewUser` tahmininden
      // (createdAt/lastSignIn farkı) değil, sunucudaki signup_completed
      // bayrağından gelir.
      final completed = await _repo.isSignupCompleted();
      await _session.onLogin(requestNotificationPermission: completed);
      Get.offAllNamed(
        completed ? AppRoutes.home : AppRoutes.signupPreferences,
      );
    } on GoogleSignInCancelledException {
      // Kullanıcı iptal etti — sessiz geç.
    } on AuthNetworkException catch (e) {
      errorMessage.value = e.toString();
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