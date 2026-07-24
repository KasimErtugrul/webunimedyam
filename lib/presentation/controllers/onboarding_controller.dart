import 'dart:developer';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/analytics_service.dart';

class OnboardingController extends GetxController {
  final AuthRepository authRepository;
  OnboardingController({required this.authRepository});

  /// Onboarding'i tamamlanmış olarak işaretler ama Home'a yönlendirmez.
  /// "Giriş Yap / Kayıt Ol" seçildiğinde kullanılır: bir sonraki adımda
  /// ekran kendi Login/Register'a yönlendirmesini yapar.
  Future<void> completeSilently() async {
    try {
      await authRepository.completeOnboarding();
      AnalyticsService.instance.logEvent('onboarding_complete_to_auth');
    } catch (e, stacktrace) {
      log('Onboarding tamamlama işlemi sırasında hata oluştu: $e', error: e, stackTrace: stacktrace);
      AnalyticsService.instance.recordError(e, stacktrace, reason: 'onboarding_complete_silently_failed');
    }
  }

  Future<void> complete() async {
    try {
      await authRepository.completeOnboarding();
      AnalyticsService.instance.logEvent('onboarding_complete');
      Get.offAllNamed(AppRoutes.home);
    } catch (e, stacktrace) {
      log('Onboarding tamamlama işlemi sırasında hata oluştu: $e', error: e, stackTrace: stacktrace);
      AnalyticsService.instance.recordError(e, stacktrace, reason: 'onboarding_complete_failed');
      Get.snackbar(
        'Hata',
        'Onboarding tamamlanırken bir hata oluştu. Lütfen tekrar deneyin.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}