import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/engagement_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/comment_model.dart';
import 'settings_controller.dart';

// HomeController ve FavoritesController IMPORT EDİLMİYOR! Bağımlılık yok.

class PlayerController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final CommentRepository commentRepository;
  final EngagementRepository engagementRepository;
  final AuthRepository authRepository;
  final VideoRepository videoRepository; // ← YENİ

  PlayerController({
    required this.favoritesRepository,
    required this.commentRepository,
    required this.engagementRepository,
    required this.authRepository,
    required this.videoRepository, // ← YENİ
  });

  YoutubePlayerController? youtubeController;
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

  final showAuthRequired = false.obs;
  final snackbarMessage = RxnString();

  final suggestedVideos = <VideoModel>[].obs;
  final isSuggestedLoading = false.obs;

  final currentVideo = Rxn<VideoModel>();
  String? get currentUserId => authRepository.currentUserId;

  @override
  void onInit() {
    super.onInit();
    currentVideo.value = Get.arguments as VideoModel?;
    log('PlayerController initialized with video: ${currentVideo.value}');
    if (currentVideo.value != null) {
      _initPlayer().then((_) {
        isPlayerReady.value = true;
        loadComments();
        _loadInitialState();
        loadSuggestedVideos(); // ← YENİ
      });
    }
  }

  Future<void> _loadInitialState() async {
    final userId = currentUserId;
    if (userId != null) {
      _resolveIsFavoriteFromCache(); // DÜZELTİLDI: HomeController kullanmıyor
    }

    // DÜZELTME: _recordView() önce bitmeli ki Supabase'deki materialized view
    // refresh triggerı ateşlensin. Ardından stats yüklenirse view sayısı doğru gelir.
    // checkLike() ise DB'yi okur, view ile yarışmaz → paralel çalışabilir.
    if (userId != null) {
      await Future.wait([_recordView(), checkLike()]);
    }
    await _loadEngagementStats(showInitialLoader: true);
  }

  // DÜZELTİLDİ: HomeController'a bağımlılık yok, doğrudan repository'den kontrol
  void _resolveIsFavoriteFromCache() {
    if (currentVideo.value == null) return;
    final videoId = currentVideo.value!.videoId;

    favoritesRepository.getFavoriteVideos().then((locals) {
      isFavorite.value = locals.any((v) => v.videoId == videoId);
    });
  }

  // lib/presentation/controllers/player_controller.dart — _initPlayer düzeltmesi
  Future<void> _initPlayer() async {
    // authRepository.getUserSettings() kaldırıldı
    final autoplay =
        Get.find<SettingsController>().settings.value?.autoplay ?? true;

    youtubeController = YoutubePlayerController.fromVideoId(
      videoId: currentVideo.value!.videoId,
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
    } catch (e) {
      log('[PlayerController] _loadEngagementStats error: $e');
    } finally {
      if (showInitialLoader) isInitialStatsLoading.value = false;
    }
  }

  // ─── Görüntüleme ─────────────────────────────────────────────────────────

  // FIX: appViewCount eskiden sadece _loadEngagementStats() ile sunucudan
  // okunuyordu. Diğer tüm sayaçlar (beğeni, favori, paylaşım, yorum) optimistic
  // güncelleniyordu ama bu unutulmuştu — bu yüzden kullanıcı videoyu izlediğinde
  // kendi izlemesini anında görmüyordu. recordView başarılıysa ve bu kullanıcı
  // için yeni bir kayıt oluştuysa sayaç hemen +1 artar.
  Future<void> _recordView() async {
    if (currentVideo.value == null) return;
    final userId = currentUserId;
    if (userId == null) return;
    try {
      await engagementRepository.recordView(userId, currentVideo.value!.videoId);
      appViewCount.value += 1;
    } catch (e) {
      log('[PlayerController] _recordView error: $e');
    }
  }

  // ─── Önerilen Videolar ───────────────────────────────────────────────────
  Future<void> loadSuggestedVideos() async {
    if (currentVideo.value == null) return;
    try {
      isSuggestedLoading.value = true;
      suggestedVideos.value = await videoRepository.getSuggestedVideos(
        currentVideo.value!.videoId,
      );
    } catch (e) {
      log('[PlayerController] loadSuggestedVideos error: $e');
    } finally {
      isSuggestedLoading.value = false;
    }
  }

  // ─── Beğeni ──────────────────────────────────────────────────────────────

  Future<void> checkLike() async {
    if (currentVideo.value == null) return;
    final userId = currentUserId;
    if (userId == null) return;
    try {
      isLiked.value = await engagementRepository.isLiked(
        userId,
        currentVideo.value!.videoId,
      );
    } catch (e) {
      log('[PlayerController] checkLike error: $e');
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
        );
      } else {
        await engagementRepository.addLike(userId, currentVideo.value!.videoId);
      }
      // OPTİMİZASYON: getEngagementStats() çağrısı kaldırıldı.
      // appLikeCount zaten yukarıda optimistic olarak güncellendi — doğru delta kesin.
    } catch (e) {
      isLiked.value = wasLiked;
      appLikeCount.value += wasLiked ? 1 : -1;
      log('toggleLike error: $e');
    } finally {
      isLikeLoading.value = false;
    }
  }

  // ─── Favori – DÜZELTİLDİ: SADECE REPOSİTORY İŞLEMLERİ, DİĞER CONTROLLER'LARA DOKUNMA ───
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
      // OPTİMİZASYON: getEngagementStats() kaldırıldı.
      // appFavoriteCount zaten optimistic güncellendi.
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
    if (currentVideo.value == null) return;
    if (isShareLoading.value) return;
    isShareLoading.value = true; // ← EN BAŞA AL

    final videoUrl =
        'https://www.youtube.com/watch?v=${currentVideo.value!.videoId}';
    final text = '${currentVideo.value!.title}\n$videoUrl';

    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: currentVideo.value!.title),
      );
      final userId = currentUserId;
      if (userId != null) {
        await engagementRepository.recordShare(
          userId,
          currentVideo.value!.videoId,
        );
        // OPTİMİZASYON: getEngagementStats() kaldırıldı — optimistic güncelleme yeterli.
        appShareCount.value += 1;
      }
    } catch (e) {
      log('[PlayerController] shareVideo fallback to clipboard: $e');
      await Clipboard.setData(ClipboardData(text: videoUrl));
      snackbarMessage.value = 'Video bağlantısı panoya kopyalandı.';
    } finally {
      isShareLoading.value = false; // ← burada kalabilir
    }
  }

  // ─── Yorumlar ────────────────────────────────────────────────────────────

  Future<void> loadComments() async {
    if (currentVideo.value == null) return;
    try {
      isCommentsLoading.value = true;
      comments.value = await commentRepository.getComments(
        currentVideo.value!.videoId,
      );
    } catch (e) {
      log('[PlayerController] loadComments error: $e');
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
      // OPTİMİZASYON: getEngagementStats() kaldırıldı — yorum sayısını doğrudan güncelle.
      appCommentCount.value += 1;
    } catch (e) {
      log('[PlayerController] addComment error: $e');
    }
  }

  Future<void> deleteComment(String commentId) async {
    if (currentVideo.value == null) return;
    try {
      await commentRepository.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);
      // OPTİMİZASYON: getEngagementStats() kaldırıldı — optimistic azalt.
      if (appCommentCount.value > 0) appCommentCount.value -= 1;
    } catch (e) {
      log('[PlayerController] deleteComment error: $e');
    }
  }

  @override
  void onClose() {
    youtubeController?.close();
    super.onClose();
  }
}