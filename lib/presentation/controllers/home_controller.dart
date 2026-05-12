import 'package:get/get.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/playlist_model.dart';
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

  final isLoading = false.obs;
  final isPlaylistsLoading = false.obs;

  final errorMessage = ''.obs;
  final playlistsError = ''.obs;

  /// 0 = Videolar, 1 = Oynatma Listeleri
  final selectedTab = 0.obs;

  /// Alt navigasyon barı seçili sekme
  final selectedIndex = 0.obs;

  final _supabase = SupabaseDataSource();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onReady() {
    super.onReady();
    loadVideos();
    loadPlaylists();
    loadFavorites();
  }

  // ─── Videolar ─────────────────────────────────────────────────────────────

  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      videos.value = await videoRepository.getVideos();
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
      videos.value = await videoRepository.refreshVideos();
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
}
