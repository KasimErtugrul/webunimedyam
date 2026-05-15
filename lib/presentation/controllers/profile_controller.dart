import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/user_settings_model.dart';
import '../../data/models/video_model.dart';
import 'home_controller.dart';

class ProfileController extends GetxController {
  final AuthRepository authRepository;
  final _supabase = SupabaseDataSource();

  ProfileController({required this.authRepository});

  // ─── Profil & Ayarlar ─────────────────────────────────────────────────────
  final profile = Rxn<ProfileModel>();
  final settings = Rxn<UserSettingsModel>();
  final isLoading = false.obs;

  // ─── Aktivite Listeleri ───────────────────────────────────────────────────
  final favoriteVideos   = <VideoModel>[].obs;
  final viewedVideos     = <VideoModel>[].obs;
  final commentedVideos  = <VideoModel>[].obs;
  final sharedVideos     = <VideoModel>[].obs;

  // Her sekme için ayrı loading state — sadece ilgili sekme spinner gösterir
  final isFavoritesLoading   = false.obs;
  final isViewedLoading      = false.obs;
  final isCommentedLoading   = false.obs;
  final isSharedLoading      = false.obs;

  // Seçili sekme (TabBar index)
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

    // Profil yüklendikten sonra aktiviteleri paralel çek
    if (isLoggedIn) _loadAllActivities();
  }

  Future<void> _loadAllActivities() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;

    await Future.wait([
      loadFavorites(userId),
      loadViewedVideos(userId),
      loadCommentedVideos(userId),
      loadSharedVideos(userId),
    ]);
  }

  Future<void> loadFavorites([String? uid]) async {
    final userId = uid ?? _supabase.currentUser?.id;
    if (userId == null) return;
    try {
      isFavoritesLoading.value = true;
      favoriteVideos.value = await _supabase.getUserFavoriteVideos(userId);
    } catch (e) {
      log('loadFavorites error: $e');
    } finally {
      isFavoritesLoading.value = false;
    }
  }

  Future<void> loadViewedVideos([String? uid]) async {
    final userId = uid ?? _supabase.currentUser?.id;
    if (userId == null) return;
    try {
      isViewedLoading.value = true;
      viewedVideos.value = await _supabase.getUserViewedVideos(userId);
    } catch (e) {
      log('loadViewedVideos error: $e');
    } finally {
      isViewedLoading.value = false;
    }
  }

  Future<void> loadCommentedVideos([String? uid]) async {
    final userId = uid ?? _supabase.currentUser?.id;
    if (userId == null) return;
    try {
      isCommentedLoading.value = true;
      commentedVideos.value = await _supabase.getUserCommentedVideos(userId);
    } catch (e) {
      log('loadCommentedVideos error: $e');
    } finally {
      isCommentedLoading.value = false;
    }
  }

  Future<void> loadSharedVideos([String? uid]) async {
    final userId = uid ?? _supabase.currentUser?.id;
    if (userId == null) return;
    try {
      isSharedLoading.value = true;
      sharedVideos.value = await _supabase.getUserSharedVideos(userId);
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
      final updated = ProfileModel(
        id: current.id,
        username: username ?? current.username,
        fullName: fullName ?? current.fullName,
        avatarUrl: avatarUrl ?? current.avatarUrl,
        createdAt: current.createdAt,
      );
      await authRepository.updateProfile(updated);
      profile.value = updated;
      Get.snackbar('Başarılı', 'Profil güncellendi.');
    } catch (_) {
      Get.snackbar('Hata', 'Profil güncellenemedi.');
    }
  }

  // ─── Yardımcılar ──────────────────────────────────────────────────────────

  void changeTab(int index) {
    Get.find<HomeController>().changeTab(index);
  }

  bool get isLoggedIn => authRepository.isLoggedIn;
}