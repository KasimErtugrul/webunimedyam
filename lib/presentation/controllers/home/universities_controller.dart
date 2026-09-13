import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';

import '../../../data/models/playlist_model.dart';
import '../../../data/models/university_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/university_favorites_repository.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../services/analytics_service.dart';
import 'engagement_controller.dart';

/// Üniversiteler + playlistler + üniversite favorileri.
class UniversitiesController extends GetxController {
  UniversitiesController({
    required this.videoRepository,
    required this.universityFavoritesRepository,
    required this.authRepository,
  });

  final VideoRepository videoRepository;
  final UniversityFavoritesRepository universityFavoritesRepository;
  final AuthRepository authRepository;

  final universities = <UniversityModel>[].obs;
  final playlists = <PlaylistModel>[].obs;
  final favoriteUniversityIds = <int>{}.obs;

  final isUniversitiesLoading = false.obs;
  final isPlaylistsLoading = false.obs;
  final playlistsError = ''.obs;

  late final StreamSubscription<UniversityFavoriteChange> _uniFavSub;

  String? get _currentUserId => authRepository.currentUserId;

  @override
  void onInit() {
    super.onInit();
    _uniFavSub =
        universityFavoritesRepository.onFavoriteChanged.listen((event) {
      if (event.isFavorite) {
        favoriteUniversityIds.add(event.universityId);
      } else {
        favoriteUniversityIds.remove(event.universityId);
      }
    });
  }

  @override
  void onClose() {
    _uniFavSub.cancel();
    super.onClose();
  }

  Future<void> loadUniversitiesAndPlaylists() async {
    try {
      isUniversitiesLoading.value = true;
      isPlaylistsLoading.value = true;
      playlistsError.value = '';
      final rows = await videoRepository.getUniversitiesAndPlaylists();
      universities.value =
          rows.map((r) => UniversityModel.fromSupabase(r)).toList();
      playlists.value = rows
          .map((r) => PlaylistModel.fromUniversity(
                r,
                videoCount: (r['video_count'] as int?) ?? 0,
                thumbnailUrl: r['thumbnail_url'] as String? ?? '',
              ))
          .toList();
      await _loadFavoriteUniversityIds();
    } catch (e, st) {
      log('Üniversiteler ve oynatma listeleri yüklenirken hata oluştu: $e',
          error: e, stackTrace: st);
      playlistsError.value = 'Üniversiteler yüklenemedi.';
    } finally {
      isUniversitiesLoading.value = false;
      isPlaylistsLoading.value = false;
    }
  }

  Future<void> loadPlaylists() => loadUniversitiesAndPlaylists();

  Future<void> _loadFavoriteUniversityIds() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;
      final ids =
          await universityFavoritesRepository.getFavoriteUniversityIds(userId);
      favoriteUniversityIds.assignAll(ids.toSet());
    } catch (e, st) {
      log('Favori üniversite ID\'leri yüklenirken hata oluştu: $e',
          error: e, stackTrace: st);
    }
  }

  bool isUniversityFavorite(int universityId) =>
      favoriteUniversityIds.contains(universityId);

  Future<void> toggleUniversityFavorite(UniversityModel university) async {
    final userId = _currentUserId;

    if (userId == null) {
      if (Get.isRegistered<EngagementController>()) {
        Get.find<EngagementController>().showAuthRequired.value = true;
      }
      AnalyticsService.instance.logEvent('auth_wall_hit',
          parameters: {
            'action': 'university_favorite',
            'source': 'home_feed',
          });
      return;
    }

    final id = university.id!;
    final wasFav = favoriteUniversityIds.contains(id);
    final bool success;
    if (wasFav) {
      success = await universityFavoritesRepository.removeFavorite(userId, id);
    } else {
      success = await universityFavoritesRepository.addFavorite(userId, id,
          university: university);
    }

    if (success) {
      AnalyticsService.instance.logEvent(
        wasFav ? 'university_unfavorite' : 'university_favorite',
        parameters: {
          'university_id': id,
          'university_name': university.name ?? 'unknown',
          'source': 'home_feed',
        },
      );
    }
  }
}