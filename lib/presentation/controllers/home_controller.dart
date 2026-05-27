import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/university_stats_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/playlist_model.dart';
import '../../data/models/university_model.dart';
import '../../data/models/university_stats_model.dart';
import '../../data/models/video_engagement_model.dart';

// FavoritesController IMPORT EDİLMİYOR! Bağımlılık yok.

class HomeController extends GetxController {
  final VideoRepository videoRepository;
  final FavoritesRepository favoritesRepository;
  final UniversityStatsRepository universityStatsRepository;
  final AuthRepository authRepository;

  HomeController({
    required this.videoRepository,
    required this.favoritesRepository,
    required this.universityStatsRepository,
    required this.authRepository,
  });

  // ─── Mevcut State ─────────────────────────────────────────────────────────

  final videos = <VideoModel>[].obs;
  final playlists = <PlaylistModel>[].obs;
  final favoriteIds = <String>[].obs;
  final universities = <UniversityModel>[].obs;

  final isLoading = false.obs;
  final isPlaylistsLoading = false.obs;
  final isUniversitiesLoading = false.obs;

  final errorMessage = ''.obs;
  final playlistsError = ''.obs;

  final selectedTab = 0.obs;
  final selectedIndex = 0.obs;
  final selectedUniversity = Rxn<UniversityModel>();

  // ─── Üniversite Stats State — 8 Liste ────────────────────────────────────

  final statsMostWatched = <UniversityStatsModel>[].obs;
  final statsMostLiked = <UniversityStatsModel>[].obs;
  final statsPopularInApp = <UniversityStatsModel>[].obs;
  final statsMostFavorited = <UniversityStatsModel>[].obs;
  final statsActiveLast30 = <UniversityStatsModel>[].obs;
  final statsBiggestChannels = <UniversityStatsModel>[].obs;
  final statsRichestArchive = <UniversityStatsModel>[].obs;
  final statsNewlyDiscovered = <UniversityStatsModel>[].obs;

  final isStatsLoading = false.obs;

  // ─── Video Seksiyonları State — 6 Liste ──────────────────────────────────

  final videosTrending = <VideoEngagementModel>[].obs;
  final videosMostWatched = <VideoEngagementModel>[].obs;
  final videosMostLiked = <VideoEngagementModel>[].obs;
  final videosMostFavorited = <VideoEngagementModel>[].obs;
  final videosMostCommented = <VideoEngagementModel>[].obs;
  final videosNewUndiscovered = <VideoEngagementModel>[].obs;

  final isVideoSectionsLoading = false.obs;

  // ─── UI Bayrakları ────────────────────────────────────────────────────────
  final showAuthRequired = false.obs;

  // ─── Yardımcılar ─────────────────────────────────────────────────────────

  String? get _currentUserId => authRepository.currentUserId;

  // Stream aboneliği için tutucu
  late final StreamSubscription<FavoriteChange> _favoriteSubscription;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

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
    loadUniversitiesAndPlaylists();
    loadVideos();
    loadFavorites();
    loadUniversityStats();
    loadVideoSections();
  }

  @override
  void onClose() {
    _favoriteSubscription.cancel();
    super.onClose();
  }

  // ─── Favori değişimlerini işle ───────────────────────────────────────────
  void _onFavoriteChanged(FavoriteChange event) {
    if (event.isFavorite) {
      if (!favoriteIds.contains(event.videoId)) {
        favoriteIds.add(event.videoId);
      }
      // Eğer video objesi geldiyse, isteğe bağlı olarak videos listesinde güncelleme yapılabilir
      // (PlayerController'dan gelen event'te video var, HomeController'dan gelen event'te yok)
    } else {
      favoriteIds.remove(event.videoId);
    }
    log('[HomeController] Favori değişikliği algılandı: ${event.videoId} → ${event.isFavorite}');
  }

  // ─── Üniversite Stats Yükleme ─────────────────────────────────────────────

  Future<void> loadUniversityStats() async {
    try {
      isStatsLoading.value = true;
      final results = await Future.wait([
        universityStatsRepository.getMostWatched(),
        universityStatsRepository.getMostLiked(),
        universityStatsRepository.getPopularInApp(),
        universityStatsRepository.getMostFavorited(),
        universityStatsRepository.getMostActiveLast30Days(),
        universityStatsRepository.getBiggestChannels(),
        universityStatsRepository.getRichestArchive(),
        universityStatsRepository.getNewlyDiscovered(),
      ]);
      statsMostWatched.value = results[0];
      statsMostLiked.value = results[1];
      statsPopularInApp.value = results[2];
      statsMostFavorited.value = results[3];
      statsActiveLast30.value = results[4];
      statsBiggestChannels.value = results[5];
      statsRichestArchive.value = results[6];
      statsNewlyDiscovered.value = results[7];
    } catch (e) {
      log('loadUniversityStats error: $e');
    } finally {
      isStatsLoading.value = false;
    }
  }

  // ─── Video Seksiyonları Yükleme ───────────────────────────────────────────

  Future<void> loadVideoSections() async {
    try {
      isVideoSectionsLoading.value = true;
      final results = await Future.wait([
        videoRepository.getTrendingVideos().catchError((e) {
          log('getTrendingVideos error: $e');
          return <VideoEngagementModel>[];
        }),
        videoRepository.getMostWatchedVideos().catchError((e) {
          log('getMostWatchedVideos error: $e');
          return <VideoEngagementModel>[];
        }),
        videoRepository.getMostLikedVideos().catchError((e) {
          log('getMostLikedVideos error: $e');
          return <VideoEngagementModel>[];
        }),
        videoRepository.getMostFavoritedVideos().catchError((e) {
          log('getMostFavoritedVideos error: $e');
          return <VideoEngagementModel>[];
        }),
        videoRepository.getMostCommentedVideos().catchError((e) {
          log('getMostCommentedVideos error: $e');
          return <VideoEngagementModel>[];
        }),
        videoRepository.getNewUndiscoveredVideos().catchError((e) {
          log('getNewUndiscoveredVideos error: $e');
          return <VideoEngagementModel>[];
        }),
      ]);
      videosTrending.value = results[0];
      videosMostWatched.value = results[1];
      videosMostLiked.value = results[2];
      videosMostFavorited.value = results[3];
      videosMostCommented.value = results[4];
      videosNewUndiscovered.value = results[5];
    } catch (e) {
      log('loadVideoSections error: $e');
    } finally {
      isVideoSectionsLoading.value = false;
    }
  }

  // ─── Üniversiteler ────────────────────────────────────────────────────────

  Future<void> loadUniversitiesAndPlaylists() async {
    try {
      isUniversitiesLoading.value = true;
      isPlaylistsLoading.value = true;
      playlistsError.value = '';
      final rows = await videoRepository.getUniversitiesAndPlaylists();
      universities.value = rows.map((r) => UniversityModel.fromSupabase(r)).toList();
      playlists.value = rows
          .map((r) => PlaylistModel.fromUniversity(
                r,
                videoCount: (r['video_count'] as int?) ?? 0,
                thumbnailUrl: r['thumbnail_url'] as String? ?? '',
              ))
          .toList();
    } catch (e) {
      log('loadUniversitiesAndPlaylists error: $e');
      playlistsError.value = 'Üniversiteler yüklenemedi.';
    } finally {
      isUniversitiesLoading.value = false;
      isPlaylistsLoading.value = false;
    }
  }

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
        videos.value = await videoRepository.getVideosByUniversity(uni.id!);
      } else {
        videos.value = await videoRepository.getLatestVideosPerUniversity();
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
      await loadVideoSections();
    } catch (e) {
      errorMessage.value = 'Videolar yenilenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Oynatma Listeleri ────────────────────────────────────────────────────

  Future<void> loadPlaylists() => loadUniversitiesAndPlaylists();

  // ─── Favoriler – DÜZELTİLDI: SADECE KENDİ STATE'İNİ GÜNCELLER, BAŞKA CONTROLLER'LARA DOKUNMAZ ───

  Future<void> loadFavorites() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;
      favoriteIds.value = await favoritesRepository.getFavoriteVideoIds(userId);
    } catch (e) {
      log('loadFavorites error: $e');
    }
  }

  bool isFavorite(String videoId) => favoriteIds.contains(videoId);

  Future<void> toggleFavorite(String videoId) async {
    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;
      return;
    }

    try {
      if (isFavorite(videoId)) {
        // Favoriden çıkar
        await favoritesRepository.removeFavorite(userId, videoId);
        await favoritesRepository.removeFavoriteVideoLocally(videoId);
        // favoriteIds set'i stream event ile güncellenecek ( _onFavoriteChanged )
      } else {
        // Favoriye ekle
        await favoritesRepository.addFavorite(userId, videoId);
        final video = videos.firstWhereOrNull((v) => v.videoId == videoId);
        if (video != null) {
          await favoritesRepository.saveFavoriteVideoLocally(video);
        }
        // favoriteIds set'i stream event ile güncellenecek
      }
      // NOT: FavoritesController'a doğrudan erişim kaldırıldı.
    } catch (e) {
      log('toggleFavorite error: $e');
    }
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
    if (name!.length > 20) return '${name.substring(0, 18)}…';
    return name;
  }
}