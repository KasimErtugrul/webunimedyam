import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/datasources/local/local_datasource.dart';
import 'home_controller.dart';
import 'favorites_controller.dart';
import 'profile_controller.dart';

class PlayerController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final CommentRepository commentRepository;
  final SupabaseDataSource supabaseDataSource;
  // ignore: unused_field
  final LocalDataSource localDataSource;

  PlayerController({
    required this.favoritesRepository,
    required this.commentRepository,
    required this.supabaseDataSource,
    required this.localDataSource,
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

  /// Fullscreen durumunu takip eder — PlayerScreen bu değeri dinler.
  final isFullscreen = false.obs;

  VideoModel? currentVideo;

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
    final userId = supabaseDataSource.currentUser?.id;
    await Future.wait([
      _loadEngagementStats(showInitialLoader: true),
      if (userId != null) checkFavorite(),
      if (userId != null) checkLike(),
      _recordView(),
    ]);
  }

  Future<void> _initPlayer() async {
    bool autoplay = true;
    try {
      final userId = supabaseDataSource.currentUser?.id;
      if (userId != null) {
        final userSettings = await supabaseDataSource.getUserSettings(userId);
        autoplay = userSettings?.autoplay ?? true;
      }
    } catch (e) {
      log('[PlayerController] _initPlayer settings error: $e');
    }

    youtubeController = YoutubePlayerController(
      initialVideoId: currentVideo!.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: autoplay,
        mute: false,
        enableCaption: false,
        captionLanguage: 'tr',
        // Fullscreen butonunu etkinleştir
        forceHD: false,
        useHybridComposition: true,
        // youtube_player_flutter kendi içinde fullscreen'i yönetir;
        // handleFullScreen: true ile bunu controller'a bırakıyoruz.
        controlsVisibleAtStart: true,
        hideThumbnail: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        //forceHD: false,
      ),
    );

    // Fullscreen değişikliklerini dinle → Android sistem UI'ını güncelle
    youtubeController.addListener(_onYoutubeStateChange);
  }

  void _onYoutubeStateChange() {
    final entering = youtubeController.value.isFullScreen;

    if (entering == isFullscreen.value) return; // değişim yoksa çık
    isFullscreen.value = entering;

    if (entering) {
      // Tam ekrana girerken: navigation bar + status bar'ı gizle,
      // sticky immersive mod ile geri getirilebilir yapıyoruz.
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Tam ekrandan çıkarken: sistem UI'ını geri getir
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  // ─── Stats ───────────────────────────────────────────────────────────────

  Future<void> _loadEngagementStats({bool showInitialLoader = false}) async {
    if (currentVideo == null) return;
    if (showInitialLoader) isInitialStatsLoading.value = true;
    try {
      final stats =
          await supabaseDataSource.getEngagementStats(currentVideo!.videoId);
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
    final userId = supabaseDataSource.currentUser?.id;
    if (userId == null) return;
    try {
      await supabaseDataSource.recordView(userId, currentVideo!.videoId);
    } catch (e) {
      log('[PlayerController] _recordView error: $e');
    }
  }

  // ─── Beğeni ──────────────────────────────────────────────────────────────

  Future<void> checkLike() async {
    if (currentVideo == null) return;
    final userId = supabaseDataSource.currentUser?.id;
    if (userId == null) return;
    try {
      isLiked.value =
          await supabaseDataSource.isLiked(userId, currentVideo!.videoId);
    } catch (e) {
      log('[PlayerController] checkLike error: $e');
    }
  }

  Future<void> toggleLike() async {
    if (currentVideo == null) return;
    final userId = supabaseDataSource.currentUser?.id;
    if (userId == null) {
      _showAuthDialog();
      return;
    }
    if (isLikeLoading.value) return;

    isLikeLoading.value = true;
    final wasLiked = isLiked.value;
    isLiked.value = !wasLiked;
    appLikeCount.value += wasLiked ? -1 : 1;

    try {
      if (wasLiked) {
        await supabaseDataSource.removeLike(userId, currentVideo!.videoId);
      } else {
        await supabaseDataSource.addLike(userId, currentVideo!.videoId);
      }
      final stats =
          await supabaseDataSource.getEngagementStats(currentVideo!.videoId);
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

  Future<void> checkFavorite() async {
    if (currentVideo == null) return;
    final userId = supabaseDataSource.currentUser?.id;
    if (userId == null) return;
    try {
      final ids = await favoritesRepository.getFavoriteVideoIds(userId);
      isFavorite.value = ids.contains(currentVideo!.videoId);
    } catch (e) {
      log('[PlayerController] checkFavorite error: $e');
    }
  }

  Future<void> toggleFavorite() async {
    if (currentVideo == null) return;
    final userId = supabaseDataSource.currentUser?.id;
    if (userId == null) {
      _showAuthDialog();
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
            userId, currentVideo!.videoId);
        await favoritesRepository
            .removeFavoriteVideoLocally(currentVideo!.videoId);
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
          fc.favoriteVideos.insert(0, currentVideo!);
        } else {
          fc.favoriteVideos
              .removeWhere((v) => v.videoId == currentVideo!.videoId);
        }
      }
      final stats =
          await supabaseDataSource.getEngagementStats(currentVideo!.videoId);
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
    final videoUrl =
        'https://www.youtube.com/watch?v=${currentVideo!.videoId}';
    final text = '${currentVideo!.title}\n$videoUrl';

    try {
      await SharePlus.instance.share(ShareParams(text: text, subject: currentVideo!.title));
      final userId = supabaseDataSource.currentUser?.id;
      if (userId != null) {
        isShareLoading.value = true;
        await supabaseDataSource.recordShare(userId, currentVideo!.videoId);
        final stats = await supabaseDataSource
            .getEngagementStats(currentVideo!.videoId);
        appShareCount.value =
            stats['app_share_count'] ?? appShareCount.value;
      }
    } catch (e) {
      log('[PlayerController] shareVideo fallback to clipboard: $e');
      await Clipboard.setData(ClipboardData(text: videoUrl));
      Get.snackbar(
        'Bağlantı kopyalandı',
        'Video bağlantısı panoya kopyalandı.',
        backgroundColor: const Color(0xFF1E1E2E),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isShareLoading.value = false;
    }
  }

  // ─── Yorumlar ─────────────────────────────────────────────────────────────

  Future<void> loadComments() async {
    if (currentVideo == null) return;
    try {
      isCommentsLoading.value = true;
      comments.value =
          await commentRepository.getComments(currentVideo!.videoId);
    } catch (e) {
      log('[PlayerController] loadComments error: $e');
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> addComment(String content) async {
    if (currentVideo == null) return;
    final userId = supabaseDataSource.currentUser?.id;
    if (userId == null) {
      _showAuthDialog();
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
      final stats =
          await supabaseDataSource.getEngagementStats(currentVideo!.videoId);
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
      final stats =
          await supabaseDataSource.getEngagementStats(currentVideo!.videoId);
      appCommentCount.value =
          stats['app_comment_count'] ?? appCommentCount.value;

      if (Get.isRegistered<ProfileController>()) {
        final userId = supabaseDataSource.currentUser?.id;
        final hasMoreComments = comments.any((c) => c.userId == userId);
        if (!hasMoreComments) {
          Get.find<ProfileController>().commentedVideos.removeWhere(
                (v) => v.videoId == currentVideo!.videoId,
              );
        }
      }
    } catch (e) {
      log('[PlayerController] deleteComment error: $e');
    }
  }

  // ─── Auth Dialog ──────────────────────────────────────────────────────────

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
            child: const Text(
              'Vazgeç',
              style: TextStyle(color: Color(0xFF9E9EB8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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

  @override
  void onClose() {
    // Listener'ı temizle ve sistem UI'ını normale döndür
    youtubeController.removeListener(_onYoutubeStateChange);
    youtubeController.dispose();

    // Ekrandan çıkarken portrait'e döndür ve sistem UI'ını geri getir
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.onClose();
  }
}