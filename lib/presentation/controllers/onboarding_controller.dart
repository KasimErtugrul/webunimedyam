import 'dart:developer';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

class OnboardingController extends GetxController {
  final AuthRepository authRepository;
  OnboardingController({required this.authRepository});

  /// Onboarding'i tamamlanmış olarak işaretler ama Home'a yönlendirmez.
  /// "Giriş Yap" seçildiğinde kullanılır: bir sonraki adımda ekran
  /// kendi Login ekranına yönlendirmesini yapar.
  Future<void> completeSilently() async {
    try {
      await authRepository.completeOnboarding();
    } catch (e, stacktrace) {
      log(
        'Onboarding tamamlama işlemi sırasında hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> complete() async {
    try {
      await authRepository.completeOnboarding();

      Get.offAllNamed(AppRoutes.home);
    } catch (e, stacktrace) {
      log(
        'Onboarding tamamlama işlemi sırasında hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );

      Get.snackbar(
        'Hata',
        'Onboarding tamamlanırken bir hata oluştu. Lütfen tekrar deneyin.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
