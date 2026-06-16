// lib/presentation/controllers/profile_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/profile_activity_repository.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/video_model.dart';
import 'settings_controller.dart';

class ProfileController extends GetxController {
  final AuthRepository authRepository;
  final FavoritesRepository favoritesRepository;
  final ProfileActivityRepository profileActivityRepository;

  ProfileController({
    required this.authRepository,
    required this.favoritesRepository,
    required this.profileActivityRepository,
  });

  // ─── Profil & Ayarlar ─────────────────────────────────────────────────────
  final profile = Rxn<ProfileModel>();
  final isLoading = false.obs;

  // ─── Aktivite Listeleri ───────────────────────────────────────────────────
  final favoriteVideos = <VideoModel>[].obs;
  final viewedVideos = <VideoModel>[].obs;
  final commentedVideos = <VideoModel>[].obs;
  final sharedVideos = <VideoModel>[].obs;

  final isFavoritesLoading = false.obs;
  final isViewedLoading = false.obs;
  final isCommentedLoading = false.obs;
  final isSharedLoading = false.obs;

  final successMessage = RxnString();
  final errorMessage = RxnString();

  final selectedTabIndex = 0.obs;

  // ─── Kimlik ───────────────────────────────────────────────────────────────

  String? get _currentUserId => authRepository.currentUserId;

  /// Route arguments'tan gelen hedef userId.
  /// null ise kendi profilimiz demektir.
  String? get targetUserId {
    final args = Get.arguments as Map<String, dynamic>?;
    return args?['userId'] as String?;
  }

  @override
  onInit() {
    super.onInit();
    loadProfile();
  }

  /// Kendi profilimiz mi görüntülüyoruz?
  bool get isOwnProfile {
    final target = targetUserId;
    return target == null || target == _currentUserId;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /* @override
  void onReady() {
    super.onReady();
    final tag = targetUserId ?? (_currentUserId ?? 'anonymous');
    loadProfile().then((_) {
      final targetId = targetUserId ?? _currentUserId;
      if (targetId != null && Get.isRegistered<FollowController>(tag: tag)) {
        Get.find<FollowController>(tag: tag).initForProfile(targetId);
      }
    });
  } */

  // ─── Profil Yükleme ──────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      if (isOwnProfile) {
        log('profile controller getprofile tetiklendi');
        profile.value = await authRepository.getProfile();
      } else {
        final tid = targetUserId;
        if (tid != null) {
          profile.value = await authRepository.getProfileById(tid);
        }
      }
    } catch (e) {
      log('loadProfile error: $e');
    } finally {
      isLoading.value = false;
    }

    // Profil yüklenince SettingsController'ı senkronize et
    final p = profile.value;
    if (p != null && Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().profileVisibility.value =
          p.profileVisibility;
    }

    _loadAllActivities();
  }

  Future<void> _loadAllActivities() async {
    final userId = isOwnProfile ? _currentUserId : targetUserId;
    if (userId == null) return;

    // Her iki durumda da aynı metodları çağır.
    // RLS zaten izin kontrolünü yapıyor — izin yoksa boş döner.
    await Future.wait([
      loadFavorites(userId),
      loadViewedVideos(userId),
      loadCommentedVideos(userId),
      loadSharedVideos(userId),
    ]);
  }

  // ─── Aktivite Yükleme ────────────────────────────────────────────────────

  Future<void> loadFavorites([String? uid]) async {
    try {
      isFavoritesLoading.value = true;
      final userId = uid ?? _currentUserId;
      if (userId == null) return;
      favoriteVideos.value = await favoritesRepository.getUserFavoriteVideos(
        userId,
      );
    } catch (e) {
      log('loadFavorites error: $e');
    } finally {
      isFavoritesLoading.value = false;
    }
  }

  Future<void> loadViewedVideos([String? uid]) async {
    final userId = uid ?? _currentUserId;
    if (userId == null) return;
    try {
      isViewedLoading.value = true;
      viewedVideos.value = await profileActivityRepository.getUserViewedVideos(
        userId,
      );
    } catch (e) {
      log('loadViewedVideos error: $e');
    } finally {
      isViewedLoading.value = false;
    }
  }

  Future<void> loadCommentedVideos([String? uid]) async {
    final userId = uid ?? _currentUserId;
    if (userId == null) return;
    try {
      isCommentedLoading.value = true;
      commentedVideos.value = await profileActivityRepository
          .getUserCommentedVideos(userId);
    } catch (e) {
      log('loadCommentedVideos error: $e');
    } finally {
      isCommentedLoading.value = false;
    }
  }

  Future<void> loadSharedVideos([String? uid]) async {
    final userId = uid ?? _currentUserId;
    if (userId == null) return;
    try {
      isSharedLoading.value = true;
      sharedVideos.value = await profileActivityRepository.getUserSharedVideos(
        userId,
      );
    } catch (e) {
      log('loadSharedVideos error: $e');
    } finally {
      isSharedLoading.value = false;
    }
  }

  // ─── Profil Güncelleme ────────────────────────────────────────────────────

  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    // GÜVENLİK: Sadece kendi profilini güncelleyebilir
    if (!isOwnProfile) {
      log('updateProfile: başkasının profili güncellenemez!');
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
    } catch (e) {
      log('updateProfile error: $e');
      errorMessage.value = 'Profil güncellenemedi.';
    }
  }

  // ─── Yardımcılar ──────────────────────────────────────────────────────────

  void changeTab(int index) => selectedTabIndex.value = index;

  bool get isLoggedIn => authRepository.isLoggedIn;

  /*  bool canViewTab(VisibilityOption visibility) {
    if (isOwnProfile) return true;
    if (visibility == VisibilityOption.public) return true;

    final targetId = targetUserId;
    if (targetId == null) return false;

    final followCtrl = Get.isRegistered<FollowController>(tag: targetId)
        ? Get.find<FollowController>(tag: targetId)
        : null;
    final isFollowing = followCtrl?.isFollowing(targetId) ?? false;

    if (visibility == VisibilityOption.friends && isFollowing) return true;
    return false;
  } */

  Future<void> refreshProfile() async => loadProfile();
}
