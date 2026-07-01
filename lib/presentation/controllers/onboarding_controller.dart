import 'dart:developer';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/analytics_service.dart';

class OnboardingController extends GetxController {
  final AuthRepository authRepository;
  OnboardingController({required this.authRepository});

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