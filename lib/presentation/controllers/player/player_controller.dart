// lib/presentation/controllers/player_controller.dart
import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/utils/share_helper.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../data/repositories/engagement_repository.dart';
import '../../../data/repositories/favorites_repository.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../data/repositories/watch_progress_repository.dart';
import '../home/home_controller.dart';
import '../player/watch_progress_tracker.dart';
import '../settings_controller.dart';

class PlayerController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final CommentRepository commentRepository;
  final EngagementRepository engagementRepository;
  final AuthRepository authRepository;
  final VideoRepository videoRepository;
  final WatchProgressRepository watchProgressRepository;

  PlayerController({
    required this.favoritesRepository,
    required this.commentRepository,
    required this.engagementRepository,
    required this.authRepository,
    required this.videoRepository,
    required this.watchProgressRepository,
  });

  YoutubePlayerController? youtubeController;
  final comments = <CommentModel>[].obs;

  final isFavorite = false.obs;
  final isLiked = false.obs;
  final isPlayerReady = false.obs;
  final isCommentsLoading = false.obs;

  /// Player init watchdog: paketin kendi 30sn timeout'undan önce biz
  /// 12sn'de hata veririz, kullanıcıyı boş ekranda bırakmayız.
  final hasPlayerError = false.obs;
  Timer? _initWatchdog;
  static const _playerInitWatchdogDuration = Duration(seconds: 12);

  final isLikeLoading = false.obs;
  final isFavoriteLoading = false.obs;
  final isShareLoading = false.obs;

  final appViewCount = 0.obs;
  final appLikeCount = 0.obs;
  final appFavoriteCount = 0.obs;
  final appShareCount = 0.obs;
  final appCommentCount = 0.obs;
  final isInitialStatsLoading = true.obs;

  int _commentCountDeltaThisSession = 0;
  int _shareCountDeltaThisSession = 0;

  final showAuthRequired = false.obs;
  final snackbarMessage = RxnString();

  final suggestedVideos = <VideoModel>[].obs;
  final isSuggestedLoading = false.obs;

  final currentVideo = Rxn<VideoModel>();

  /// Yorumlar, en yeni en üstte. (Repo sırasına güvenmeden createdAt'e göre.)
  /// Obx içinde çağrılırsa [comments] değişince otomatik yenilenir.
  List<CommentModel> get commentsNewestFirst {
    final list = List<CommentModel>.of(comments);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  String? get currentUserId => authRepository.currentUserId;

  /// İzlemeye Devam Et — kendi state'ini yöneten bağımsız helper.
  late final WatchProgressTracker _progress;

  @override
  void onInit() {
    super.onInit();

    _progress = WatchProgressTracker(
      repository: watchProgressRepository,
      getController: () => youtubeController,
      getVideo: () => currentVideo.value,
    );

    final argVideo = Get.arguments as VideoModel?;
    if (argVideo != null) {
      currentVideo.value = argVideo;
      _startPlayerFlow();
      return;
    }

    // Deep link: sadece videoId var, tam modeli çek.
    final deepLinkVideoId = Get.parameters['videoId'];
    if (deepLinkVideoId != null && deepLinkVideoId.isNotEmpty) {
      _loadVideoByIdAndStart(deepLinkVideoId);
    }
  }

  Future<void> _loadVideoByIdAndStart(String videoId) async {
    try {
      final video = await videoRepository.getVideoById(videoId);
      if (video == null) {
        hasPlayerError.value = true;
        return;
      }
      currentVideo.value = video;
      _startPlayerFlow();
    } catch (e, st) {
      hasPlayerError.value = true;
      log(
        'Deep link videosu yüklenirken hata ($videoId): $e',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _startPlayerFlow() {
    _startInitWatchdog();
    _initPlayer().then((_) async {
      _initWatchdog?.cancel();
      isPlayerReady.value = true;
      loadComments();
      _loadInitialState();
      loadSuggestedVideos();

      await _progress.restore();
      _progress.start();
    });
  }

  void _startInitWatchdog() {
    _initWatchdog?.cancel();
    hasPlayerError.value = false;
    _initWatchdog = Timer(_playerInitWatchdogDuration, () {
      if (!isPlayerReady.value) {
        hasPlayerError.value = true;
      }
    });
  }

  Future<void> retryInitPlayer() async {
    if (currentVideo.value == null) return;
    hasPlayerError.value = false;
    isPlayerReady.value = false;
    youtubeController?.close();
    youtubeController = null;

    _startInitWatchdog();
    await _initPlayer();
    _initWatchdog?.cancel();
    if (youtubeController != null) {
      isPlayerReady.value = true;
      await _progress.restore();
      _progress.start();
    } else {
      hasPlayerError.value = true;
    }
  }

  Future<void> _initPlayer() async {
    try {
      final autoplay =
          Get.find<SettingsController>().settings.value?.autoplay ?? true;

      youtubeController = YoutubePlayerController.fromVideoId(
        videoId: currentVideo.value!.videoId,
        autoPlay: autoplay,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
          strictRelatedVideos: true,
          enableCaption: true,
          captionLanguage: 'tur',
          playsInline: true,
          loop: false,
          mute: false,
        ),
      );

      // Paketin resmi API'si: tam ekran açılıp kapanınca haber verir.
      // (iframe 6.x cihazı kendisi döndürmez; yönü buradan biz veriyoruz.)
      youtubeController!.setFullScreenListener(_onFullScreenChanged);
    } catch (e, st) {
      log('Player başlatılırken hata: $e', error: e, stackTrace: st);
    }
  }

  void _onFullScreenChanged(bool isFullScreen) {
    if (isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      _restoreSystemChrome();
    }
  }

  void _restoreSystemChrome() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // ─── İlk durum ─────────────────────────────────────────────────────────

  Future<void> _loadInitialState() async {
    try {
      final userId = currentUserId;
      if (userId != null) {
        _resolveIsFavoriteFromCache();
        await Future.wait([_recordView(), checkLike()]);
      }
      await _loadEngagementStats(showInitialLoader: true);
    } catch (e, st) {
      log(
        'Player başlangıç durumu yüklenirken hata: $e',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _resolveIsFavoriteFromCache() {
    try {
      if (currentVideo.value == null) return;
      final videoId = currentVideo.value!.videoId;
      favoritesRepository
          .getFavoriteVideos()
          .then((locals) {
            isFavorite.value = locals.any((v) => v.videoId == videoId);
          })
          .catchError((e, st) {
            log(
              'Favori durumu cache\'den kontrol edilirken hata: $e',
              error: e,
              stackTrace: st,
            );
          });
    } catch (e, st) {
      log('Favori durumu çözümlenirken hata: $e', error: e, stackTrace: st);
    }
  }

  // ─── Stats ─────────────────────────────────────────────────────────────

  Future<void> _loadEngagementStats({bool showInitialLoader = false}) async {
    if (currentVideo.value == null) return;
    if (showInitialLoader) isInitialStatsLoading.value = true;
    try {
      final stats = await engagementRepository.getEngagementStats(
        currentVideo.value!.videoId,
      );
      appViewCount.value = stats['app_view_count'] ?? 0;
      appLikeCount.value = stats['app_like_count'] ?? 0;
      appFavoriteCount.value = stats['app_favorite_count'] ?? 0;
      appShareCount.value = stats['app_share_count'] ?? 0;
      appCommentCount.value = stats['app_comment_count'] ?? 0;
    } catch (e, st) {
      log(
        'Etkileşim istatistikleri yüklenirken hata: $e',
        error: e,
        stackTrace: st,
      );
    } finally {
      if (showInitialLoader) isInitialStatsLoading.value = false;
    }
  }

  // ─── Görüntüleme ───────────────────────────────────────────────────────

  Future<void> _recordView() async {
    if (currentVideo.value == null) return;
    final userId = currentUserId;
    if (userId == null) return;
    try {
      final isNewView = await engagementRepository.recordView(
        userId,
        currentVideo.value!.videoId,
        video: currentVideo.value,
      );
      if (isNewView) appViewCount.value += 1;
    } catch (e, st) {
      log('Görüntülenme kaydedilirken hata: $e', error: e, stackTrace: st);
    }
  }

  // ─── Önerilen videolar ─────────────────────────────────────────────────

  Future<void> loadSuggestedVideos() async {
    if (currentVideo.value == null) return;
    try {
      isSuggestedLoading.value = true;
      suggestedVideos.value = await videoRepository.getSuggestedVideos(
        currentVideo.value!.videoId,
      );
    } catch (e, st) {
      log('Önerilen videolar yüklenirken hata: $e', error: e, stackTrace: st);
    } finally {
      isSuggestedLoading.value = false;
    }
  }

  // ─── Beğeni ────────────────────────────────────────────────────────────

  Future<void> checkLike() async {
    if (currentVideo.value == null) return;
    final userId = currentUserId;
    if (userId == null) return;
    try {
      isLiked.value = await engagementRepository.isLiked(
        userId,
        currentVideo.value!.videoId,
      );
    } catch (e, st) {
      log('Beğeni durumu kontrol edilirken hata: $e', error: e, stackTrace: st);
    }
  }

  Future<void> toggleLike() async {
    if (currentVideo.value == null) return;
    final userId = currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;

      return;
    }
    if (isLikeLoading.value) return;

    isLikeLoading.value = true;
    final wasLiked = isLiked.value;
    isLiked.value = !wasLiked;
    appLikeCount.value += wasLiked ? -1 : 1;

    try {
      if (wasLiked) {
        await engagementRepository.removeLike(
          userId,
          currentVideo.value!.videoId,
          video: currentVideo.value,
        );
      } else {
        await engagementRepository.addLike(
          userId,
          currentVideo.value!.videoId,
          video: currentVideo.value,
        );
      }
    } catch (e, st) {
      isLiked.value = wasLiked;
      appLikeCount.value += wasLiked ? 1 : -1;
      log('Beğeni toggle hatası: $e', error: e, stackTrace: st);
    } finally {
      isLikeLoading.value = false;
    }
  }

  // ─── Favori ────────────────────────────────────────────────────────────

  Future<void> toggleFavorite() async {
    if (currentVideo.value == null) return;
    final userId = currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;

      return;
    }
    if (isFavoriteLoading.value) return;

    isFavoriteLoading.value = true;
    final wasAdding = !isFavorite.value;
    isFavorite.value = wasAdding;
    appFavoriteCount.value += wasAdding ? 1 : -1;

    try {
      if (!wasAdding) {
        await favoritesRepository.removeFavorite(
          userId,
          currentVideo.value!.videoId,
        );
        await favoritesRepository.removeFavoriteVideoLocally(
          currentVideo.value!.videoId,
        );
      } else {
        await favoritesRepository.addFavorite(
          userId,
          currentVideo.value!.videoId,
        );
        await favoritesRepository.saveFavoriteVideoLocally(currentVideo.value!);
      }
    } catch (e, st) {
      isFavorite.value = !wasAdding;
      appFavoriteCount.value += wasAdding ? -1 : 1;
      log('Favori toggle hatası: $e', error: e, stackTrace: st);
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  // ─── Paylaşım ──────────────────────────────────────────────────────────

  Future<void> shareVideo() async {
    if (currentVideo.value == null) return;
    if (isShareLoading.value) return;
    isShareLoading.value = true;

    final videoUrl = ShareHelper.buildWebFallback(currentVideo.value!.videoId);

    try {
      await ShareHelper.shareVideo(
        videoId: currentVideo.value!.videoId,
        title: currentVideo.value!.title,
        universityName: currentVideo.value!.universityName,
        thumbnailUrl: currentVideo.value!.bestThumbnail,
      );
      final userId = currentUserId;
      if (userId != null) {
        await engagementRepository.recordShare(
          userId,
          currentVideo.value!.videoId,
        );
        appShareCount.value += 1;
        _shareCountDeltaThisSession += 1;
      }
    } catch (e, st) {
      log(
        'Paylaşım başarısız, panoya kopyalanıyor: $e',
        error: e,
        stackTrace: st,
      );
      await Clipboard.setData(ClipboardData(text: videoUrl));
      snackbarMessage.value = 'Video bağlantısı panoya kopyalandı.';
    } finally {
      isShareLoading.value = false;
    }
  }

  // ─── Yorumlar ──────────────────────────────────────────────────────────

  Future<void> loadComments() async {
    if (currentVideo.value == null) return;
    try {
      isCommentsLoading.value = true;
      comments.value = await commentRepository.getComments(
        currentVideo.value!.videoId,
      );
    } catch (e, st) {
      log('Yorumlar yüklenirken hata: $e', error: e, stackTrace: st);
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> addComment(String content) async {
    if (currentVideo.value == null) return;
    final userId = currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;

      return;
    }
    if (content.trim().isEmpty) return;
    try {
      await commentRepository.addComment(
        userId: userId,
        videoId: currentVideo.value!.videoId,
        content: content.trim(),
      );
      await loadComments();
      appCommentCount.value += 1;
      _commentCountDeltaThisSession += 1;
    } catch (e, st) {
      log('Yorum eklenirken hata: $e', error: e, stackTrace: st);
    }
  }

  Future<void> deleteComment(String commentId) async {
    if (currentVideo.value == null) return;
    try {
      await commentRepository.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);
      if (appCommentCount.value > 0) appCommentCount.value -= 1;
      _commentCountDeltaThisSession -= 1;
    } catch (e, st) {
      log('Yorum silinirken hata: $e', error: e, stackTrace: st);
    }
  }

  @override
  void onClose() {
    // Progress: son konumu kaydet + timer'ı durdur.
    _progress.persistOnClose();

    // Home'a dönüşte engagement sayaçlarını senkronize et.
    // Not: HomeController artık facade; sync* metotları hâlâ çalışıyor.
    try {
      if (currentVideo.value != null && Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        home.syncLikeFromPlayer(currentVideo.value!.videoId, isLiked.value);
        home.syncFavoriteFromPlayer(
          currentVideo.value!.videoId,
          isFavorite.value,
        );
        home.syncViewCountFromPlayer(
          currentVideo.value!.videoId,
          appViewCount.value,
        );
        if (_commentCountDeltaThisSession != 0) {
          home.syncCommentCountFromPlayer(
            currentVideo.value!.videoId,
            _commentCountDeltaThisSession,
          );
        }
        if (_shareCountDeltaThisSession != 0) {
          home.syncShareCountFromPlayer(
            currentVideo.value!.videoId,
            _shareCountDeltaThisSession,
          );
        }
      }
    } catch (_) {}

    _initWatchdog?.cancel();
    _restoreSystemChrome();
    youtubeController?.close();
    super.onClose();
  }
}
