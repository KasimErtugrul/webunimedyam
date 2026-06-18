import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../app/routes/app_routes.dart';
import '../../services/notification_service.dart';
import 'favorites_controller.dart';
import 'home_controller.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({required this.authRepository});

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ─── Sign In ──────────────────────────────────────────────────────────────
  /// Kullanıcı giriş yapmamıza yardımcı olur.
  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await authRepository.signIn(email: email, password: password);

      // Login başarılı → FCM token'ı Supabase'e kaydet
      await NotificationService.instance.onUserLogin();

      Get.offAllNamed(AppRoutes.home);
    } catch (e, st) {
      log('Sign in error: $e', stackTrace: st);
      errorMessage.value = 'Giriş başarısız. Email ve şifrenizi kontrol edin.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Sign Up ──────────────────────────────────────────────────────────────
  /// Yeni bir kullanıcı kaydetmeyi sağlar.
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

      // Kayıt başarılı → FCM token'ı Supabase'e kaydet
      await NotificationService.instance.onUserLogin();

      Get.offAllNamed(AppRoutes.home);
    } catch (e, st) {
      log('Sign up error: $e', stackTrace: st);
      errorMessage.value = 'Kayıt başarısız. Bilgilerinizi kontrol edin.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────
  /// Kullanıcıdan oturumunu kapatır.
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      // Logout öncesi FCM token'ı Supabase'den sil
      await NotificationService.instance.onUserLogout();

      await authRepository.signOut();

      // Bağımlı controller'ları resetle
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().favoriteIds.clear();
      }
      if (Get.isRegistered<FavoritesController>()) {
        Get.find<FavoritesController>().favoriteVideos.clear();
      }

      Get.offAllNamed(AppRoutes.home);
    } catch (e, st) {
      log('Sign out error: $e', stackTrace: st);
      errorMessage.value = 'Çıkış yapılırken hata oluştu.';
    } finally {
      isLoading.value = false;
    }
  }
}
