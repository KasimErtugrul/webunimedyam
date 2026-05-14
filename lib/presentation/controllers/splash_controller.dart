import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthRepository authRepository;

  SplashController({required this.authRepository});

  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final onboardingCompleted = await authRepository.isOnboardingCompleted();

    if (!onboardingCompleted) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    // Auth olsun ya da olmasın direkt home'a git.
    // Favori / yorum gibi işlemlerde zaten auth istenir.
    Get.offAllNamed(AppRoutes.home);
  }
}