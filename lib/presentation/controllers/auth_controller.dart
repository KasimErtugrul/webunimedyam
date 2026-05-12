import 'dart:developer';

import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await authRepository.signIn(email: email, password: password);

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = 'Giriş başarısız. Email ve şifrenizi kontrol edin.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await authRepository.signUp(
        email: email,
        password: password,
        username: username,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e, stacktrace) {
      log('Sign up error: $e', stackTrace: stacktrace);
      errorMessage.value = 'Kayıt başarısız. Bilgilerinizi kontrol edin.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = 'Çıkış yapılırken hata oluştu.';
    }
  }
}
