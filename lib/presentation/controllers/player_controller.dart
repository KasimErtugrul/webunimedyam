import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/engagement_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/comment_model.dart';
import 'home_controller.dart';
import 'favorites_controller.dart';

class PlayerController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final CommentRepository commentRepository;
  final EngagementRepository engagementRepository;
  final AuthRepository authRepository;

  PlayerController({
    required this.favoritesRepository,
    required this.commentRepository,
    required this.engagementRepository,
    required this.authRepository,
  });

  late YoutubePlayerController youtubeController;
  final comments = <CommentModel>[].obs;

  final isFavorite = false.obs;
  final isLiked = false.obs;
  final isPlayerReady = false.obs;
  final isCommentsLoading = false.obs;

  final isLikeLoading = false.obs;
  final isFavoriteLoading = false.obs;
  final isShareLoading = false.obs;

  final appViewCount = 0.obs;
  final appLikeCount = 0.obs;
  final appFavoriteCount = 0.obs;
  final appShareCount = 0.obs;
  final appCommentCount = 0.obs;
  final isInitialStatsLoading = true.obs;

  // UI Bayrakları
  final showAuthRequired = false.obs;
  final snackbarMessage = RxnString();

  VideoModel? currentVideo;

  String? get _currentUserId => authRepository.currentUserId;

  @override
  void onInit() {
    super.onInit();
    currentVideo = Get.arguments as VideoModel?;
    if (currentVideo != null) {
      _initPlayer().then((_) {
        isPlayerReady.value = true;
        loadComments();
        _loadInitialState();
      });
    }
  }

  Future<void> _loadInitialState() async {
    final userId = _currentUserId;
    if (userId != null) {
      _resolveIsFavoriteFromCache();
    }

    await Future.wait([
      _loadEngagementStats(showInitialLoader: true),
      if (userId != null) checkLike(),
      _recordView(),
    ]);
  }

  void _resolveIsFavoriteFromCache() {
    if (currentVideo == null) return;
    final videoId = currentVideo!.videoId;

    if (Get.isRegistered<HomeController>()) {
      final hc = Get.find<HomeController>();
      isFavorite.value = hc.favoriteIds.contains(videoId);
      return;
    }

    favoritesRepository.getFavoriteVideos().then((locals) {
      isFavorite.value = locals.any((v) => v.videoId == videoId);
    });
  }

  Future<void> _initPlayer() async {
    bool autoplay = true;

    try {
      final userSettings = await authRepository.getUserSettings();
      autoplay = userSettings?.autoplay ?? true;
    } catch (e) {
      log('[PlayerController] Autoplay setting error: $e');
    }

    youtubeController = YoutubePlayerController.fromVideoId(
      videoId: currentVideo!.videoId,
      autoPlay: autoplay,
      params: const YoutubePlayerParams(
        showFullscreenButton: false,
        showControls: true,
        strictRelatedVideos: true,
        enableCaption: true,
        captionLanguage: 'tur',
        playsInline: true,
        loop: false,
        mute: false,
      ),
    );
  }

  // ─── Stats ───────────────────────────────────────────────────────────────

  Future<void> _loadEngagementStats({bool showInitialLoader = false}) async {
    if (currentVideo == null) return;
    if (showInitialLoader) isInitialStatsLoading.value = true;
    try {
      final stats = await engagementRepository.getEngagementStats(
        currentVideo!.videoId,
      );
      appViewCount.value = stats['app_view_count'] ?? 0;
      appLikeCount.value = stats['app_like_count'] ?? 0;
      appFavoriteCount.value = stats['app_favorite_count'] ?? 0;
      appShareCount.value = stats['app_share_count'] ?? 0;
      appCommentCount.value = stats['app_comment_count'] ?? 0;
    } catch (e) {
      log('[PlayerController] _loadEngagementStats error: $e');
    } finally {
      if (showInitialLoader) isInitialStatsLoading.value = false;
    }
  }

  // ─── Görüntüleme ─────────────────────────────────────────────────────────

  Future<void> _recordView() async {
    if (currentVideo == null) return;
    final userId = _currentUserId;
    if (userId == null) return;
    await engagementRepository.recordView(userId, currentVideo!.videoId);
  }

  // ─── Beğeni ──────────────────────────────────────────────────────────────

  Future<void> checkLike() async {
    if (currentVideo == null) return;
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      isLiked.value = await engagementRepository.isLiked(
        userId,
        currentVideo!.videoId,
      );
    } catch (e) {
      log('[PlayerController] checkLike error: $e');
    }
  }

  Future<void> toggleLike() async {
    if (currentVideo == null) return;
    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true; // Bayrak kaldırıldı
      return;
    }
    if (isLikeLoading.value) return;

    isLikeLoading.value = true;
    final wasLiked = isLiked.value;
    isLiked.value = !wasLiked;
    appLikeCount.value += wasLiked ? -1 : 1;

    try {
      if (wasLiked) {
        await engagementRepository.removeLike(userId, currentVideo!.videoId);
      } else {
        await engagementRepository.addLike(userId, currentVideo!.videoId);
      }
      final stats = await engagementRepository.getEngagementStats(
        currentVideo!.videoId,
      );
      appLikeCount.value = stats['app_like_count'] ?? appLikeCount.value;
    } catch (e) {
      isLiked.value = wasLiked;
      appLikeCount.value += wasLiked ? 1 : -1;
      log('toggleLike error: $e');
    } finally {
      isLikeLoading.value = false;
    }
  }

  // ─── Favori ──────────────────────────────────────────────────────────────

  Future<void> toggleFavorite() async {
    if (currentVideo == null) return;
    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true; // Bayrak kaldırıldı
      return;
    }
    if (isFavoriteLoading.value) return;

    isFavoriteLoading.value = true;
    final wasAdding = !isFavorite.value;
    isFavorite.value = wasAdding;
    appFavoriteCount.value += wasAdding ? 1 : -1;

    try {
      if (!wasAdding) {
        await favoritesRepository.removeFavorite(userId, currentVideo!.videoId);
        await favoritesRepository.removeFavoriteVideoLocally(
          currentVideo!.videoId,
        );
      } else {
        await favoritesRepository.addFavorite(userId, currentVideo!.videoId);
        await favoritesRepository.saveFavoriteVideoLocally(currentVideo!);
      }

      if (Get.isRegistered<HomeController>()) {
        final hc = Get.find<HomeController>();
        if (wasAdding) {
          hc.favoriteIds.add(currentVideo!.videoId);
        } else {
          hc.favoriteIds.remove(currentVideo!.videoId);
        }
      }

      if (Get.isRegistered<FavoritesController>()) {
        final fc = Get.find<FavoritesController>();
        if (wasAdding) {
          fc.addFavoriteVideo(currentVideo!);
        } else {
          fc.removeFavoriteVideo(currentVideo!.videoId);
        }
      }

      final stats = await engagementRepository.getEngagementStats(
        currentVideo!.videoId,
      );
      appFavoriteCount.value =
          stats['app_favorite_count'] ?? appFavoriteCount.value;
    } catch (e) {
      isFavorite.value = !wasAdding;
      appFavoriteCount.value += wasAdding ? -1 : 1;
      log('toggleFavorite error: $e');
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  // ─── Paylaşım ────────────────────────────────────────────────────────────

  Future<void> shareVideo() async {
    if (currentVideo == null) return;
    if (isShareLoading.value) return;
    final videoUrl = 'https://www.youtube.com/watch?v=${currentVideo!.videoId}';
    final text = '${currentVideo!.title}\n$videoUrl';

    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: currentVideo!.title),
      );
      final userId = _currentUserId;
      if (userId != null) {
        isShareLoading.value = true;
        await engagementRepository.recordShare(userId, currentVideo!.videoId);
        final stats = await engagementRepository.getEngagementStats(
          currentVideo!.videoId,
        );
        appShareCount.value = stats['app_share_count'] ?? appShareCount.value;
      }
    } catch (e) {
      log('[PlayerController] shareVideo fallback to clipboard: $e');
      await Clipboard.setData(ClipboardData(text: videoUrl));
      snackbarMessage.value = 'Video bağlantısı panoya kopyalandı.'; // Bayrak kaldırıldı
    } finally {
      isShareLoading.value = false;
    }
  }

  // ─── Yorumlar ─────────────────────────────────────────────────────────────

  Future<void> loadComments() async {
    if (currentVideo == null) return;
    try {
      isCommentsLoading.value = true;
      comments.value = await commentRepository.getComments(
        currentVideo!.videoId,
      );
    } catch (e) {
      log('[PlayerController] loadComments error: $e');
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> addComment(String content) async {
    if (currentVideo == null) return;
    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true; // DÜZELTİLDİ: Eski _showAuthDialog yerine bayrak
      return;
    }
    if (content.trim().isEmpty) return;
    try {
      await commentRepository.addComment(
        userId: userId,
        videoId: currentVideo!.videoId,
        content: content.trim(),
      );
      await loadComments();
      final stats = await engagementRepository.getEngagementStats(
        currentVideo!.videoId,
      );
      appCommentCount.value =
          stats['app_comment_count'] ?? appCommentCount.value;
    } catch (e) {
      log('[PlayerController] addComment error: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    if (currentVideo == null) return;
    try {
      await commentRepository.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);
      final stats = await engagementRepository.getEngagementStats(
        currentVideo!.videoId,
      );
      appCommentCount.value =
          stats['app_comment_count'] ?? appCommentCount.value;
    } catch (e) {
      log('[PlayerController] deleteComment error: $e');
    }
  }

  @override
  void onClose() {
    youtubeController.close();
    super.onClose();
  }
}