import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';

class OnboardingController extends GetxController {
  final AuthRepository authRepository;
  OnboardingController({required this.authRepository});

  Future<void> complete() async {
    await authRepository.completeOnboarding();
    Get.offAllNamed(AppRoutes.home);
  }
}