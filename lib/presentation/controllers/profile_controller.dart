// lib/presentation/controllers/profile_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/errors/username_taken_exception.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/user_stats_model.dart';
import 'settings_controller.dart';

class ProfileController extends GetxController {
  final AuthRepository authRepository;
  final StatsRepository statsRepository;

  ProfileController({
    required this.authRepository,
    required this.statsRepository,
  });

  // ─── Profil & Ayarlar ─────────────────────────────────────────────────────
  final profile = Rxn<ProfileModel>();
  final isLoading = false.obs;

  final successMessage = RxnString();
  final errorMessage = RxnString();

  final isUploadingAvatar = false.obs;
  final isSavingProfile = false.obs;

  // ─── Özet İstatistikler (profil başlığı) ───────────────────────────────────
  // Sadece kendi profilimizde doldurulur (get_my_stats RPC'si auth.uid()
  // üzerinden çalışır, başka kullanıcı için veri döndürmez).
  final stats = Rxn<UserStatsModel>();
  final isLoadingStats = false.obs;

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
    });

    // İstatistik şeridi yalnızca kendi profilimizde anlamlı; başkasının
    // profilinde gösterilmiyor, bu yüzden orada boşuna istek atmıyoruz.
    if (isOwnProfile) {
      loadStats();
    }
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

  // ─── Özet İstatistikleri Yükleme ───────────────────────────────────────────

  Future<void> loadStats({bool forceRefresh = false}) async {
    if (!isOwnProfile) return;
    try {
      isLoadingStats.value = true;
      stats.value = await statsRepository.getUserStats(
        forceRefresh: forceRefresh,
      );
    } catch (e, stacktrace) {
      log(
        'Profil istatistikleri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    } finally {
      isLoadingStats.value = false;
    }
  }

  // ─── Profil Güncelleme ────────────────────────────────────────────────────

  Future<bool> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    if (!isOwnProfile) {
      errorMessage.value = 'Bu profili düzenleme yetkiniz yok.';
      return false;
    }

    final current = profile.value;
    if (current == null) return false;

    try {
      isSavingProfile.value = true;
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

      return true;
    } on UsernameTakenException {
      // Genel "Profil güncellenemedi" mesajından kasıtlı olarak ayrı:
      // kullanıcı burada spesifik olarak "bu isim tutuluyor, başka bir
      // tane dene" bilgisini almalı, aksi halde hangi alanın sorunlu
      // olduğunu anlayamaz.
      errorMessage.value = 'Bu kullanıcı adı zaten alınmış.';
      return false;
    } catch (e, stacktrace) {
      log(
        'Profil güncellenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Profil güncellenemedi.';
      return false;
    } finally {
      isSavingProfile.value = false;
    }
  }

  // ─── Profil Fotoğrafı ─────────────────────────────────────────────────────

  /// Galeriden fotoğraf seçtirir, sıkıştırır, Supabase Storage'a yükler
  /// ve profiles.avatar_url alanını günceller.
  Future<void> pickAndUploadAvatar({
    ImageSource source = ImageSource.gallery,
  }) async {
    if (!isOwnProfile) {
      errorMessage.value = 'Bu profili düzenleme yetkiniz yok.';
      return;
    }
    if (isUploadingAvatar.value) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null) return; // Kullanıcı seçimi iptal etti

      isUploadingAvatar.value = true;

      final bytes = await picked.readAsBytes();

      // Boyut güvenliği: bucket zaten 5MB sınırlı ama erken kullanıcı
      // geri bildirimi için burada da kontrol ediyoruz.
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        errorMessage.value =
            'Fotoğraf çok büyük. Lütfen 5MB altında bir fotoğraf seçin.';
        return;
      }

      var extension = picked.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        extension = 'jpg';
      }

      final avatarUrl = await authRepository.uploadAvatar(
        bytes: bytes,
        fileExtension: extension,
      );

      final current = profile.value;
      if (current != null) {
        profile.value = current.copyWith(avatarUrl: avatarUrl);
      }

      successMessage.value = 'Profil fotoğrafı güncellendi.';
    } catch (e, stacktrace) {
      log(
        'Profil fotoğrafı yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value =
          'Profil fotoğrafı yüklenemedi. Lütfen tekrar deneyin.';
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  // ─── Yardımcılar ──────────────────────────────────────────────────────────

  bool get isLoggedIn => authRepository.isLoggedIn;

  Future<void> refreshProfile() async {
    try {
      await loadProfile();
      if (isOwnProfile) {
        await loadStats(forceRefresh: true);
      }
    } catch (e, stacktrace) {
      log(
        'Profil yenilenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }
}
