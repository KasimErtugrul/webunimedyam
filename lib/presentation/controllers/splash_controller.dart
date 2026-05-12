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

    if (authRepository.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}