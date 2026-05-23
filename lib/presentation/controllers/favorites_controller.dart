import 'dart:developer';

import 'package:get/get.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/models/video_model.dart';

class FavoritesController extends GetxController {
  final FavoritesRepository favoritesRepository;

  FavoritesController({required this.favoritesRepository});

  final favoriteVideos = <VideoModel>[].obs;
  final isLoading = false.obs;

  // FIX: ProfileController bağımlılığı tamamen kaldırıldı! 
  // Controller'lar birbirinin beynine girmemeli. Her biri kendi verisini Repo'dan çeker.

  @override
  void onReady() {
    super.onReady();
    loadFavorites();
  }

  /// Local storage'dan favorileri yükler — ağ bağlantısı gerekmez.
  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      favoriteVideos.value = await favoritesRepository.getFavoriteVideos();
    } catch (e) {
      log('loadFavorites error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// PlayerController/HomeController'dan çağrılır — video favorilenince local'e ekler.
  /// SADECE KENDİ STATE'İNİ GÜNCELLER.
  Future<void> addFavoriteVideo(VideoModel video) async {
    try {
      if (favoriteVideos.any((v) => v.videoId == video.videoId)) return;
      await favoritesRepository.saveFavoriteVideoLocally(video);
      favoriteVideos.insert(0, video); // Sadece kendi listesi
    } catch (e) {
      log('addFavoriteVideo error: $e');
    }
  }

  /// Favori kaldırılınca local'den siler.
  /// SADECE KENDİ STATE'İNİ GÜNCELLER.
  Future<void> removeFavoriteVideo(String videoId) async {
    try {
      await favoritesRepository.removeFavoriteVideoLocally(videoId);
      favoriteVideos.removeWhere((v) => v.videoId == videoId);
    } catch (e) {
      log('removeFavoriteVideo error: $e');
    }
  }
  
  // NOT: Eski removeFavorite metodu silindi çünkü removeFavoriteVideo ile tamamen aynı işi yapıyordu.
  // Eğer UI tarafında somewhere removeFavorite çağırıyorsan, onu removeFavoriteVideo olarak değiştirmelisin.
}