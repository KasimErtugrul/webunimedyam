// lib/presentation/controllers/profile_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/profile_model.dart';
import '../../services/analytics_service.dart';
import 'settings_controller.dart';

class ProfileController extends GetxController {
  final AuthRepository authRepository;

  ProfileController({required this.authRepository});

  // ─── Profil & Ayarlar ─────────────────────────────────────────────────────
  final profile = Rxn<ProfileModel>();
  final isLoading = false.obs;

  final successMessage = RxnString();
  final errorMessage = RxnString();

  // ─── Kimlik ───────────────────────────────────────────────────────────────

  String? get _currentUserId => authRepository.currentUserId;

  /// Route arguments'tan gelen hedef userId.
  /// null ise kendi profilimiz demektir.
  ///
  /// NOT: Profil sekmesi home_screen.dart'ta IndexedStack içinde tutulduğu
  /// için her görünüme geçişte gerçek bir Get.toNamed çağrısı yapılmıyor.
  /// Bu yüzden Get.arguments, bu ekranla alakasız bir önceki navigasyondan
  /// kalma bir değer (örn. player'a geçişte gönderilen bir VideoModel)
  /// olabilir. Sert cast bunu TypeError'a çevirip crash'e yol açıyordu
  /// (bkz. Crashlytics: ProfileController.targetUserId). Bu yüzden tip
  /// kontrolünü güvenli (is-check) şekilde yapıyoruz — profile_screen.dart
  /// ve profile_binding.dart'taki aynı düzeltmeyle tutarlı.
  String? get targetUserId {
    final rawArgs = Get.arguments;
    final args = rawArgs is Map<String, dynamic> ? rawArgs : null;
    return args?['userId'] as String?;
  }

  @override
  void onInit() {
    super.onInit();
    loadProfile().then((_) {
      // Sadece ekrana ilk girişte logla; refreshProfile() (pull-to-refresh)
      // aynı loadProfile()'ı tekrar çağırdığı için burada değil, doğrudan
      // onInit akışında bir kereliğine tetikleniyor.
      AnalyticsService.instance.logEvent('profile_view', parameters: {
        'own_profile': isOwnProfile.toString(),
      });
    });
  }

  /// Kendi profilimiz mi görüntülüyoruz?
  bool get isOwnProfile {
    final target = targetUserId;
    return target == null || target == _currentUserId;
  }

  // ─── Profil Yükleme ──────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      if (isOwnProfile) {
        profile.value = await authRepository.getProfile();
      } else {
        final tid = targetUserId;
        if (tid != null) {
          profile.value = await authRepository.getProfileById(tid);
        }
      }
    } catch (e, stacktrace) {
      log(
        'Profil yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Profil yüklenemedi.';
    } finally {
      isLoading.value = false;
    }

    // Profil yüklenince SettingsController'ı senkronize et
    try {
      final p = profile.value;
      if (p != null && Get.isRegistered<SettingsController>()) {
        Get.find<SettingsController>().profileVisibility.value =
            p.profileVisibility;
      }
    } catch (e, stacktrace) {
      log(
        'SettingsController senkronizasyonu sırasında hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Profil Güncelleme ────────────────────────────────────────────────────

  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    if (!isOwnProfile) {
      errorMessage.value = 'Bu profili düzenleme yetkiniz yok.';
      return;
    }

    final current = profile.value;
    if (current == null) return;

    try {
      final updated = current.copyWith(
        username: username,
        fullName: fullName,
        avatarUrl: avatarUrl,
      );
      await authRepository.updateProfile(updated);
      profile.value = updated;
      successMessage.value = 'Profil güncellendi.';

      // Gerçek değerleri değil, hangi alanların değiştiğini logluyoruz
      // (kullanıcı adı/avatar gibi kişisel veriyi Analytics'e taşımamak için).
      AnalyticsService.instance.logEvent('profile_update', parameters: {
        'username_changed':
            (username != null && username != current.username).toString(),
        'full_name_changed':
            (fullName != null && fullName != current.fullName).toString(),
        'avatar_changed':
            (avatarUrl != null && avatarUrl != current.avatarUrl).toString(),
      });
    } catch (e, stacktrace) {
      log(
        'Profil güncellenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Profil güncellenemedi.';
    }
  }

  // ─── Yardımcılar ──────────────────────────────────────────────────────────

  bool get isLoggedIn => authRepository.isLoggedIn;

  Future<void> refreshProfile() async {
    try {
      await loadProfile();
    } catch (e, stacktrace) {
      log(
        'Profil yenilenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }
}