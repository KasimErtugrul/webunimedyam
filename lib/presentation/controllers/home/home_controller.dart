import 'package:get/get.dart';

import '../../../data/models/playlist_model.dart';
import '../../../data/models/university_model.dart';
import '../../../data/models/university_stats_model.dart';
import '../../../data/models/video_engagement_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/models/watch_progress_model.dart';
import '../../../data/repositories/auth_repository.dart';
import 'discovery_controller.dart';
import 'engagement_controller.dart';
import 'feed_controller.dart';
import '../settings_controller.dart';
import 'universities_controller.dart';

/// Public facade. Ekranlar bu API'yi kullanmaya devam eder; asıl iş
/// [FeedController], [EngagementController], [UniversitiesController],
/// [DiscoveryController] içindedir.
class HomeController extends GetxController {
  HomeController({required this.authRepository});

  final AuthRepository authRepository;

  FeedController get feed => Get.find<FeedController>();
  EngagementController get engagement => Get.find<EngagementController>();
  UniversitiesController get universitiesCtrl => Get.find<UniversitiesController>();
  DiscoveryController get discovery => Get.find<DiscoveryController>();

  // ─── Tab / Navigation ───────────────────────────────────────────────────
  final selectedTab = 0.obs;
  final selectedIndex = 0.obs;
  final homeTabResetSignal = 0.obs;

  void changeTab(int index) {
    if (index == 0) {
      final alreadyOnHome = selectedIndex.value == 0;
      selectedIndex.value = 0;
      if (alreadyOnHome) {
        homeTabResetSignal.value++;
      }
      return;
    }
    selectedIndex.value = index;
    if (index == 1) {
      discovery.ensureLoaded();
    }
  }

  String get appBarTitle {
    final uni = feed.selectedUniversity.value;
    if (uni == null) return 'ÜniTV';
    final name = uni.name ?? 'ÜniTV';
    if (name.length > 20) return '${name.substring(0, 18)}…';
    return name;
  }

  // ─── Home layout (wheel/list) ───────────────────────────────────────────
  final isWheelView = false.obs;
  Worker? _homeLayoutWorker;

  void toggleWheelView() {
    final newLayout = isWheelView.value ? 'list' : 'wheel';
    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().changeHomeLayout(newLayout);
    } else {
      isWheelView.value = !isWheelView.value;
      authRepository.saveHomeLayoutLocally(newLayout);
    }
  }

  Future<void> _initHomeLayout() async {
    if (Get.isRegistered<SettingsController>()) {
      final settingsCtrl = Get.find<SettingsController>();
      isWheelView.value = settingsCtrl.homeLayout.value == 'wheel';
      _homeLayoutWorker =
          ever<String>(settingsCtrl.homeLayout, (layout) {
        isWheelView.value = layout == 'wheel';
      });
    } else {
      final layout = await authRepository.getHomeLayout();
      isWheelView.value = layout == 'wheel';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initHomeLayout();
  }

  @override
  void onReady() {
    super.onReady();
    // Alt controller'ları uyandır ve ilk yüklemeleri başlat.
    feed;
    engagement;
    universitiesCtrl;
    // Discovery Lazy: sadece Keşfet sekmesi ilk kez açıldığında.

    universitiesCtrl.loadUniversitiesAndPlaylists();
    feed.loadVideos().then((_) => engagement.loadLikedVideoIds());
    engagement.loadFavorites();
    feed.loadContinueWatching();
  }

  @override
  void onClose() {
    _homeLayoutWorker?.dispose();
    super.onClose();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // FACADE — Eski HomeController API'si (ekranlar değişmeden çalışır)
  // ═════════════════════════════════════════════════════════════════════════

  bool get isLoggedIn => authRepository.isLoggedIn;

  // ─── Feed ────────────────────────────────────────────────────────────────
  RxList<VideoModel> get videos => feed.videos;
  RxInt get currentPage => feed.currentPage;
  RxBool get hasMoreVideos => feed.hasMoreVideos;
  RxBool get isLoadingMore => feed.isLoadingMore;
  RxBool get isLoading => feed.isLoading;
  RxString get errorMessage => feed.errorMessage;
  Rxn<UniversityModel> get selectedUniversity => feed.selectedUniversity;
  RxMap<String, int> get viewCountOverrides => feed.viewCountOverrides;

  Future<void> loadVideos() => feed.loadVideos();
  Future<void> loadMoreVideos() => feed.loadMoreVideos();
  Future<void> refreshVideos() => feed.refreshVideos();
  Future<void> selectUniversity(UniversityModel? u) => feed.selectUniversity(u);
  void syncViewCountFromPlayer(String id, int c) =>
      feed.syncViewCountFromPlayer(id, c);

  // ─── Continue watching ───────────────────────────────────────────────────
  RxList<WatchProgressModel> get continueWatching => feed.continueWatching;
  RxBool get isContinueWatchingLoading => feed.isContinueWatchingLoading;
  Future<void> loadContinueWatching() => feed.loadContinueWatching();
  Future<void> removeFromContinueWatching(String id) =>
      feed.removeFromContinueWatching(id);

  // ─── Engagement ──────────────────────────────────────────────────────────
  RxList<String> get favoriteIds => engagement.favoriteIds;
  RxList<String> get likedVideoIds => engagement.likedVideoIds;
  RxList<String> get likeLoadingVideoIds => engagement.likeLoadingVideoIds;
  RxList<String> get shareLoadingVideoIds => engagement.shareLoadingVideoIds;
  RxList<String> get sharedVideoIds => engagement.sharedVideoIds;
  RxList<String> get commentedVideoIds => engagement.commentedVideoIds;
  RxMap<String, int> get quickCommentBumps => engagement.quickCommentBumps;
  RxSet<String> get quickCommentSendingIds => engagement.quickCommentSendingIds;
  RxBool get showAuthRequired => engagement.showAuthRequired;
  int get likedIdsCount => engagement.likedIdsCount;
  int extraCommentCountFor(String id) => engagement.extraCommentCountFor(id);

  bool isFavorite(String id) => engagement.isFavorite(id);
  bool isLiked(String id) => engagement.isLiked(id);
  bool isLikeLoading(String id) => engagement.isLikeLoading(id);
  bool isShareLoading(String id) => engagement.isShareLoading(id);

  Future<void> loadFavorites() => engagement.loadFavorites();
  Future<void> loadLikedVideoIds() => engagement.loadLikedVideoIds();
  Future<void> loadSharedVideoIds() => engagement.loadSharedVideoIds();
  Future<void> loadCommentedVideoIds() => engagement.loadCommentedVideoIds();
  Future<void> toggleFavorite(String id) => engagement.toggleFavorite(id);
  Future<void> toggleLike(String id) => engagement.toggleLike(id);
  Future<void> shareVideo(VideoModel v) => engagement.shareVideo(v);
  Future<bool> sendQuickComment(VideoModel v, String c) =>
      engagement.sendQuickComment(v, c);

  void syncLikeFromPlayer(String id, bool liked) =>
      engagement.syncLikeFromPlayer(id, liked);
  void syncFavoriteFromPlayer(String id, bool fav) =>
      engagement.syncFavoriteFromPlayer(id, fav);
  void syncShareCountFromPlayer(String id, int delta) =>
      engagement.syncShareCountFromPlayer(id, delta);
  void syncCommentCountFromPlayer(String id, int delta) =>
      engagement.syncCommentCountFromPlayer(id, delta);

  // ─── Universities ────────────────────────────────────────────────────────
  RxList<UniversityModel> get universities => universitiesCtrl.universities;
  RxList<PlaylistModel> get playlists => universitiesCtrl.playlists;
  RxSet<int> get favoriteUniversityIds => universitiesCtrl.favoriteUniversityIds;
  RxBool get isUniversitiesLoading => universitiesCtrl.isUniversitiesLoading;
  RxBool get isPlaylistsLoading => universitiesCtrl.isPlaylistsLoading;
  RxString get playlistsError => universitiesCtrl.playlistsError;

  Future<void> loadUniversitiesAndPlaylists() =>
      universitiesCtrl.loadUniversitiesAndPlaylists();
  Future<void> loadPlaylists() => universitiesCtrl.loadPlaylists();
  bool isUniversityFavorite(int id) =>
      universitiesCtrl.isUniversityFavorite(id);
  Future<void> toggleUniversityFavorite(UniversityModel u) =>
      universitiesCtrl.toggleUniversityFavorite(u);

  // ─── Discovery ───────────────────────────────────────────────────────────
  RxList<UniversityStatsModel> get statsMostWatched =>
      discovery.statsMostWatched;
  RxList<UniversityStatsModel> get statsMostLiked => discovery.statsMostLiked;
  RxList<UniversityStatsModel> get statsPopularInApp =>
      discovery.statsPopularInApp;
  RxList<UniversityStatsModel> get statsMostFavorited =>
      discovery.statsMostFavorited;
  RxList<UniversityStatsModel> get statsActiveLast30 =>
      discovery.statsActiveLast30;
  RxList<UniversityStatsModel> get statsBiggestChannels =>
      discovery.statsBiggestChannels;
  RxList<UniversityStatsModel> get statsRichestArchive =>
      discovery.statsRichestArchive;
  RxList<UniversityStatsModel> get statsNewlyDiscovered =>
      discovery.statsNewlyDiscovered;
  RxBool get isStatsLoading => discovery.isStatsLoading;

  RxList<VideoEngagementModel> get videosTrending => discovery.videosTrending;
  RxList<VideoEngagementModel> get videosMostWatched =>
      discovery.videosMostWatched;
  RxList<VideoEngagementModel> get videosMostLiked => discovery.videosMostLiked;
  RxList<VideoEngagementModel> get videosMostFavorited =>
      discovery.videosMostFavorited;
  RxList<VideoEngagementModel> get videosMostCommented =>
      discovery.videosMostCommented;
  RxList<VideoEngagementModel> get videosNewUndiscovered =>
      discovery.videosNewUndiscovered;
  RxBool get isVideoSectionsLoading => discovery.isVideoSectionsLoading;

  Future<void> loadUniversityStats() => discovery.loadUniversityStats();
  Future<void> loadVideoSections() => discovery.loadVideoSections();
}