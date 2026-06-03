// lib/presentation/controllers/profile_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/profile_activity_repository.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/user_settings_model.dart';
import '../../data/models/video_model.dart';
import 'follow_controller.dart';

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
  final profile   = Rxn<ProfileModel>();
  final isLoading = false.obs;

  // ─── Aktivite Listeleri ───────────────────────────────────────────────────
  final favoriteVideos   = <VideoModel>[].obs;
  final viewedVideos     = <VideoModel>[].obs;
  final commentedVideos  = <VideoModel>[].obs;
  final sharedVideos     = <VideoModel>[].obs;

  final isFavoritesLoading  = false.obs;
  final isViewedLoading     = false.obs;
  final isCommentedLoading  = false.obs;
  final isSharedLoading     = false.obs;

  final successMessage = RxnString();
  final errorMessage   = RxnString();

  final selectedTabIndex = 0.obs;

  // ─── Kimlik ───────────────────────────────────────────────────────────────

  String? get _currentUserId => authRepository.currentUserId;

  /// Route arguments'tan gelen hedef userId.
  /// Binding'de kullanılan tag ile tutarlı olmalı.
  /// null ise kendi profilimiz demektir.
  String? get targetUserId {
    final args = Get.arguments as Map<String, dynamic>?;
    return args?['userId'] as String?;
  }

  /// Kendi profilimiz mi görüntülüyoruz?
  bool get isOwnProfile {
    final target = targetUserId;
    return target == null || target == _currentUserId;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onReady() {
    super.onReady();
    final tag = targetUserId ?? (_currentUserId ?? 'anonymous');
    loadProfile().then((_) {
      final targetId = targetUserId ?? _currentUserId;
      if (targetId != null && Get.isRegistered<FollowController>(tag: tag)) {
        Get.find<FollowController>(tag: tag).initForProfile(targetId);
      }
    });
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
    } catch (e) {
      log('loadProfile error: $e');
    } finally {
      isLoading.value = false;
    }

    _loadAllActivities();
  }

  Future<void> _loadAllActivities() async {
    final userId = isOwnProfile ? _currentUserId : targetUserId;
    if (userId == null) return;

    if (isOwnProfile) {
      await Future.wait([
        loadFavorites(userId),
        loadViewedVideos(userId),
        loadCommentedVideos(userId),
        loadSharedVideos(userId),
      ]);
    } else {
      await _loadOtherUserActivities(userId);
    }
  }

  Future<void> _loadOtherUserActivities(String userId) async {
    final tag = targetUserId ?? (_currentUserId ?? 'anonymous');
    final followCtrl = Get.isRegistered<FollowController>(tag: tag)
        ? Get.find<FollowController>(tag: tag)
        : null;
    final isFollowingTarget = followCtrl?.isFollowing(userId) ?? false;

    final targetProfile = profile.value;

    final favVis = targetProfile != null
        ? _visibilityFromProfile(targetProfile, 'favorites')
        : VisibilityOption.public;
    if (_canViewActivity(favVis, isFollowingTarget)) {
      await loadFavorites(userId);
    }

    final watchVis = targetProfile != null
        ? _visibilityFromProfile(targetProfile, 'watch_history')
        : VisibilityOption.public;
    if (_canViewActivity(watchVis, isFollowingTarget)) {
      await loadViewedVideos(userId);
    }

    final commentVis = targetProfile != null
        ? _visibilityFromProfile(targetProfile, 'comments')
        : VisibilityOption.public;
    if (_canViewActivity(commentVis, isFollowingTarget)) {
      await loadCommentedVideos(userId);
    }

    await loadSharedVideos(userId);
  }

  VisibilityOption _visibilityFromProfile(ProfileModel p, String type) {
    return VisibilityOption.public;
  }

  bool _canViewActivity(VisibilityOption visibility, bool isFollowing) {
    if (visibility == VisibilityOption.public) return true;
    if (visibility == VisibilityOption.friends && isFollowing) return true;
    return false;
  }

  // ─── Aktivite Yükleme ────────────────────────────────────────────────────

  Future<void> loadFavorites([String? uid]) async {
    try {
      isFavoritesLoading.value = true;
      final userId = uid ?? _currentUserId;
      if (userId == null) return;
      favoriteVideos.value =
          await favoritesRepository.getUserFavoriteVideos(userId);
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
      viewedVideos.value =
          await profileActivityRepository.getUserViewedVideos(userId);
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
      commentedVideos.value =
          await profileActivityRepository.getUserCommentedVideos(userId);
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
      sharedVideos.value =
          await profileActivityRepository.getUserSharedVideos(userId);
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
    final current = profile.value;
    if (current == null) return;

    try {
      final updated = current.copyWith(
        username:  username,
        fullName:  fullName,
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

  bool canViewTab(VisibilityOption visibility) {
    if (isOwnProfile) return true;
    if (visibility == VisibilityOption.public) return true;

    final targetId = targetUserId;
    if (targetId == null) return false;

    final tag = targetId;
    final followCtrl = Get.isRegistered<FollowController>(tag: tag)
        ? Get.find<FollowController>(tag: tag)
        : null;
    final isFollowing = followCtrl?.isFollowing(targetId) ?? false;

    if (visibility == VisibilityOption.friends && isFollowing) return true;
    return false;
  }

  Future<void> refreshProfile() async => loadProfile();
}
