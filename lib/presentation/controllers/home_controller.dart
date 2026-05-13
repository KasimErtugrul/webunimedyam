import 'package:get/get.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/playlist_model.dart';
import '../../data/models/university_model.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import 'favorites_controller.dart';

class HomeController extends GetxController {
  final VideoRepository videoRepository;
  final FavoritesRepository favoritesRepository;

  HomeController({
    required this.videoRepository,
    required this.favoritesRepository,
  });

  // ─── State ────────────────────────────────────────────────────────────────

  final videos = <VideoModel>[].obs;
  final playlists = <PlaylistModel>[].obs;
  final favoriteIds = <String>[].obs;
  final universities = <UniversityModel>[].obs;

  final isLoading = false.obs;
  final isPlaylistsLoading = false.obs;
  final isUniversitiesLoading = false.obs;

  final errorMessage = ''.obs;
  final playlistsError = ''.obs;

  /// 0 = Videolar, 1 = Oynatma Listeleri
  final selectedTab = 0.obs;

  /// Alt navigasyon barı seçili sekme
  final selectedIndex = 0.obs;

  /// Seçili üniversite — null ise "Tümü" gösterilir
  final selectedUniversity = Rxn<UniversityModel>();

  final _supabase = SupabaseDataSource();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onReady() {
    super.onReady();
    loadUniversities();
    loadVideos();
    loadPlaylists();
    loadFavorites();
  }

  // ─── Üniversiteler ────────────────────────────────────────────────────────

  Future<void> loadUniversities() async {
    try {
      isUniversitiesLoading.value = true;
      universities.value = await videoRepository.getUniversities();
    } catch (e) {
      print('loadUniversities error: $e');
    } finally {
      isUniversitiesLoading.value = false;
    }
  }

  /// Üniversite seçildiğinde çağrılır. null = "Tümü"
  Future<void> selectUniversity(UniversityModel? university) async {
    selectedUniversity.value = university;
    await loadVideos();
  }

  // ─── Videolar ─────────────────────────────────────────────────────────────

  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uni = selectedUniversity.value;
      if (uni != null) {
        // Belirli üniversitenin tüm videoları
        videos.value =
            await videoRepository.getVideosByUniversity(uni.id);
      } else {
        // Her üniversiteden son video (ana sayfa özet görünümü)
        videos.value =
            await videoRepository.getLatestVideosPerUniversity();
      }
    } catch (e) {
      errorMessage.value = 'Videolar yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshVideos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      // Refresh her zaman tüm cache'i tazeler (YouTube API)
      await videoRepository.refreshVideos();
      // Sonra mevcut filtreyle yeniden yükle
      await loadVideos();
    } catch (e) {
      errorMessage.value = 'Videolar yenilenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Oynatma Listeleri ────────────────────────────────────────────────────

  Future<void> loadPlaylists() async {
    try {
      isPlaylistsLoading.value = true;
      playlistsError.value = '';
      playlists.value = await videoRepository.getPlaylists();
    } catch (e) {
      playlistsError.value = 'Oynatma listeleri yüklenemedi.';
    } finally {
      isPlaylistsLoading.value = false;
    }
  }

  // ─── Favoriler ────────────────────────────────────────────────────────────

  Future<void> loadFavorites() async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return;
      favoriteIds.value =
          await favoritesRepository.getFavoriteVideoIds(userId);
    } catch (e) {
      print('loadFavorites error: $e');
    }
  }

  bool isFavorite(String videoId) => favoriteIds.contains(videoId);

  Future<void> toggleFavorite(String videoId) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) {
      Get.toNamed('/login');
      return;
    }

    try {
      if (isFavorite(videoId)) {
        await favoritesRepository.removeFavorite(userId, videoId);
        favoriteIds.remove(videoId);
      } else {
        await favoritesRepository.addFavorite(userId, videoId);
        favoriteIds.add(videoId);
      }
      if (Get.isRegistered<FavoritesController>()) {
        Get.find<FavoritesController>().loadFavorites();
      }
    } catch (e) {
      print('toggleFavorite error: $e');
    }
  }

  // ─── Navigasyon ──────────────────────────────────────────────────────────

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  // ─── Yardımcılar ─────────────────────────────────────────────────────────

  /// AppBar'da gösterilecek başlık
  String get appBarTitle {
    final uni = selectedUniversity.value;
    if (uni == null) return 'ÜniTV';
    // Uzun adları kısalt
    final name = uni.name;
    if (name.length > 20) {
      return '${name.substring(0, 18)}…';
    }
    return name;
  }
}