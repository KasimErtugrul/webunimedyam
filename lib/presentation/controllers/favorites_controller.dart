import 'package:get/get.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/datasources/remote/supabase_datasource.dart';

class FavoritesController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final VideoRepository videoRepository;

  FavoritesController({
    required this.favoritesRepository,
    required this.videoRepository,
  });

  final favoriteVideos = <VideoModel>[].obs;
  final isLoading = false.obs;
  final _supabase = SupabaseDataSource();

  @override
  void onReady() {
    super.onReady();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;

    try {
      isLoading.value = true;
      final ids = await favoritesRepository.getFavoriteVideoIds(userId);
      final allVideos = await videoRepository.getVideos();
      favoriteVideos.value =
          allVideos.where((v) => ids.contains(v.videoId)).toList();
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFavorite(String videoId) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;

    try {
      await favoritesRepository.removeFavorite(userId, videoId);
      favoriteVideos.removeWhere((v) => v.videoId == videoId);
    } catch (_) {}
  }

  /// Player ekranından favori eklenince listeyi anında günceller.
  void addFavoriteVideo(VideoModel video) {
    if (!favoriteVideos.any((v) => v.videoId == video.videoId)) {
      favoriteVideos.add(video);
    }
  }

  /// Player ekranından favori kaldırılınca listeyi anında günceller.
  void removeFavoriteVideo(String videoId) {
    favoriteVideos.removeWhere((v) => v.videoId == videoId);
  }
}