import 'dart:developer';

import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/favorites_repository.dart'; // YENİ EKLENDİ
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/user_settings_model.dart';
import '../../data/models/video_model.dart';

class ProfileController extends GetxController {
  final AuthRepository authRepository;
  final SupabaseDataSource supabaseDataSource;
  final FavoritesRepository favoritesRepository; // YENİ EKLENDİ

  ProfileController({
    required this.authRepository,
    required this.supabaseDataSource,
    required this.favoritesRepository, // YENİ EKLENDİ
  });

  // ─── Profil & Ayarlar ─────────────────────────────────────────────────────
  final profile = Rxn<ProfileModel>();
  final settings = Rxn<UserSettingsModel>();
  final isLoading = false.obs;

  // ─── Aktivite Listeleri ───────────────────────────────────────────────────
  final favoriteVideos   = <VideoModel>[].obs;
  final viewedVideos     = <VideoModel>[].obs;
  final commentedVideos  = <VideoModel>[].obs;
  final sharedVideos     = <VideoModel>[].obs;

  final isFavoritesLoading   = false.obs;
  final isViewedLoading      = false.obs;
  final isCommentedLoading   = false.obs;
  final isSharedLoading      = false.obs;

  // ─── UI Mesajları (snackbar yerine observable) ────────────────────────────
  final successMessage = RxnString();
  final errorMessage   = RxnString();

  final selectedTabIndex = 0.obs;

  @override
  void onReady() {
    super.onReady();
    loadProfile();
  }

  // ─── Profil ───────────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      profile.value = await authRepository.getProfile();
      settings.value = await authRepository.getUserSettings();
    } catch (e) {
      log('loadProfile error: $e');
    } finally {
      isLoading.value = false;
    }

    if (isLoggedIn) _loadAllActivities();
  }

  Future<void> _loadAllActivities() async {
    final userId = supabaseDataSource.currentUser?.id;
    if (userId == null) return;

    await Future.wait([
      loadFavorites(userId),
      loadViewedVideos(userId),
      loadCommentedVideos(userId),
      loadSharedVideos(userId),
    ]);
  }

  // FIX: Busy-wait (Future.doWhile) KALDIRILDI!
  // FavoritesController'a bağımlılık koptu. Artık veriyi doğrudan FavoritesRepository'den
  // alıyoruz (Local Cache). Bu en hızlı ve en güvenli yoldur.
  Future<void> loadFavorites([String? uid]) async {
    try {
      isFavoritesLoading.value = true;
      final userId = uid ?? supabaseDataSource.currentUser?.id;
      if (userId == null) return;
      
      // Artık Repository karar veriyor: Local boşsa Supabase'e gider!
      favoriteVideos.value = await favoritesRepository.getUserFavoriteVideos(userId);
    } catch (e) {
      log('loadFavorites error: $e');
    } finally {
      isFavoritesLoading.value = false;
    }
  }

  // FIX: supabaseDataSource çağrıları try-catch'e alındı. Offline ise app çökmez.
  Future<void> loadViewedVideos([String? uid]) async {
    final userId = uid ?? supabaseDataSource.currentUser?.id;
    if (userId == null) return;
    try {
      isViewedLoading.value = true;
      viewedVideos.value = await supabaseDataSource.getUserViewedVideos(userId);
    } catch (e) {
      log('loadViewedVideos error: $e');
      viewedVideos.clear(); // Hata olursa boş liste tut
    } finally {
      isViewedLoading.value = false;
    }
  }

  Future<void> loadCommentedVideos([String? uid]) async {
    final userId = uid ?? supabaseDataSource.currentUser?.id;
    if (userId == null) return;
    try {
      isCommentedLoading.value = true;
      commentedVideos.value = await supabaseDataSource.getUserCommentedVideos(userId);
    } catch (e) {
      log('loadCommentedVideos error: $e');
      commentedVideos.clear();
    } finally {
      isCommentedLoading.value = false;
    }
  }

  Future<void> loadSharedVideos([String? uid]) async {
    final userId = uid ?? supabaseDataSource.currentUser?.id;
    if (userId == null) return;
    try {
      isSharedLoading.value = true;
      sharedVideos.value = await supabaseDataSource.getUserSharedVideos(userId);
    } catch (e) {
      log('loadSharedVideos error: $e');
      sharedVideos.clear();
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
      final updated = ProfileModel(
        id: current.id,
        username: username ?? current.username,
        fullName: fullName ?? current.fullName,
        avatarUrl: avatarUrl ?? current.avatarUrl,
        createdAt: current.createdAt,
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

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  bool get isLoggedIn => authRepository.isLoggedIn;
}