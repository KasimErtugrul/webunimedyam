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

  PlayerController({
    required this.favoritesRepository,
    required this.commentRepository,
  });

  final _supabase = SupabaseDataSource();
  // ignore: unused_field
  final _local = LocalDataSource();

  late YoutubePlayerController youtubeController;
  final comments = <CommentModel>[].obs;

  final isFavorite = false.obs;
  final isLiked = false.obs;
  final isPlayerReady = false.obs;
  final isCommentsLoading = false.obs;

  // Her aksiyon için ayrı loading — UI'da sadece o değişir
  final isLikeLoading = false.obs;
  final isFavoriteLoading = false.obs;
  final isShareLoading = false.obs;

  // Uygulama içi istatistikler — her biri bağımsız observable
  final appViewCount = 0.obs;
  final appLikeCount = 0.obs;
  final appFavoriteCount = 0.obs;
  final appShareCount = 0.obs;
  final appCommentCount = 0.obs;
  final isInitialStatsLoading = true.obs; // Sadece ilk yükleme için

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
    final userId = _supabase.currentUser?.id;
    // Stat yükleme + kullanıcı durumu paralel çalışsın
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
      final userId = _supabase.currentUser?.id;
      if (userId != null) {
        final userSettings = await _supabase.getUserSettings(userId);
        autoplay = userSettings?.autoplay ?? true;
      }
    } catch (_) {}

    youtubeController = YoutubePlayerController(
      initialVideoId: currentVideo!.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: autoplay,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  // ─── Stats ───────────────────────────────────────────────────────────────

  /// [showInitialLoader] sadece ilk açılışta true — sonrasında sayılar
  /// sessizce güncellenir, spinner gösterilmez.
  Future<void> _loadEngagementStats({bool showInitialLoader = false}) async {
    if (showInitialLoader) isInitialStatsLoading.value = true;
    try {
      final stats = await _supabase.getEngagementStats(currentVideo!.videoId);
      appViewCount.value    = stats['app_view_count']    ?? 0;
      appLikeCount.value    = stats['app_like_count']    ?? 0;
      appFavoriteCount.value = stats['app_favorite_count'] ?? 0;
      appShareCount.value   = stats['app_share_count']   ?? 0;
      appCommentCount.value = stats['app_comment_count'] ?? 0;
    } catch (_) {} finally {
      if (showInitialLoader) isInitialStatsLoading.value = false;
    }
  }

  // ─── Görüntüleme ─────────────────────────────────────────────────────────

  Future<void> _recordView() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;
    try {
      await _supabase.recordView(userId, currentVideo!.videoId);
    } catch (_) {}
  }

  // ─── Beğeni ──────────────────────────────────────────────────────────────

  Future<void> checkLike() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;
    try {
      isLiked.value = await _supabase.isLiked(userId, currentVideo!.videoId);
    } catch (_) {}
  }

  Future<void> toggleLike() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) { _showAuthDialog(); return; }
    if (isLikeLoading.value) return;

    isLikeLoading.value = true;
    // Optimistic update — ikon anında değişir
    final wasLiked = isLiked.value;
    isLiked.value = !wasLiked;
    appLikeCount.value += wasLiked ? -1 : 1;

    try {
      if (wasLiked) {
        await _supabase.removeLike(userId, currentVideo!.videoId);
      } else {
        await _supabase.addLike(userId, currentVideo!.videoId);
      }
      // Gerçek sayıyı sessizce senkronize et
      final stats = await _supabase.getEngagementStats(currentVideo!.videoId);
      appLikeCount.value = stats['app_like_count'] ?? appLikeCount.value;
    } catch (e) {
      // Hata olursa geri al
      isLiked.value = wasLiked;
      appLikeCount.value += wasLiked ? 1 : -1;
      log('toggleLike error: $e');
    } finally {
      isLikeLoading.value = false;
    }
  }

  // ─── Favori ──────────────────────────────────────────────────────────────

  Future<void> checkFavorite() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;
    try {
      final ids = await favoritesRepository.getFavoriteVideoIds(userId);
      isFavorite.value = ids.contains(currentVideo!.videoId);
    } catch (_) {}
  }

  Future<void> toggleFavorite() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) { _showAuthDialog(); return; }
    if (isFavoriteLoading.value) return;

    isFavoriteLoading.value = true;
    final wasAdding = !isFavorite.value;
    // Optimistic
    isFavorite.value = wasAdding;
    appFavoriteCount.value += wasAdding ? 1 : -1;

    try {
      if (!wasAdding) {
        await favoritesRepository.removeFavorite(userId, currentVideo!.videoId);
        await favoritesRepository.removeFavoriteVideoLocally(currentVideo!.videoId);
      } else {
        await favoritesRepository.addFavorite(userId, currentVideo!.videoId);
        await favoritesRepository.saveFavoriteVideoLocally(currentVideo!);
      }
      // HomeController / FavoritesController senkronizasyonu
      if (Get.isRegistered<HomeController>()) {
        final hc = Get.find<HomeController>();
        if (wasAdding) hc.favoriteIds.add(currentVideo!.videoId);
        else hc.favoriteIds.remove(currentVideo!.videoId);
      }
      if (Get.isRegistered<FavoritesController>()) {
        final fc = Get.find<FavoritesController>();
        if (wasAdding) fc.favoriteVideos.insert(0, currentVideo!);
        else fc.favoriteVideos.removeWhere((v) => v.videoId == currentVideo!.videoId);
      }
      // Gerçek sayı senkronizasyonu
      final stats = await _supabase.getEngagementStats(currentVideo!.videoId);
      appFavoriteCount.value = stats['app_favorite_count'] ?? appFavoriteCount.value;
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
    if (isShareLoading.value) return;
    final videoUrl = 'https://www.youtube.com/watch?v=${currentVideo!.videoId}';
    final text = '${currentVideo!.title}\n$videoUrl';

    try {
      await Share.share(text, subject: currentVideo!.title);
      // Paylaşım başarılıysa kaydet
      final userId = _supabase.currentUser?.id;
      if (userId != null) {
        isShareLoading.value = true;
        await _supabase.recordShare(userId, currentVideo!.videoId);
        final stats = await _supabase.getEngagementStats(currentVideo!.videoId);
        appShareCount.value = stats['app_share_count'] ?? appShareCount.value;
      }
    } catch (_) {
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
    try {
      isCommentsLoading.value = true;
      comments.value = await commentRepository.getComments(currentVideo!.videoId);
    } catch (_) {} finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> addComment(String content) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) { _showAuthDialog(); return; }
    if (content.trim().isEmpty) return;
    try {
      await commentRepository.addComment(
        userId: userId,
        videoId: currentVideo!.videoId,
        content: content.trim(),
      );
      await loadComments();
      // Sadece yorum sayısını güncelle
      final stats = await _supabase.getEngagementStats(currentVideo!.videoId);
      appCommentCount.value = stats['app_comment_count'] ?? appCommentCount.value;
    } catch (_) {}
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await commentRepository.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);
      final stats = await _supabase.getEngagementStats(currentVideo!.videoId);
      appCommentCount.value = stats['app_comment_count'] ?? appCommentCount.value;

      // Bu kullanicinin bu videoya baska yorumu kalmadiysa
      // ProfileController.commentedVideos'tan da cikar.
      if (Get.isRegistered<ProfileController>()) {
        final userId = _supabase.currentUser?.id;
        final hasMoreComments = comments.any((c) => c.userId == userId);
        if (!hasMoreComments) {
          Get.find<ProfileController>()
              .commentedVideos
              .removeWhere((v) => v.videoId == currentVideo!.videoId);
        }
      }
    } catch (_) {}
  }

  // ─── Auth Dialog ─────────────────────────────────────────────────────────

  void _showAuthDialog() {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Giriş Gerekiyor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: const Text(
        'Bu özelliği kullanmak için giriş yapmanız gerekiyor.',
        style: TextStyle(color: Color(0xFF9E9EB8)),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Vazgeç', style: TextStyle(color: Color(0xFF9E9EB8))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () { Get.back(); Get.toNamed('/login'); },
          child: const Text('Giriş Yap'),
        ),
      ],
    ));
  }

  @override
  void onClose() {
    youtubeController.dispose();
    super.onClose();
  }
}