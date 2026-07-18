import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/engagement_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/university_stats_repository.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/watch_progress_repository.dart';
import '../../services/analytics_service.dart';

import '../../data/models/video_model.dart';
import '../../data/models/playlist_model.dart';
import '../../data/models/university_model.dart';
import '../../data/models/university_stats_model.dart';
import '../../data/models/video_engagement_model.dart';
import '../../data/models/watch_progress_model.dart';
import 'settings_controller.dart';

class HomeController extends GetxController {
  final VideoRepository videoRepository;
  final FavoritesRepository favoritesRepository;
  final UniversityStatsRepository universityStatsRepository;
  final AuthRepository authRepository;
  final EngagementRepository engagementRepository;
  final UniversityFavoritesRepository universityFavoritesRepository;
  final CommentRepository commentRepository;
  final WatchProgressRepository watchProgressRepository; // ← YENİ: İzlemeye Devam Et

  HomeController({
    required this.videoRepository,
    required this.favoritesRepository,
    required this.universityStatsRepository,
    required this.authRepository,
    required this.engagementRepository,
    required this.universityFavoritesRepository,
    required this.commentRepository,
    required this.watchProgressRepository, // ← YENİ
  });

  // ─── State ─────────────────────────────────────────────────────────────────

  static const _pageSize = 10;
  final currentPage = 0.obs;
  final hasMoreVideos = true.obs;
  final isLoadingMore = false.obs;

  final videos = <VideoModel>[].obs;

  // BUG FIX: Görüntülenme sayısı için GLOBAL override cache.
  // Önceki kodda syncViewCountFromPlayer() SADECE `videos` listesindeki
  // (HomeController'a ait) video kaydını güncelliyordu. Ama VideoCardWidget
  // başka controller'ların kendi listelerinde de kullanılıyor (örn.
  // university_detail_screen.dart -> UniversityDetailController.videos).
  // O durumda firstWhereOrNull eşleşme bulamıyor, widget statik/eski
  // appViewCount'a düşüyor -> liste ekranına geri dönünce sayaç 0 görünüyor,
  // sadece o ekran kendi verisini yeniden çekince (refresh/pull-to-refresh)
  // düzeliyordu. Beğeni/favori bundan etkilenmiyordu çünkü onların ikon
  // durumu zaten likedVideoIds/favoriteIds gibi global, ID bazlı setlerden
  // okunuyordu. Bu map de aynı global mantığı görüntülenmeye taşıyor.
  final viewCountOverrides = <String, int>{}.obs;

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

  // Ana sayfa besleme (feed) görünüm modu: liste mi, wheel mi?
  // Mevcut listview akışını bozmuyor; sadece aynı `videos` verisini
  // farklı bir arayüzle gösteriyor.
  //
  // Bu değer artık kalıcı: Ayarlar ekranındaki "Ana Sayfa Görünümü"
  // seçeneğiyle aynı kaynağı (SettingsController.homeLayout /
  // AuthRepository — önce yerel, yoksa Supabase) paylaşır, ikisi
  // birbiriyle senkron kalır.
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

  /// Ana sayfa görünümünü kalıcı tercihten yükler (önce yerel, yoksa
  /// Supabase — bkz. AuthRepository.getHomeLayout) ve Ayarlar ekranıyla
  /// aynı anda kalması için SettingsController.homeLayout'u dinlemeye başlar.
  Future<void> _initHomeLayout() async {
    if (Get.isRegistered<SettingsController>()) {
      final settingsCtrl = Get.find<SettingsController>();
      isWheelView.value = settingsCtrl.homeLayout.value == 'wheel';
      _homeLayoutWorker = ever<String>(settingsCtrl.homeLayout, (layout) {
        isWheelView.value = layout == 'wheel';
      });
    } else {
      final layout = await authRepository.getHomeLayout();
      isWheelView.value = layout == 'wheel';
    }
  }

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

  // ─── İzlemeye Devam Et (Continue Watching) — TAMAMEN LOCAL ────────────────
  final continueWatching = <WatchProgressModel>[].obs;
  final isContinueWatchingLoading = false.obs;

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
  late final StreamSubscription<WatchProgressChange> _watchProgressSubscription;

  int get likedIdsCount => _likedIds.length;

  // Obx'nin RxList'i dogrudan izleyebilmesi icin public getter'lar
  RxList<String> get likedVideoIds => _likedIds;
  RxList<String> get likeLoadingVideoIds => _likeLoadingIds;
  RxList<String> get shareLoadingVideoIds => _shareLoadingIds;
  RxList<String> get sharedVideoIds => _sharedIds;
  RxList<String> get commentedVideoIds => _commentedIds;

  // ─── Hızlı Yorum (video'ya girmeden, üç nokta menüsünden) ─────────────────
  // Sunucudan gelen appCommentCount anlık olarak güncellenmediği için,
  // bu oturumda gönderilen hızlı yorumları videoId -> adet şeklinde tutuyoruz.
  final _quickCommentBumps = <String, int>{}.obs;
  final _quickCommentSendingIds = <String>{}.obs;

  RxMap<String, int> get quickCommentBumps => _quickCommentBumps;
  RxSet<String> get quickCommentSendingIds => _quickCommentSendingIds;

  int extraCommentCountFor(String videoId) => _quickCommentBumps[videoId] ?? 0;

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
    // İzlemeye Devam Et: player'da ilerleme kaydedildikçe/silindikçe
    // ana sayfadaki listeyi anında güncelle.
    _watchProgressSubscription = watchProgressRepository.onProgressChanged
        .listen((_) => loadContinueWatching());
    _initHomeLayout();
  }

  @override
  void onReady() {
    super.onReady();
    // FIX: loadUniversityStats() ve loadVideoSections() burada
    // ÇAĞRILMIYOR artık.
    //
    // Bu ikisinin ürettiği veri (statsMostWatched/videosTrending vb.)
    // Ana Sayfa'da DEĞİL, Keşfet sekmesinde (channel_tab_widget.dart /
    // video_tab_widget.dart) gösteriliyor. Önceki kodda HomeController
    // her zaman aynı anda oluşturulduğu (Home ekranı açılır açılmaz
    // Get.find<HomeController>() tetiklendiği) için, kullanıcı Keşfet
    // sekmesine hiç girmese bile bu iki RPC anında ateşleniyordu — tam
    // olarak "henüz girilmemiş sayfaların verisini açılışta çekme"
    // sorunu. Artık bu iki yükleme changeTab() içinde, kullanıcı GERÇEKTEN
    // Keşfet sekmesine ilk kez geçtiğinde tetikleniyor (bkz. changeTab).
    loadUniversitiesAndPlaylists();
    loadVideos().then((_) => loadLikedVideoIds());
    loadFavorites();
    loadContinueWatching();
  }

  @override
  void onClose() {
    _favoriteSubscription.cancel();
    _uniFavSubscription.cancel();
    _watchProgressSubscription.cancel();
    _homeLayoutWorker?.dispose();
    super.onClose();
  }

  void _onFavoriteChanged(FavoriteChange event) {
    final wasFav = favoriteIds.contains(event.videoId);
    // Önce sayacı güncelle, sonra favoriteIds'i — ikisi tutarlı rebuild için
    if (event.isFavorite && !wasFav) {
      _updateVideoFavoriteCount(event.videoId, 1);
      favoriteIds.add(event.videoId);
    } else if (!event.isFavorite && wasFav) {
      _updateVideoFavoriteCount(event.videoId, -1);
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
    } catch (e, stacktrace) {
      log(
        'Üniversite istatistikleri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log(
        'Video bölümleri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    } finally {
      isVideoSectionsLoading.value = false;
    }
  }

  // ─── İzlemeye Devam Et (Continue Watching) — TAMAMEN LOCAL ────────────────

  Future<void> loadContinueWatching() async {
    try {
      isContinueWatchingLoading.value = true;
      continueWatching.value = await watchProgressRepository
          .getContinueWatching();
    } catch (e, stacktrace) {
      log(
        'İzlemeye devam et listesi yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    } finally {
      isContinueWatchingLoading.value = false;
    }
  }

  /// Kullanıcı "İzlemeye Devam Et" kartını kaldırdığında (ör. kaydırarak
  /// veya "Kaldır" butonuyla) çağrılır. Optimistic olarak listeden çıkarır.
  Future<void> removeFromContinueWatching(String videoId) async {
    final removedIndex = continueWatching.indexWhere(
      (w) => w.video.videoId == videoId,
    );
    if (removedIndex == -1) return;
    final removedItem = continueWatching[removedIndex];
    continueWatching.removeAt(removedIndex);
    try {
      await watchProgressRepository.removeProgress(videoId);
    } catch (e, stacktrace) {
      // Hata durumunda geri ekle
      continueWatching.insert(removedIndex, removedItem);
      log(
        'İzlemeye devam et kaydı kaldırılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log(
        'Üniversiteler ve oynatma listeleri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
      _likedIds.assignAll(
        ids,
      ); // assignAll hem clear hem addAll yapar ve Obx'i tetikler
      for (final id in ids) {
        _likeCache[id] = true;
      }
    } catch (e, stacktrace) {
      log(
        'Beğenilen video ID\'leri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> loadSharedVideoIds() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final ids = await engagementRepository.getSharedVideoIds(userId);
      _sharedIds.assignAll(ids);
    } catch (e, stacktrace) {
      log(
        'Paylaşılan video ID\'leri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> loadCommentedVideoIds() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final ids = await engagementRepository.getCommentedVideoIds(userId);
      _commentedIds.assignAll(ids);
    } catch (e, stacktrace) {
      log(
        'Yorum yapılan video ID\'leri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> _loadFavoriteUniversityIds() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;
      final ids = await universityFavoritesRepository.getFavoriteUniversityIds(
        userId,
      );
      favoriteUniversityIds.assignAll(ids.toSet());
    } catch (e, stacktrace) {
      log(
        'Favori üniversite ID\'leri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> selectUniversity(UniversityModel? university) async {
    try {
      selectedUniversity.value = university;
      await loadVideos();
    } catch (e, stacktrace) {
      log(
        'Üniversite seçilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final uni = selectedUniversity.value;

      if (uni != null) {
        videos.value = await videoRepository.getVideosByUniversity(uni.id!);
      } else {
        final firstPage = await videoRepository.getLatestVideosPerUniversity(
          page: 0,
        );
        videos.value = firstPage;
        currentPage.value = 0;
        // Cache/ilk sayfa tam pageSize kadar geldiyse muhtemelen devamı vardır.
        hasMoreVideos.value = firstPage.length >= _pageSize;
      }
    } catch (e, stacktrace) {
      log(
        'Videolar yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
      final newVideos = await videoRepository.getLatestVideosPerUniversity(
        page: nextPage,
      );

      // BUG FIX: Sunucudan/cache'ten aynı videonun tekrar gelmesi ihtimaline
      // karşı (sayfa sınırları çakışırsa) videoId bazlı tekilleştirme yapılır.
      // Bu olmadan liste aynı kartları tekrar tekrar ekleyip "pagination
      // çalışmıyor gibi görünüyor" hissi yaratabiliyordu.
      final existingIds = videos.map((v) => v.videoId).toSet();
      final uniqueNewVideos = newVideos
          .where((v) => existingIds.add(v.videoId))
          .toList();

      videos.addAll(uniqueNewVideos);
      currentPage.value = nextPage;
      hasMoreVideos.value = newVideos.length >= _pageSize;
    } catch (e, stacktrace) {
      log(
        'Daha fazla video yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log(
        'Videolar yenilenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log(
        'Favoriler yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  bool isFavorite(String videoId) => favoriteIds.contains(videoId);

  Future<void> toggleFavorite(String videoId) async {
    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;
      AnalyticsService.instance.logEvent('auth_wall_hit', parameters: {
        'action': 'favorite',
        'source': 'home_feed',
      });
      return;
    }

    final wasFav = isFavorite(videoId);

    // ── Optimistic update: durum ve sayaç anında değişir ──
    if (wasFav) {
      favoriteIds.remove(videoId);
    } else {
      favoriteIds.add(videoId);
    }
    _updateVideoFavoriteCount(videoId, wasFav ? -1 : 1);

    try {
      if (wasFav) {
        await favoritesRepository.removeFavorite(userId, videoId);
        await favoritesRepository.removeFavoriteVideoLocally(videoId);
      } else {
        await favoritesRepository.addFavorite(userId, videoId);
        final video = videos.firstWhereOrNull((v) => v.videoId == videoId);
        if (video != null) {
          await favoritesRepository.saveFavoriteVideoLocally(video);
        }
      }
      AnalyticsService.instance.logEvent(
        wasFav ? 'remove_from_favorites' : 'add_to_favorites',
        parameters: {'video_id': videoId, 'source': 'home_feed'},
      );
    } catch (e, stacktrace) {
      // Rollback
      if (wasFav) {
        favoriteIds.add(videoId);
      } else {
        favoriteIds.remove(videoId);
      }
      _updateVideoFavoriteCount(videoId, wasFav ? 1 : -1);
      log(
        'Favori durumu değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  void _updateVideoFavoriteCount(String videoId, int delta) {
    final idx = videos.indexWhere((v) => v.videoId == videoId);
    if (idx == -1) return;
    videos[idx] = videos[idx].copyWith(
      appFavoriteCount: (videos[idx].appFavoriteCount + delta).clamp(0, 999999999),
    );
  }

  void _updateVideoViewCount(String videoId, int newCount) {
    final idx = videos.indexWhere((v) => v.videoId == videoId);
    if (idx == -1) return;
    if (videos[idx].appViewCount >= newCount) return; // geri gitme
    videos[idx] = videos[idx].copyWith(appViewCount: newCount);
  }

  // BUG FIX: Artık SADECE `videos` listesini değil, global
  // `viewCountOverrides` map'ini de güncelliyor. VideoCardWidget hangi
  // controller'ın listesinden render edilmiş olursa olsun (Home, Üniversite
  // Detay, vs.) bu map'e bakarak en güncel sayıyı gösterebilsin diye.
  void syncViewCountFromPlayer(String videoId, int viewCount) {
    final current = viewCountOverrides[videoId] ?? 0;
    if (viewCount > current) {
      viewCountOverrides[videoId] = viewCount;
    }
    _updateVideoViewCount(videoId, viewCount);
  }

  void _updateVideoShareCount(String videoId, int delta) {
    final idx = videos.indexWhere((v) => v.videoId == videoId);
    if (idx == -1) return;
    videos[idx] = videos[idx].copyWith(
      appShareCount: (videos[idx].appShareCount + delta).clamp(0, 999999999),
    );
  }

  void syncFavoriteFromPlayer(String videoId, bool isNowFav) {
    final wasFav = favoriteIds.contains(videoId);
    if (wasFav == isNowFav) return;
    // Önce sayacı güncelle, sonra favoriteIds'i değiştir.
    // Böylece Obx rebuild olduğunda hem icon hem sayaç tutarlı görünür.
    _updateVideoFavoriteCount(videoId, isNowFav ? 1 : -1);
    if (isNowFav) {
      favoriteIds.add(videoId);
    } else {
      favoriteIds.remove(videoId);
    }
  }

  // ─── Üniversite Favori ────────────────────────────────────────────────────

  bool isUniversityFavorite(int universityId) =>
      favoriteUniversityIds.contains(universityId);

  Future<void> toggleUniversityFavorite(UniversityModel university) async {
    final userId = _currentUserId;

    if (userId == null) {
      showAuthRequired.value = true;
      AnalyticsService.instance.logEvent('auth_wall_hit', parameters: {
        'action': 'university_favorite',
        'source': 'home_feed',
      });
      return;
    }

    final id = university.id!;
    final bool success;
    final wasFav = favoriteUniversityIds.contains(id);

    if (wasFav) {
      success = await universityFavoritesRepository.removeFavorite(userId, id);
    } else {
      success = await universityFavoritesRepository.addFavorite(
        userId,
        id,
        university: university,
      );
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

    if (!success) {
      // Repository zaten log'ladı; burada UI'ya geribildirim ver
      // İsteğe göre snackbar eklenebilir:
      // Get.snackbar('Hata', 'İşlem gerçekleştirilemedi.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ─── Beğeni — on-demand cache yaklaşımı ──────────────────────────────────

  bool isLiked(String videoId) => _likedIds.contains(videoId);
  bool isLikeLoading(String videoId) => _likeLoadingIds.contains(videoId);
  bool isShareLoading(String videoId) => _shareLoadingIds.contains(videoId);

  // ─── Like toggle — tam optimistic update ─────────────────────────────────
  // Önceki kodda _likedIds güncelleniyor ama videos listesindeki
  // VideoModel.appLikeCount dokunulmuyordu. Kart doğrudan video.appLikeCount
  // okuduğu için sayı hiç değişmiyordu. Artık toggle anında hem _likedIds
  // hem de videos listesindeki ilgili model copyWith ile güncelleniyor.
  // Hata durumunda her ikisi de rollback ediliyor.
  Future<void> toggleLike(String videoId) async {
    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;
      AnalyticsService.instance.logEvent('auth_wall_hit', parameters: {
        'action': 'like',
        'source': 'home_feed',
      });
      return;
    }
    if (_likeProcessing.contains(videoId)) return;
    if (_likeCacheLoading.contains(videoId)) return;

    _likeProcessing.add(videoId);
    _likeLoadingIds.add(videoId);

    try {
      // Cache'de yoksa DB'den bir kez sorgula
      if (!_likeCache.containsKey(videoId)) {
        _likeCacheLoading.add(videoId);
        try {
          _likeCache[videoId] = await engagementRepository.isLiked(userId, videoId);
        } finally {
          _likeCacheLoading.remove(videoId);
        }
        if (_likeCache[videoId]!) _likedIds.add(videoId);
      }

      final wasLiked = _likeCache[videoId]!;

      // ── Optimistic update: hem durum hem sayaç anında değişir ──
      _likeCache[videoId] = !wasLiked;
      if (wasLiked) {
        _likedIds.remove(videoId);
      } else {
        _likedIds.add(videoId);
      }
      _updateVideoLikeCount(videoId, wasLiked ? -1 : 1);

      try {
        if (wasLiked) {
          await engagementRepository.removeLike(userId, videoId);
        } else {
          await engagementRepository.addLike(userId, videoId);
        }
        AnalyticsService.instance.logEvent(
          wasLiked ? 'video_unlike' : 'video_like',
          parameters: {'video_id': videoId, 'source': 'home_feed'},
        );
      } catch (e, stacktrace) {
        // Rollback: hem durum hem sayaç geri alınır
        _likeCache[videoId] = wasLiked;
        if (wasLiked) {
          _likedIds.add(videoId);
        } else {
          _likedIds.remove(videoId);
        }
        _updateVideoLikeCount(videoId, wasLiked ? 1 : -1);
        log(
          'Beğeni toggle yazma işlemi sırasında hata oluştu: $e',
          error: e,
          stackTrace: stacktrace,
        );
      }
    } finally {
      _likeLoadingIds.remove(videoId);
      _likeProcessing.remove(videoId);
    }
  }

  // videos listesindeki VideoModel'in appLikeCount'unu günceller
  void _updateVideoLikeCount(String videoId, int delta) {
    final idx = videos.indexWhere((v) => v.videoId == videoId);
    if (idx == -1) return;
    final updated = videos[idx].copyWith(
      appLikeCount: (videos[idx].appLikeCount + delta).clamp(0, 999999999),
    );
    videos[idx] = updated;
  }

  // PlayerController kapanırken like durumunu senkronize eder.
  // Bu sayede player'dan beğenip geri dönünce ana sayfada da
  // durum ve sayaç doğru görünür.
  void syncLikeFromPlayer(String videoId, bool isNowLiked) {
    final wasLiked = _likeCache[videoId] ?? _likedIds.contains(videoId);
    if (wasLiked == isNowLiked) return; // zaten senkron

    _likeCache[videoId] = isNowLiked;
    // Önce sayacı güncelle, sonra _likedIds'i değiştir.
    _updateVideoLikeCount(videoId, isNowLiked ? 1 : -1);
    if (isNowLiked) {
      if (!_likedIds.contains(videoId)) _likedIds.add(videoId);
    } else {
      _likedIds.remove(videoId);
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
        if (!_sharedIds.contains(video.videoId)) {
          _sharedIds.add(video.videoId);
          // Paylaşım sayacını videos listesinde anında güncelle
          _updateVideoShareCount(video.videoId, 1);
        }
      }
      AnalyticsService.instance.logEvent('share', parameters: {
        'content_type': 'video',
        'item_id': video.videoId,
        'method': 'share_sheet',
        'source': 'home_feed',
      });
    } catch (e, stacktrace) {
      log(
        'Video paylaşılırken hata oluştu, panoya kopyalanıyor: $e',
        error: e,
        stackTrace: stacktrace,
      );
      await Clipboard.setData(ClipboardData(text: videoUrl));
      Get.snackbar(
        'Bağlantı Kopyalandı',
        'Video bağlantısı panoya kopyalandı.',
        snackPosition: SnackPosition.BOTTOM,
      );
      AnalyticsService.instance.logEvent('share', parameters: {
        'content_type': 'video',
        'item_id': video.videoId,
        'method': 'clipboard_fallback',
        'source': 'home_feed',
      });
    } finally {
      _shareLoadingIds.remove(video.videoId);
      _shareProcessing.remove(video.videoId);
    }
  }

  // ─── Hızlı Yorum Gönder (Üç Nokta Menüsü) ─────────────────────────────────
  // Kullanıcı videoya/player ekranına girmeden, kart üzerindeki "⋯" menüsünden
  // doğrudan yorum gönderebilir. Aynı comment_repository'i kullanır, böylece
  // player ekranındaki yorum listesiyle veri kaynağı ortak kalır.
  Future<bool> sendQuickComment(VideoModel video, String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;

    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;
      AnalyticsService.instance.logEvent('auth_wall_hit', parameters: {
        'action': 'comment',
        'source': 'home_feed',
      });
      return false;
    }

    if (_quickCommentSendingIds.contains(video.videoId)) return false;
    _quickCommentSendingIds.add(video.videoId);
    try {
      await commentRepository.addComment(
        userId: userId,
        videoId: video.videoId,
        content: trimmed,
      );
      _quickCommentBumps[video.videoId] =
          (_quickCommentBumps[video.videoId] ?? 0) + 1;
      if (!_commentedIds.contains(video.videoId)) {
        _commentedIds.add(video.videoId);
      }
      AnalyticsService.instance.logEvent('comment_add', parameters: {
        'video_id': video.videoId,
        'source': 'home_feed',
      });
      return true;
    } catch (e, stacktrace) {
      log(
        'Hızlı yorum gönderilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      Get.snackbar(
        'Gönderilemedi',
        'Yorumun gönderilemedi, lütfen tekrar dene.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _quickCommentSendingIds.remove(video.videoId);
    }
  }

  // ─── Navigasyon ──────────────────────────────────────────────────────────

  // FIX: Keşfet sekmesinin verisi (istatistikler + video bölümleri) artık
  // onReady()'de değil, kullanıcı sekmeye GERÇEKTEN ilk kez geçtiğinde
  // çekiliyor. Bu flag, aynı veriyi her sekme değişiminde tekrar tekrar
  // çekmemek için "bir kez yüklendi mi" bilgisini tutar.
  bool _discoveryTabInitialized = false;

  void changeTab(int index) {
    selectedIndex.value = index;
    if (index == 1 && !_discoveryTabInitialized) {
      _discoveryTabInitialized = true;
      loadUniversityStats();
      loadVideoSections();
    }
  }

  String get appBarTitle {
    final uni = selectedUniversity.value;
    if (uni == null) return 'ÜniTV';
    final name = uni.name ?? 'ÜniTV';
    if (name.length > 20) return '${name.substring(0, 18)}…';
    return name;
  }
}