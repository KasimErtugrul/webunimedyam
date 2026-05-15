import 'dart:developer';

import 'package:get/get.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/models/video_model.dart';
import 'profile_controller.dart';

class FavoritesController extends GetxController {
  final FavoritesRepository favoritesRepository;

  FavoritesController({required this.favoritesRepository});

  final favoriteVideos = <VideoModel>[].obs;
  final isLoading = false.obs;

  /// ProfileController kayıtlıysa referans döner, yoksa null — circular dep yok.
  ProfileController? get _profile =>
      Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : null;

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

  /// Favori kaldır: local senkron + ProfileController anında güncellenir.
  Future<void> removeFavorite(String videoId) async {
    try {
      await favoritesRepository.removeFavoriteVideoLocally(videoId);
      favoriteVideos.removeWhere((v) => v.videoId == videoId);
      _profile?.favoriteVideos.removeWhere((v) => v.videoId == videoId);
    } catch (e) {
      log('removeFavorite error: $e');
    }
  }

  /// PlayerController'dan çağrılır — video favorilenince local'e ekler.
  Future<void> addFavoriteVideo(VideoModel video) async {
    if (favoriteVideos.any((v) => v.videoId == video.videoId)) return;
    await favoritesRepository.saveFavoriteVideoLocally(video);
    favoriteVideos.insert(0, video);
    _profile?.favoriteVideos.insert(0, video);
  }

  /// PlayerController'dan çağrılır — favori kaldırılınca local'den siler.
  Future<void> removeFavoriteVideo(String videoId) async {
    await favoritesRepository.removeFavoriteVideoLocally(videoId);
    favoriteVideos.removeWhere((v) => v.videoId == videoId);
    _profile?.favoriteVideos.removeWhere((v) => v.videoId == videoId);
  }
}