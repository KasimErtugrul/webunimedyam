import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../app/routes/app_routes.dart';
import '../../services/notification_service.dart';
import '../../services/analytics_service.dart';
import 'favorites_controller.dart';
import 'home_controller.dart';

/// Email/şifre ile giriş-kayıt akışı tek yöntem olduğu için event
/// parametrelerinde sabit olarak kullanılıyor. İleride Google/Apple
/// girişi eklenirse ilgili çağrılarda bu değer değiştirilmeli.
const String _kAuthMethod = 'email';

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

      // auth_wall_hit sonrası dönüşümü ölçebilmek için GA4 önerilen event.
      AnalyticsService.instance.logLogin(method: _kAuthMethod);

      Get.offAllNamed(AppRoutes.home);
    } catch (e, stacktrace) {
      log('Giriş yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Giriş başarısız. Email ve şifrenizi kontrol edin.';

      // Başarısız giriş denemelerini ayrı işaretliyoruz ki "kaç kişi login
      // ekranına geldi ama şifre/email hatası yüzünden vazgeçti" görülebilsin.
      AnalyticsService.instance.logEvent('login_failed', parameters: {
        'method': _kAuthMethod,
      });
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

      // auth_wall_hit sonrası dönüşümü ölçebilmek için GA4 önerilen event.
      AnalyticsService.instance.logSignUp(method: _kAuthMethod);

      Get.offAllNamed(AppRoutes.home);
    } catch (e, stacktrace) {
      log('Kayıt olunurken hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Kayıt başarısız. Bilgilerinizi kontrol edin.';

      // Başarısız kayıt denemelerini ayrı işaretliyoruz (örn. email zaten
      // kullanımda, zayıf şifre vb. nedenlerle formu terk edenleri görmek için).
      AnalyticsService.instance.logEvent('sign_up_failed', parameters: {
        'method': _kAuthMethod,
      });
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

      AnalyticsService.instance.logLogout();

      // Bağımlı controller'ları resetle
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().favoriteIds.clear();
      }
      if (Get.isRegistered<FavoritesController>()) {
        Get.find<FavoritesController>().favoriteVideos.clear();
      }

      Get.offAllNamed(AppRoutes.home);
    } catch (e, stacktrace) {
      log('Çıkış yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Çıkış yapılırken hata oluştu.';
    } finally {
      isLoading.value = false;
    }
  }
}