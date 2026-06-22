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

import 'home_controller.dart';

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
    try {
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
    } catch (e, stacktrace) {
      log(
        'Player başlangıç durumu yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // DÜZELTİLDİ: HomeController'a bağımlılık yok, doğrudan repository'den kontrol
  void _resolveIsFavoriteFromCache() {
    try {
      if (currentVideo.value == null) return;
      final videoId = currentVideo.value!.videoId;

      favoritesRepository
          .getFavoriteVideos()
          .then((locals) {
            isFavorite.value = locals.any((v) => v.videoId == videoId);
          })
          .catchError((e, stacktrace) {
            log(
              'Favori durumu cache\'den kontrol edilirken hata oluştu: $e',
              error: e,
              stackTrace: stacktrace,
            );
          });
    } catch (e, stacktrace) {
      log(
        'Favori durumu çözümlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // lib/presentation/controllers/player_controller.dart — _initPlayer düzeltmesi
  Future<void> _initPlayer() async {
    try {
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
    } catch (e, stacktrace) {
      log(
        'Player başlatılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
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
    } catch (e, stacktrace) {
      log(
        'Etkileşim istatistikleri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    } finally {
      if (showInitialLoader) isInitialStatsLoading.value = false;
    }
  }

  // ─── Görüntüleme ─────────────────────────────────────────────────────────

  // FIX: appViewCount eskiden sadece _loadEngagementStats() ile sunucudan
  // okunuyordu. Diğer tüm sayaçlar (beğeni, favori, paylaşım, yorum) optimistic
  // güncelleniyordu ama bu unutulmuştu — bu yüzden kullanıcı videoyu izlediğinde
  // kendi izlemesini anında görmüyordu. recordView gerçekten YENİ bir izleyici
  // kaydı oluşturduysa (isNewView = true) sayaç hemen +1 artar. Aynı videoyu
  // tekrar izlemek (unique constraint sayesinde satır eklemez) artık sayacı
  // şişirmiyor — önceden her izlemede +1 yapılıyordu, bu da gerçek sunucu
  // sayısıyla (10 dk'lık cron yenilemesinde) çakışıp ekranda sayının "düşmüş"
  // gibi görünmesine sebep oluyordu.
  Future<void> _recordView() async {
    if (currentVideo.value == null) return;
    final userId = currentUserId;
    if (userId == null) return;
    try {
      final isNewView = await engagementRepository.recordView(
        userId,
        currentVideo.value!.videoId,
      );
      if (isNewView) appViewCount.value += 1;
    } catch (e, stacktrace) {
      log(
        'Görüntülenme kaydedilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log(
        'Önerilen videolar yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log(
        'Beğeni durumu kontrol edilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      isLiked.value = wasLiked;
      appLikeCount.value += wasLiked ? 1 : -1;
      log(
        'Beğeni toggle işlemi sırasında hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      isFavorite.value = !wasAdding;
      appFavoriteCount.value += wasAdding ? -1 : 1;
      log(
        'Favori toggle işlemi sırasında hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log(
        'Video paylaşılırken hata oluştu, panoya kopyalanıyor: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log(
        'Yorumlar yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log('Yorum eklenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  Future<void> deleteComment(String commentId) async {
    if (currentVideo.value == null) return;
    try {
      await commentRepository.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);
      // OPTİMİZASYON: getEngagementStats() kaldırıldı — optimistic azalt.
      if (appCommentCount.value > 0) appCommentCount.value -= 1;
    } catch (e, stacktrace) {
      log('Yorum silinirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  @override
  void onClose() {
    // PlayerController kapanırken HomeController'ı senkronize et.
    // Kullanıcı player'dan beğenip geri döndüğünde ana sayfadaki
    // kart durumu ve sayacı doğru yansısın.
    try {
      if (currentVideo.value != null && Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().syncLikeFromPlayer(
          currentVideo.value!.videoId,
          isLiked.value,
        );
      }
    } catch (_) {}
    youtubeController?.close();
    super.onClose();
  }
}