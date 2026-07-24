import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
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
  final isGoogleLoading = false.obs;
  final errorMessage = ''.obs;

  // ─── Email OTP Doğrulama ────────────────────────────────────────────────
  /// Kayıt sonrası onay bekleyen kullanıcının email'i (OTP ekranını
  /// önceden doldurmak ve "tekrar gönder" çağrısında kullanmak için).
  final pendingEmail = ''.obs;
  final isVerifyingOtp = false.obs;
  final isResendingOtp = false.obs;
  final resendCooldown = 0.obs;
  Timer? _resendTimer;

  // ─── Şifre Değiştirme (oturum açıkken) ─────────────────────────────────
  final isChangingPassword = false.obs;
  final changePasswordError = ''.obs;
  final changePasswordSuccess = false.obs;

  // ─── Şifremi Unuttum (oturum yokken) ────────────────────────────────────
  /// Kod gönderilen email (reset ekranını doldurmak ve tekrar gönder
  /// çağrısında kullanmak için).
  final pendingResetEmail = ''.obs;
  final isSendingResetOtp = false.obs;
  final isVerifyingReset = false.obs;
  final isResendingResetOtp = false.obs;
  final resetResendCooldown = 0.obs;
  Timer? _resetResendTimer;

  @override
  void onClose() {
    _resendTimer?.cancel();
    _resetResendTimer?.cancel();
    super.onClose();
  }

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

  // ─── Google ile Giriş ───────────────────────────────────────────────────
  /// Google ile giriş/kayıt. Yeni kullanıcıysa (ilk kez bu Google hesabıyla
  /// giriş yapıyorsa) email/OTP akışındakiyle tutarlı olsun diye önce
  /// İlgi Alanı Seçimi ekranına, mevcut kullanıcıysa direkt Home'a gider.
  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      errorMessage.value = '';

      final isNewUser = await authRepository.signInWithGoogle();

      if (isNewUser) {
        Get.offAllNamed(AppRoutes.interestSelection);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e, stacktrace) {
      log('Google ile giriş yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      // Kullanıcı hesap seçim ekranını iptal ettiyse sessiz geç, ekranda
      // kalsın; gerçek hatalarda mesaj göster.
      if (!e.toString().contains('iptal edildi')) {
        errorMessage.value = 'Google ile giriş başarısız. Lütfen tekrar deneyin.';
      }
      AnalyticsService.instance.logEvent('login_failed', parameters: {
        'method': 'google',
      });
    } finally {
      isGoogleLoading.value = false;
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

      final needsVerification = await authRepository.signUp(
        email: email,
        password: password,
        username: username,
      );

      if (needsVerification) {
        // "Confirm email" açık: henüz session yok, kullanıcı önce mailine
        // gelen 6 haneli kodu girmeli. FCM/analytics conversion event'i
        // OTP doğrulandığında (verifyOtp içinde) tetiklenecek.
        pendingEmail.value = email;
        _startResendCooldown();
        Get.toNamed(AppRoutes.otpVerification, arguments: {'email': email});
        return;
      }

      // "Confirm email" kapalıysa session direkt kurulur.
      await NotificationService.instance.onUserLogin();
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

  // ─── Email OTP Doğrulama ────────────────────────────────────────────────
  /// Kullanıcının email'ine gelen 6 haneli kodu doğrular. Başarılıysa
  /// session kurulur ve Home'a yönlendirilir.
  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      isVerifyingOtp.value = true;
      errorMessage.value = '';

      await authRepository.verifyEmailOtp(email: email, token: otp);

      // Yeni kayıt olan kullanıcıya, ana sayfaya gitmeden önce ilgilendiği
      // üniversiteleri seçme fırsatı sunuyoruz. Bu ekran zorunlu değildir;
      // kullanıcı "Atla" diyerek de Home'a geçebilir. Bu ekran bir daha
      // gösterilmeyecek şekilde InterestSelectionController tarafından
      // işaretlenir.
      Get.offAllNamed(AppRoutes.interestSelection);
    } catch (e, stacktrace) {
      log('OTP doğrulanırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Kod hatalı veya süresi dolmuş. Lütfen tekrar deneyin.';

      AnalyticsService.instance.logEvent('otp_verification_failed');
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  /// Onay kodunu tekrar gönderir. Spam'i önlemek için 60 saniyelik
  /// bekleme (cooldown) süresi boyunca tekrar tetiklenmez.
  Future<void> resendOtp({required String email}) async {
    if (resendCooldown.value > 0 || isResendingOtp.value) return;

    try {
      isResendingOtp.value = true;
      errorMessage.value = '';

      await authRepository.resendVerificationOtp(email: email);
      _startResendCooldown();
    } catch (e, stacktrace) {
      log('OTP tekrar gönderilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Kod gönderilemedi. Lütfen tekrar deneyin.';
    } finally {
      isResendingOtp.value = false;
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    resendCooldown.value = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown.value <= 1) {
        resendCooldown.value = 0;
        timer.cancel();
      } else {
        resendCooldown.value--;
      }
    });
  }

  // ─── Şifre Değiştirme (oturum açıkken) ─────────────────────────────────
  /// Mevcut şifreyi doğrulayıp yenisiyle değiştirir.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isChangingPassword.value = true;
      changePasswordError.value = '';
      changePasswordSuccess.value = false;

      await authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      changePasswordSuccess.value = true;
      AnalyticsService.instance.logEvent('password_changed');

      await Get.dialog(
        AlertDialog(
          title: const Text('Şifre Değiştirildi'),
          content: const Text('Şifreniz başarıyla güncellendi.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Tamam'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      Get.back();
    } catch (e, stacktrace) {
      log('Şifre değiştirilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      changePasswordError.value =
          'Şifre değiştirilemedi. Mevcut şifrenizi kontrol edin.';
    } finally {
      isChangingPassword.value = false;
    }
  }

  /// Değiştirme ekranından çıkılıp tekrar girildiğinde eski hata/başarı
  /// durumunun görünmemesi için sıfırlar.
  void resetChangePasswordState() {
    changePasswordError.value = '';
    changePasswordSuccess.value = false;
  }

  // ─── Şifremi Unuttum (oturum yokken) ────────────────────────────────────
  /// Şifre sıfırlama kodunu email'e gönderir ve kod giriş ekranına yönlendirir.
  Future<void> sendPasswordResetOtp({required String email}) async {
    try {
      isSendingResetOtp.value = true;
      errorMessage.value = '';

      await authRepository.sendPasswordResetOtp(email: email);

      pendingResetEmail.value = email;
      _startResetResendCooldown();
      Get.toNamed(AppRoutes.resetPassword, arguments: {'email': email});
    } catch (e, stacktrace) {
      log('Şifre sıfırlama kodu gönderilirken hata oluştu: $e',
          error: e, stackTrace: stacktrace);
      errorMessage.value = 'Kod gönderilemedi. Email adresinizi kontrol edin.';
    } finally {
      isSendingResetOtp.value = false;
    }
  }

  /// Kodu ve yeni şifreyi doğrular; başarılıysa Login ekranına döner.
  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      isVerifyingReset.value = true;
      errorMessage.value = '';

      await authRepository.confirmPasswordReset(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      AnalyticsService.instance.logEvent('password_reset_completed');

      // Recovery akışı sırasında geçici bir session kurulmuş olabilir;
      // kullanıcı yeni şifresiyle bilinçli olarak tekrar giriş yapsın diye
      // oturumu kapatıp Login ekranına yönlendiriyoruz.
      await authRepository.signOut();
      Get.offAllNamed(AppRoutes.login);
    } catch (e, stacktrace) {
      log('Şifre sıfırlanırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Kod hatalı veya süresi dolmuş. Lütfen tekrar deneyin.';

      AnalyticsService.instance.logEvent('password_reset_failed');
    } finally {
      isVerifyingReset.value = false;
    }
  }

  /// Şifre sıfırlama kodunu tekrar gönderir.
  Future<void> resendPasswordResetOtp({required String email}) async {
    if (resetResendCooldown.value > 0 || isResendingResetOtp.value) return;

    try {
      isResendingResetOtp.value = true;
      errorMessage.value = '';

      await authRepository.resendPasswordResetOtp(email: email);
      _startResetResendCooldown();
    } catch (e, stacktrace) {
      log('Şifre sıfırlama kodu tekrar gönderilirken hata oluştu: $e',
          error: e, stackTrace: stacktrace);
      errorMessage.value = 'Kod gönderilemedi. Lütfen tekrar deneyin.';
    } finally {
      isResendingResetOtp.value = false;
    }
  }

  void _startResetResendCooldown() {
    _resetResendTimer?.cancel();
    resetResendCooldown.value = 60;
    _resetResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resetResendCooldown.value <= 1) {
        resetResendCooldown.value = 0;
        timer.cancel();
      } else {
        resetResendCooldown.value--;
      }
    });
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