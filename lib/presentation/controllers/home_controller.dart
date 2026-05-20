import 'dart:developer';

import 'package:flutter/material.dart';
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
  // DÜZELTME #1: new SupabaseDataSource() yerine DI üzerinden alınan singleton
  final SupabaseDataSource supabaseDataSource;

  HomeController({
    required this.videoRepository,
    required this.favoritesRepository,
    required this.supabaseDataSource,
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
  /// 0=Ana Sayfa, 1=Üniversiteler, 2=Favoriler
  final selectedIndex = 0.obs;

  /// Seçili üniversite — null ise "Tümü" gösterilir
  final selectedUniversity = Rxn<UniversityModel>();

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
      log('loadUniversities error: $e');
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
        videos.value =
            await videoRepository.getVideosByUniversity(uni.id);
      } else {
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
      await videoRepository.refreshVideos();
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
      final userId = supabaseDataSource.currentUser?.id;
      if (userId == null) return;
      favoriteIds.value =
          await favoritesRepository.getFavoriteVideoIds(userId);
    } catch (e) {
      log('loadFavorites error: $e');
    }
  }

  bool isFavorite(String videoId) => favoriteIds.contains(videoId);

  Future<void> toggleFavorite(String videoId) async {
    final userId = supabaseDataSource.currentUser?.id;
    if (userId == null) {
      // DÜZELTME #3: Auth dialog tek merkezden (_showAuthDialog yöntemi)
      _showAuthDialog();
      return;
    }

    try {
      if (isFavorite(videoId)) {
        await favoritesRepository.removeFavorite(userId, videoId);
        await favoritesRepository.removeFavoriteVideoLocally(videoId);
        favoriteIds.remove(videoId);
        if (Get.isRegistered<FavoritesController>()) {
          Get.find<FavoritesController>().favoriteVideos
              .removeWhere((v) => v.videoId == videoId);
        }
      } else {
        await favoritesRepository.addFavorite(userId, videoId);
        final video = videos.firstWhereOrNull((v) => v.videoId == videoId);
        if (video != null) {
          await favoritesRepository.saveFavoriteVideoLocally(video);
          if (Get.isRegistered<FavoritesController>()) {
            Get.find<FavoritesController>().favoriteVideos.insert(0, video);
          }
        }
        favoriteIds.add(videoId);
      }
    } catch (e) {
      log('toggleFavorite error: $e');
    }
  }

  // ─── Auth Dialog — tek merkezi tanım ─────────────────────────────────────

  void _showAuthDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Giriş Gerekiyor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu özelliği kullanmak için giriş yapmanız gerekiyor.',
          style: TextStyle(color: Color(0xFF9E9EB8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Vazgeç', style: TextStyle(color: Color(0xFF9E9EB8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              Get.toNamed('/login');
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  // ─── Navigasyon ──────────────────────────────────────────────────────────

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  // ─── Yardımcılar ─────────────────────────────────────────────────────────

  String get appBarTitle {
    final uni = selectedUniversity.value;
    if (uni == null) return 'ÜniTV';
    final name = uni.name;
    if (name.length > 20) {
      return '${name.substring(0, 18)}…';
    }
    return name;
  }
}
