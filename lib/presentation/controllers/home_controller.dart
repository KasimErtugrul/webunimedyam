import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/university_stats_repository.dart';
import '../../data/repositories/engagement_repository.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import 'profile_controller.dart';
import '../../data/models/video_model.dart';
import '../../data/models/playlist_model.dart';
import '../../data/models/university_model.dart';
import '../../data/models/university_stats_model.dart';
import '../../data/models/video_engagement_model.dart';

class HomeController extends GetxController {
  final VideoRepository videoRepository;
  final FavoritesRepository favoritesRepository;
  final UniversityStatsRepository universityStatsRepository;
  final AuthRepository authRepository;
  final EngagementRepository engagementRepository;
  final UniversityFavoritesRepository universityFavoritesRepository;

  HomeController({
    required this.videoRepository,
    required this.favoritesRepository,
    required this.universityStatsRepository,
    required this.authRepository,
    required this.engagementRepository,
    required this.universityFavoritesRepository,
  });

  // ─── State ─────────────────────────────────────────────────────────────────

  static const _pageSize = 10;
  final currentPage = 0.obs;
  final hasMoreVideos = true.obs;
  final isLoadingMore = false.obs;

  final videos = <VideoModel>[].obs;
  final playlists = <PlaylistModel>[].obs;
  final favoriteIds = <String>[].obs;
  final _sharedIds = <String>[].obs;
  final _commentedIds = <String>[].obs;
  final favoriteUniversityIds = <int>{}.obs;
  final universities = <UniversityModel>[].obs;

  final isLoading = false.obs;
  final isPlaylistsLoading = false.obs;
  final isUniversitiesLoading = false.obs;

  final errorMessage = ''.obs;
  final playlistsError = ''.obs;

  final selectedTab = 0.obs;
  final selectedIndex = 0.obs;
  final selectedUniversity = Rxn<UniversityModel>();

  final statsMostWatched = <UniversityStatsModel>[].obs;
  final statsMostLiked = <UniversityStatsModel>[].obs;
  final statsPopularInApp = <UniversityStatsModel>[].obs;
  final statsMostFavorited = <UniversityStatsModel>[].obs;
  final statsActiveLast30 = <UniversityStatsModel>[].obs;
  final statsBiggestChannels = <UniversityStatsModel>[].obs;
  final statsRichestArchive = <UniversityStatsModel>[].obs;
  final statsNewlyDiscovered = <UniversityStatsModel>[].obs;

  final isStatsLoading = false.obs;

  final videosTrending = <VideoEngagementModel>[].obs;
  final videosMostWatched = <VideoEngagementModel>[].obs;
  final videosMostLiked = <VideoEngagementModel>[].obs;
  final videosMostFavorited = <VideoEngagementModel>[].obs;
  final videosMostCommented = <VideoEngagementModel>[].obs;
  final videosNewUndiscovered = <VideoEngagementModel>[].obs;

  final isVideoSectionsLoading = false.obs;
  final showAuthRequired = false.obs;

  // ─── Like local cache ─────────────────────────────────────────────────────
  final _likeCache = <String, bool>{};
  final _likeCacheLoading = <String>{};
  final _likeProcessing = <String>{};
  final _shareProcessing = <String>{};

  final _likedIds = <String>[].obs;
  final _likeLoadingIds = <String>[].obs;
  final _shareLoadingIds = <String>[].obs;

  // ─── Yardımcılar ─────────────────────────────────────────────────────────

  String? get _currentUserId => authRepository.currentUserId;
  bool get isLoggedIn => authRepository.isLoggedIn;

  late final StreamSubscription<FavoriteChange> _favoriteSubscription;
  late final StreamSubscription<UniversityFavoriteChange> _uniFavSubscription;

  int get likedIdsCount => _likedIds.length;

  // Obx'nin RxList'i dogrudan izleyebilmesi icin public getter'lar
  RxList<String> get likedVideoIds => _likedIds;
  RxList<String> get likeLoadingVideoIds => _likeLoadingIds;
  RxList<String> get shareLoadingVideoIds => _shareLoadingIds;
  RxList<String> get sharedVideoIds => _sharedIds;
  RxList<String> get commentedVideoIds => _commentedIds;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _favoriteSubscription = favoritesRepository.onFavoriteChanged.listen(
      _onFavoriteChanged,
    );
    _uniFavSubscription = universityFavoritesRepository.onFavoriteChanged
        .listen((event) {
          if (event.isFavorite) {
            favoriteUniversityIds.add(event.universityId);
          } else {
            favoriteUniversityIds.remove(event.universityId);
          }
        });

    // Profil sekmesine (index 4) ilk geçişte aktiviteleri yükle
    ever(selectedIndex, (index) {
      if (index != 4) return;
      final supabase = Get.find<SupabaseDataSource>();
      final tag = supabase.currentUser?.id ?? 'anonymous';
      if (!Get.isRegistered<ProfileController>(tag: tag)) return;
      Get.find<ProfileController>(tag: tag).loadAllActivities();
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadUniversitiesAndPlaylists();
    loadVideos().then((_) => loadLikedVideoIds());
    loadFavorites();
    loadUniversityStats();
    loadVideoSections();
  }

  @override
  void onClose() {
    _favoriteSubscription.cancel();
    _uniFavSubscription.cancel();
    super.onClose();
  }

  void _onFavoriteChanged(FavoriteChange event) {
    if (event.isFavorite) {
      if (!favoriteIds.contains(event.videoId)) favoriteIds.add(event.videoId);
    } else {
      favoriteIds.remove(event.videoId);
    }
  }

  // ─── Stats ────────────────────────────────────────────────────────────────

  Future<void> loadUniversityStats() async {
    try {
      isStatsLoading.value = true;
      final bundle = await universityStatsRepository.getAllStats();
      statsMostWatched.value = bundle['most_watched'] ?? [];
      statsMostLiked.value = bundle['most_liked'] ?? [];
      statsPopularInApp.value = bundle['popular_in_app'] ?? [];
      statsMostFavorited.value = bundle['most_favorited'] ?? [];
      statsActiveLast30.value = bundle['most_active_last_30'] ?? [];
      statsBiggestChannels.value = bundle['biggest_channels'] ?? [];
      statsRichestArchive.value = bundle['richest_archive'] ?? [];
      statsNewlyDiscovered.value = bundle['newly_discovered'] ?? [];
    } catch (e) {
      log('loadUniversityStats error: $e');
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> loadVideoSections() async {
    try {
      isVideoSectionsLoading.value = true;
      final bundle = await videoRepository.getAllVideoSections();
      videosTrending.value = bundle['trending'] ?? [];
      videosMostWatched.value = bundle['most_watched'] ?? [];
      videosMostLiked.value = bundle['most_liked'] ?? [];
      videosMostFavorited.value = bundle['most_favorited'] ?? [];
      videosMostCommented.value = bundle['most_commented'] ?? [];
      videosNewUndiscovered.value = bundle['new_undiscovered'] ?? [];
    } catch (e) {
      log('loadVideoSections error: $e');
    } finally {
      isVideoSectionsLoading.value = false;
    }
  }

  Future<void> loadUniversitiesAndPlaylists() async {
    try {
      isUniversitiesLoading.value = true;
      isPlaylistsLoading.value = true;
      playlistsError.value = '';
      final rows = await videoRepository.getUniversitiesAndPlaylists();
      universities.value = rows
          .map((r) => UniversityModel.fromSupabase(r))
          .toList();
      playlists.value = rows
          .map(
            (r) => PlaylistModel.fromUniversity(
              r,
              videoCount: (r['video_count'] as int?) ?? 0,
              thumbnailUrl: r['thumbnail_url'] as String? ?? '',
            ),
          )
          .toList();
      await _loadFavoriteUniversityIds();
    } catch (e) {
      log('loadUniversitiesAndPlaylists error: $e');
      playlistsError.value = 'Üniversiteler yüklenemedi.';
    } finally {
      isUniversitiesLoading.value = false;
      isPlaylistsLoading.value = false;
    }
  }

 Future<void> loadLikedVideoIds() async {
  final userId = _currentUserId;
  if (userId == null) return;
  try {
    final ids = await engagementRepository.getLikedVideoIds(userId);
   log('home controller ids: $ids');
    _likedIds.assignAll(ids); // assignAll hem clear hem addAll yapar ve Obx'i tetikler
    for (final id in ids) {
      _likeCache[id] = true;
    }
    log('❤️ [Home] ${ids.length} beğenilen video yüklendi');
  } catch (e) {
    log('loadLikedVideoIds error: $e');
  }
}

  Future<void> loadSharedVideoIds() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final ids = await engagementRepository.getSharedVideoIds(userId);
      _sharedIds.assignAll(ids);
      log('🔗 [Home] ${ids.length} paylaşılan video yüklendi');
    } catch (e) {
      log('loadSharedVideoIds error: $e');
    }
  }

  Future<void> loadCommentedVideoIds() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final ids = await engagementRepository.getCommentedVideoIds(userId);
      _commentedIds.assignAll(ids);
      log('💬 [Home] ${ids.length} yorumlanan video yüklendi');
    } catch (e) {
      log('loadCommentedVideoIds error: $e');
    }
  }

  Future<void> _loadFavoriteUniversityIds() async {
    final userId = _currentUserId;
    if (userId == null) return;
    final ids = await universityFavoritesRepository.getFavoriteUniversityIds(
      userId,
    );
    favoriteUniversityIds.assignAll(ids.toSet());
  }

  Future<void> selectUniversity(UniversityModel? university) async {
    selectedUniversity.value = university;
    await loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final uni = selectedUniversity.value;

      if (uni != null) {
        videos.value = await videoRepository.getVideosByUniversity(uni.id!);
      } else {
        videos.value = await videoRepository.getLatestVideosPerUniversity(page: 0);
        currentPage.value = 0;
        hasMoreVideos.value = true;
      }
    } catch (e) {
      errorMessage.value = 'Videolar yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreVideos() async {
    if (isLoadingMore.value || !hasMoreVideos.value) return;
    if (selectedUniversity.value != null) return; // şimdilik sadece ana feed
    try {
      isLoadingMore.value = true;
      final nextPage = currentPage.value + 1;
      final newVideos = await videoRepository.getLatestVideosPerUniversity(page: nextPage);
      videos.addAll(newVideos);
      currentPage.value = nextPage;
      hasMoreVideos.value = newVideos.length == _pageSize;
    } catch (e) {
      log('loadMoreVideos error: $e');
    } finally {
      isLoadingMore.value = false;
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

  Future<void> loadPlaylists() => loadUniversitiesAndPlaylists();

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
        await favoritesRepository.removeFavorite(userId, videoId);
        await favoritesRepository.removeFavoriteVideoLocally(videoId);
      } else {
        await favoritesRepository.addFavorite(userId, videoId);
        final video = videos.firstWhereOrNull((v) => v.videoId == videoId);
        if (video != null) {
          await favoritesRepository.saveFavoriteVideoLocally(video);
        }
      }
    } catch (e) {
      log('toggleFavorite error: $e');
    }
  }

  // ─── Üniversite Favori ────────────────────────────────────────────────────

  bool isUniversityFavorite(int universityId) =>
      favoriteUniversityIds.contains(universityId);

  Future<void> toggleUniversityFavorite(UniversityModel university) async {
    final userId = _currentUserId;
    log(
      '🔵 toggleUniversityFavorite called — userId: $userId, uni: ${university.id}',
    );

    if (userId == null) {
      showAuthRequired.value = true;
      log('🔴 userId null, showAuthRequired set');

      return;
    }
    final id = university.id!;
    try {
      if (favoriteUniversityIds.contains(id)) {
        await universityFavoritesRepository.removeFavorite(userId, id);
      } else {
        await universityFavoritesRepository.addFavorite(
          userId,
          id,
          university: university,
        );
      }
    } catch (e) {
      log('toggleUniversityFavorite error: $e');
    }
  }

  // ─── Beğeni — on-demand cache yaklaşımı ──────────────────────────────────

  bool isLiked(String videoId) => _likedIds.contains(videoId);
  bool isLikeLoading(String videoId) => _likeLoadingIds.contains(videoId);
  bool isShareLoading(String videoId) => _shareLoadingIds.contains(videoId);

  Future<void> toggleLike(String videoId) async {
    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;
      return;
    }
    if (_likeProcessing.contains(videoId)) return;
    if (_likeCacheLoading.contains(videoId)) return;

    _likeProcessing.add(videoId);
    _likeLoadingIds.add(videoId);

    try {
      if (!_likeCache.containsKey(videoId)) {
        _likeCacheLoading.add(videoId);
        try {
          _likeCache[videoId] = await engagementRepository.isLiked(
            userId,
            videoId,
          );
        } finally {
          _likeCacheLoading.remove(videoId);
        }
        if (_likeCache[videoId]!) _likedIds.add(videoId);
      }

      final wasLiked = _likeCache[videoId]!;

      _likeCache[videoId] = !wasLiked;
      if (wasLiked) {
        _likedIds.remove(videoId);
      } else {
        _likedIds.add(videoId);
      }

      try {
        if (wasLiked) {
          await engagementRepository.removeLike(userId, videoId);
        } else {
          await engagementRepository.addLike(userId, videoId);
        }
      } catch (e) {
        _likeCache[videoId] = wasLiked;
        if (wasLiked) {
          _likedIds.add(videoId);
        } else {
          _likedIds.remove(videoId);
        }
        log('[HomeController] toggleLike write error: $e');
      }
    } finally {
      _likeLoadingIds.remove(videoId);
      _likeProcessing.remove(videoId);
    }
  }

  // ─── Paylaşım ─────────────────────────────────────────────────────────────

  Future<void> shareVideo(VideoModel video) async {
    if (_shareProcessing.contains(video.videoId)) return;
    _shareProcessing.add(video.videoId);
    _shareLoadingIds.add(video.videoId);

    final videoUrl = 'https://www.youtube.com/watch?v=${video.videoId}';
    final text = '${video.title}\n$videoUrl';

    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: video.title),
      );
      final userId = _currentUserId;
      if (userId != null) {
        await engagementRepository.recordShare(userId, video.videoId);
        if (!_sharedIds.contains(video.videoId)) _sharedIds.add(video.videoId);
      }
    } catch (e) {
      log('[HomeController] shareVideo fallback to clipboard: $e');
      await Clipboard.setData(ClipboardData(text: videoUrl));
      Get.snackbar(
        'Bağlantı Kopyalandı',
        'Video bağlantısı panoya kopyalandı.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _shareLoadingIds.remove(video.videoId);
      _shareProcessing.remove(video.videoId);
    }
  }

  // ─── Navigasyon ──────────────────────────────────────────────────────────

  void changeTab(int index) => selectedIndex.value = index;

  String get appBarTitle {
    final uni = selectedUniversity.value;
    if (uni == null) return 'ÜniTV';
    final name = uni.name ?? 'ÜniTV';
    if (name.length > 20) return '${name.substring(0, 18)}…';
    return name;
  }
}