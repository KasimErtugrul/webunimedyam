import 'dart:developer';
import 'dart:async';
import 'package:get/get.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/models/video_model.dart';

class FavoritesController extends GetxController {
  final FavoritesRepository favoritesRepository;

  FavoritesController({required this.favoritesRepository});

  final favoriteVideos = <VideoModel>[].obs;
  final isLoading = false.obs;

  late final StreamSubscription<FavoriteChange> _favoriteSubscription;

  @override
  void onInit() {
    super.onInit();
    // Favori değişimlerini dinle
    _favoriteSubscription = favoritesRepository.onFavoriteChanged.listen((event) {
      _onFavoriteChanged(event);
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadFavorites();
  }

  @override
  void onClose() {
    _favoriteSubscription.cancel();
    super.onClose();
  }

  void _onFavoriteChanged(FavoriteChange event) {
    if (event.isFavorite) {
      // Ekleme: eğer video nesnesi geldiyse ekle, yoksa cache'den yeniden yükle
      if (event.video != null && !favoriteVideos.any((v) => v.videoId == event.videoId)) {
        favoriteVideos.insert(0, event.video!);
        log('[FavoritesController] Favori eklendi (event): ${event.videoId}');
      } else {
        // Video objesi gelmediyse, tam veri için cache'den yeniden yükle
        loadFavorites();
      }
    } else {
      // Silme
      favoriteVideos.removeWhere((v) => v.videoId == event.videoId);
      log('[FavoritesController] Favori silindi (event): ${event.videoId}');
    }
  }

  /// Local storage'dan favorileri yükler
  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      favoriteVideos.value = await favoritesRepository.getFavoriteVideos();
      log('[FavoritesController] Favoriler yüklendi: ${favoriteVideos.length} video');
    } catch (e) {
      log('loadFavorites error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}