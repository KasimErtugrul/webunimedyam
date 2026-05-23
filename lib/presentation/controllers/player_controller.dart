import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/datasources/local/local_datasource.dart';
import 'home_controller.dart';
import 'favorites_controller.dart';

// ProfileController import'u kaldırıldı! (Spagetti bağ koptu)

class PlayerController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final CommentRepository commentRepository;
  final SupabaseDataSource supabaseDataSource;
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

    if (userId != null) {
      _resolveIsFavoriteFromCache();
    }

    await Future.wait([
      _loadEngagementStats(showInitialLoader: true),
      if (userId != null) checkLike(),
      _recordView(),
    ]);
  }

  // FIX: Doğrudan localDataSource yerine favoritesRepository kullanıldı.
  void _resolveIsFavoriteFromCache() {
    if (currentVideo == null) return;
    final videoId = currentVideo!.videoId;

    // HomeController zaten favoriteIds'i bellekte tutuyorsa hemen kullan
    if (Get.isRegistered<HomeController>()) {
      final hc = Get.find<HomeController>();
      isFavorite.value = hc.favoriteIds.contains(videoId);
      return;
    }

    // HomeController yok → Repository'den oku (Repo zaten local'e bakar)
    favoritesRepository.getFavoriteVideos().then((locals) {
      isFavorite.value = locals.any((v) => v.videoId == videoId);
    });
  }

  Future<void> _initPlayer() async {
    bool autoplay = true;

    try {
      final userId = supabaseDataSource.currentUser?.id;
      if (userId != null) {
        final cached = await localDataSource.getCachedUserSettings();
        if (cached != null) {
          autoplay = (cached['autoplay'] as bool?) ?? true;
        } else {
          final userSettings = await supabaseDataSource.getUserSettings(userId);
          autoplay = userSettings?.autoplay ?? true;
          if (userSettings != null) {
            await localDataSource.cacheUserSettings(userSettings.toSupabase());
          }
        }
      }
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
      final stats = await supabaseDataSource.getEngagementStats(
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
      isLiked.value = await supabaseDataSource.isLiked(
        userId,
        currentVideo!.videoId,
      );
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
      final stats = await supabaseDataSource.getEngagementStats(
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

  // FIX: Cross-Controller Mutation temizlendi!
  // Artık diğer controller'ların listelerine direkt müdahale etmek yerine
  // onların kendi public metotlarını (addFavoriteVideo / removeFavoriteVideo) çağırıyoruz.
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
      // 1. Supabase ve Local Kayıt
      if (!wasAdding) {
        await favoritesRepository.removeFavorite(userId, currentVideo!.videoId);
        await favoritesRepository.removeFavoriteVideoLocally(
          currentVideo!.videoId,
        );
      } else {
        await favoritesRepository.addFavorite(userId, currentVideo!.videoId);
        await favoritesRepository.saveFavoriteVideoLocally(currentVideo!);
      }

      // 2. Diğer Controller'ları Güvenle Haberdar Et
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
          fc.addFavoriteVideo(currentVideo!); // Güvenli metot çağrısı
        } else {
          fc.removeFavoriteVideo(
            currentVideo!.videoId,
          ); // Güvenli metot çağrısı
        }
      }

      // 3. İstatistikleri Güncelle
      final stats = await supabaseDataSource.getEngagementStats(
        currentVideo!.videoId,
      );
      appFavoriteCount.value =
          stats['app_favorite_count'] ?? appFavoriteCount.value;
    } catch (e) {
      // Hata olursa Optimistic UI'ı geri al
      isFavorite.value = !wasAdding;
      appFavoriteCount.value += wasAdding ? -1 : 1;
      log('toggleFavorite error: $e');
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  // ─── Paylaşım ────────────────────────────────────────────────────────────

  // TODO: MİMARİ BORÇ - Get.snackbar UI kodudur, Controller'da olmamalıdır.
  Future<void> shareVideo() async {
    if (currentVideo == null) return;
    if (isShareLoading.value) return;
    final videoUrl = 'https://www.youtube.com/watch?v=${currentVideo!.videoId}';
    final text = '${currentVideo!.title}\n$videoUrl';

    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: currentVideo!.title),
      );
      final userId = supabaseDataSource.currentUser?.id;
      if (userId != null) {
        isShareLoading.value = true;
        await supabaseDataSource.recordShare(userId, currentVideo!.videoId);
        final stats = await supabaseDataSource.getEngagementStats(
          currentVideo!.videoId,
        );
        appShareCount.value = stats['app_share_count'] ?? appShareCount.value;
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
      final stats = await supabaseDataSource.getEngagementStats(
        currentVideo!.videoId,
      );
      appCommentCount.value =
          stats['app_comment_count'] ?? appCommentCount.value;
    } catch (e) {
      log('[PlayerController] addComment error: $e');
    }
  }

  // FIX: ProfileController'a direkt müdahale kaldırıldı!
  // Silme işlemini ProfileController kendi ekranına dönünce Repository'den çekip farkedecek.
  Future<void> deleteComment(String commentId) async {
    if (currentVideo == null) return;
    try {
      await commentRepository.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);
      final stats = await supabaseDataSource.getEngagementStats(
        currentVideo!.videoId,
      );
      appCommentCount.value =
          stats['app_comment_count'] ?? appCommentCount.value;
    } catch (e) {
      log('[PlayerController] deleteComment error: $e');
    }
  }

  // ─── Auth Dialog ──────────────────────────────────────────────────────────

  // TODO: MİMARİ BORÇ (Tech Debt) - Bu UI kodu Controller'da olmamalı.
  // Controller sadece bir flag kaldırmalı (showAuthRequired = true), UI dinlemeli.
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
    youtubeController.close();
    super.onClose();
  }
}
