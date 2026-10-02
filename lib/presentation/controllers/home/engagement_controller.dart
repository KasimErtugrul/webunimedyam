import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/share_helper.dart';
import '../../../data/models/video_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../data/repositories/engagement_repository.dart';
import '../../../data/repositories/favorites_repository.dart';
import 'feed_controller.dart';

/// Kullanıcının video üzerindeki tüm aksiyonları: beğeni, favori, paylaşım,
/// hızlı yorum. Feed sayaçlarını FeedController üzerinden günceller.
class EngagementController extends GetxController {
  EngagementController({
    required this.engagementRepository,
    required this.favoritesRepository,
    required this.commentRepository,
    required this.authRepository,
  });

  final EngagementRepository engagementRepository;
  final FavoritesRepository favoritesRepository;
  final CommentRepository commentRepository;
  final AuthRepository authRepository;

  final favoriteIds = <String>[].obs;
  final showAuthRequired = false.obs;

  final _sharedIds = <String>[].obs;
  final _commentedIds = <String>[].obs;
  final _likedIds = <String>[].obs;
  final _likeLoadingIds = <String>[].obs;
  final _shareLoadingIds = <String>[].obs;

  final _likeCache = <String, bool>{};
  final _likeCacheLoading = <String>{};
  final _likeProcessing = <String>{};
  final _shareProcessing = <String>{};

  final _quickCommentBumps = <String, int>{}.obs;
  final _quickCommentSendingIds = <String>{}.obs;

  late final StreamSubscription<FavoriteChange> _favoriteSub;

  // Public getters (Obx uyumu için)
  RxList<String> get likedVideoIds => _likedIds;
  RxList<String> get likeLoadingVideoIds => _likeLoadingIds;
  RxList<String> get shareLoadingVideoIds => _shareLoadingIds;
  RxList<String> get sharedVideoIds => _sharedIds;
  RxList<String> get commentedVideoIds => _commentedIds;
  RxMap<String, int> get quickCommentBumps => _quickCommentBumps;
  RxSet<String> get quickCommentSendingIds => _quickCommentSendingIds;

  int get likedIdsCount => _likedIds.length;
  int extraCommentCountFor(String videoId) => _quickCommentBumps[videoId] ?? 0;

  String? get _currentUserId => authRepository.currentUserId;

  @override
  void onInit() {
    super.onInit();
    _favoriteSub = favoritesRepository.onFavoriteChanged.listen(
      _onFavoriteChanged,
    );
  }

  @override
  void onClose() {
    _favoriteSub.cancel();
    super.onClose();
  }

  void _onFavoriteChanged(FavoriteChange event) {
    final wasFav = favoriteIds.contains(event.videoId);
    if (event.isFavorite && !wasFav) {
      _updateFeedFavoriteCount(event.videoId, 1);
      favoriteIds.add(event.videoId);
    } else if (!event.isFavorite && wasFav) {
      _updateFeedFavoriteCount(event.videoId, -1);
      favoriteIds.remove(event.videoId);
    }
  }

  // ─── Feed sayaç köprüsü ─────────────────────────────────────────────────

  void _updateFeedLikeCount(String id, int delta) {
    if (Get.isRegistered<FeedController>()) {
      Get.find<FeedController>().updateLikeCount(id, delta);
    }
  }

  void _updateFeedFavoriteCount(String id, int delta) {
    if (Get.isRegistered<FeedController>()) {
      Get.find<FeedController>().updateFavoriteCount(id, delta);
    }
  }

  void _updateFeedShareCount(String id, int delta) {
    if (Get.isRegistered<FeedController>()) {
      Get.find<FeedController>().updateShareCount(id, delta);
    }
  }

  // ─── Favori ─────────────────────────────────────────────────────────────

  bool isFavorite(String videoId) => favoriteIds.contains(videoId);

  Future<void> loadFavorites() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      favoriteIds.value = await favoritesRepository.getFavoriteVideoIds(userId);
    } catch (e, st) {
      log('Favoriler yüklenirken hata oluştu: $e', error: e, stackTrace: st);
    }
  }

  Future<void> toggleFavorite(String videoId) async {
    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;

      return;
    }

    final wasFav = isFavorite(videoId);
    if (wasFav) {
      favoriteIds.remove(videoId);
    } else {
      favoriteIds.add(videoId);
    }
    _updateFeedFavoriteCount(videoId, wasFav ? -1 : 1);

    try {
      if (wasFav) {
        await favoritesRepository.removeFavorite(userId, videoId);
        await favoritesRepository.removeFavoriteVideoLocally(videoId);
      } else {
        await favoritesRepository.addFavorite(userId, videoId);
        final video = Get.isRegistered<FeedController>()
            ? Get.find<FeedController>().videos.firstWhereOrNull(
                (v) => v.videoId == videoId,
              )
            : null;
        if (video != null) {
          await favoritesRepository.saveFavoriteVideoLocally(video);
        }
      }
    } catch (e, st) {
      if (wasFav) {
        favoriteIds.add(videoId);
      } else {
        favoriteIds.remove(videoId);
      }
      _updateFeedFavoriteCount(videoId, wasFav ? 1 : -1);
      log(
        'Favori durumu değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: st,
      );
    }
  }

  void syncFavoriteFromPlayer(String videoId, bool isNowFav) {
    final wasFav = favoriteIds.contains(videoId);
    if (wasFav == isNowFav) return;
    _updateFeedFavoriteCount(videoId, isNowFav ? 1 : -1);
    if (isNowFav) {
      favoriteIds.add(videoId);
    } else {
      favoriteIds.remove(videoId);
    }
  }

  // ─── Beğeni ─────────────────────────────────────────────────────────────

  bool isLiked(String videoId) => _likedIds.contains(videoId);
  bool isLikeLoading(String videoId) => _likeLoadingIds.contains(videoId);
  bool isShareLoading(String videoId) => _shareLoadingIds.contains(videoId);

  Future<void> loadLikedVideoIds() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final ids = await engagementRepository.getLikedVideoIds(userId);
      _likedIds.assignAll(ids);
      for (final id in ids) {
        _likeCache[id] = true;
      }
    } catch (e, st) {
      log(
        'Beğenilen video ID\'leri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: st,
      );
    }
  }

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
      _updateFeedLikeCount(videoId, wasLiked ? -1 : 1);

      try {
        if (wasLiked) {
          await engagementRepository.removeLike(userId, videoId);
        } else {
          await engagementRepository.addLike(userId, videoId);
        }
      } catch (e, st) {
        _likeCache[videoId] = wasLiked;
        if (wasLiked) {
          _likedIds.add(videoId);
        } else {
          _likedIds.remove(videoId);
        }
        _updateFeedLikeCount(videoId, wasLiked ? 1 : -1);
        log('Beğeni toggle yazma hatası: $e', error: e, stackTrace: st);
      }
    } finally {
      _likeLoadingIds.remove(videoId);
      _likeProcessing.remove(videoId);
    }
  }

  void syncLikeFromPlayer(String videoId, bool isNowLiked) {
    final wasLiked = _likeCache[videoId] ?? _likedIds.contains(videoId);
    if (wasLiked == isNowLiked) return;

    _likeCache[videoId] = isNowLiked;
    _updateFeedLikeCount(videoId, isNowLiked ? 1 : -1);
    if (isNowLiked) {
      if (!_likedIds.contains(videoId)) _likedIds.add(videoId);
    } else {
      _likedIds.remove(videoId);
    }
  }

  // ─── Paylaşım ───────────────────────────────────────────────────────────

  Future<void> loadSharedVideoIds() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final ids = await engagementRepository.getSharedVideoIds(userId);
      _sharedIds.assignAll(ids);
    } catch (e, st) {
      log(
        'Paylaşılan video ID\'leri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> shareVideo(VideoModel video) async {
    if (_shareProcessing.contains(video.videoId)) return;
    _shareProcessing.add(video.videoId);
    _shareLoadingIds.add(video.videoId);

    final videoUrl = ShareHelper.buildWebFallback(video.videoId);

    try {
      await ShareHelper.shareVideo(
        videoId: video.videoId,
        title: video.title,
        universityName: video.universityName,
        thumbnailUrl: video.bestThumbnail,
      );
      final userId = _currentUserId;
      if (userId != null) {
        await engagementRepository.recordShare(userId, video.videoId);
        if (!_sharedIds.contains(video.videoId)) {
          _sharedIds.add(video.videoId);
          _updateFeedShareCount(video.videoId, 1);
        }
      }
    } catch (e, st) {
      log(
        'Paylaşım başarısız, panoya kopyalanıyor: $e',
        error: e,
        stackTrace: st,
      );
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

  void syncShareCountFromPlayer(String videoId, int delta) {
    if (delta == 0) return;
    _updateFeedShareCount(videoId, delta);
  }

  // ─── Yorum ──────────────────────────────────────────────────────────────

  Future<void> loadCommentedVideoIds() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final ids = await engagementRepository.getCommentedVideoIds(userId);
      _commentedIds.assignAll(ids);
    } catch (e, st) {
      log(
        'Yorum yapılan video ID\'leri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<bool> sendQuickComment(VideoModel video, String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;

    final userId = _currentUserId;
    if (userId == null) {
      showAuthRequired.value = true;

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

      return true;
    } catch (e, st) {
      log(
        'Hızlı yorum gönderilirken hata oluştu: $e',
        error: e,
        stackTrace: st,
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

  void syncCommentCountFromPlayer(String videoId, int delta) {
    if (delta == 0) return;
    final current = _quickCommentBumps[videoId] ?? 0;
    _quickCommentBumps[videoId] = current + delta;
  }
}
