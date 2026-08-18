import 'dart:developer';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../core/utils/share_helper.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/engagement_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/watch_progress_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/comment_model.dart';
import '../../services/analytics_service.dart';
import 'settings_controller.dart';

import 'home_controller.dart';

class PlayerController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final CommentRepository commentRepository;
  final EngagementRepository engagementRepository;
  final AuthRepository authRepository;
  final VideoRepository videoRepository; // ← YENİ
  final WatchProgressRepository
  watchProgressRepository; // ← YENİ: İzlemeye Devam Et

  PlayerController({
    required this.favoritesRepository,
    required this.commentRepository,
    required this.engagementRepository,
    required this.authRepository,
    required this.videoRepository, // ← YENİ
    required this.watchProgressRepository, // ← YENİ
  });

  YoutubePlayerController? youtubeController;
  final comments = <CommentModel>[].obs;

  final isFavorite = false.obs;
  final isLiked = false.obs;
  final isPlayerReady = false.obs;
  final isCommentsLoading = false.obs;

  // BUG FIX: youtube_player_iframe paketi, WebView içindeki YouTube iframe'i
  // 30 saniye içinde hazır olmazsa kendi içinde bir TimeoutException
  // fırlatıyor (js_bridge.dart) ve bu bizim try-catch'imizin dışında kalıp
  // "fatal" bir çökme gibi görünüyor. Kullanıcıyı 30 saniye boyunca boş bir
  // ekranda bırakmamak için kendi kısa süreli (12sn) bekleyişimizi ekliyoruz:
  // bu süre içinde player hazır olmazsa kullanıcıya "video açılamadı, tekrar
  // dene" ekranı gösterilir.
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
  // Bu ekranda (player açıkken) net eklenen/silinen yorum sayısı.
  // Ana sayfaya dönerken HomeController'a bildirip kart üzerindeki
  // yorum sayısını like/fav/görüntülenme ile aynı şekilde senkron tutmak için.
  int _commentCountDeltaThisSession = 0;
  // Bu ekranda net paylaşılan video sayısı — yorum sayacıyla aynı
  // gerekçeyle: onClose'da HomeController'a bildirilecek.
  int _shareCountDeltaThisSession = 0;
  final isInitialStatsLoading = true.obs;

  final showAuthRequired = false.obs;
  final snackbarMessage = RxnString();

  final suggestedVideos = <VideoModel>[].obs;
  final isSuggestedLoading = false.obs;

  final currentVideo = Rxn<VideoModel>();
  String? get currentUserId => authRepository.currentUserId;

  // ─── İzlemeye Devam Et (Continue Watching) — TAMAMEN LOCAL ───────────────
  Timer? _progressTimer;
  int _lastPositionSeconds = 0;
  int _lastDurationSeconds = 0;
  bool _firstProgressSaveDone = false;
  DateTime? _lastProgressPersistAt;
  static const _progressPersistInterval = Duration(seconds: 3);
  // BUG FIX: autoPlay varsayılan olarak açık olduğundan, kullanıcı oynat
  // tuşuna hiç basmadan videoya girip anında geri çıksa bile video otomatik
  // oynamaya başlıyor ve saniyeler ilerliyordu. Eşik 1 saniyeyken bu, gerçekte
  // hiç izlenmemiş videoların bile "İzlemeye Devam Et" listesine düşmesine
  // sebep oluyordu. Artık ilk kayıt için en az bu kadar saniye izlenmiş
  // olması gerekiyor — anlık girip-çıkmalar artık kayıt oluşturmuyor, ama
  // gerçekten birkaç saniye izleyen kullanıcı için liste yine çalışıyor.
  static const _minSecondsForFirstSave = 5;

  @override
  void onInit() {
    super.onInit();
    final argVideo = Get.arguments as VideoModel?;

    if (argVideo != null) {
      // Normal navigasyon (video kartı, arama, bildirim vb.) — elimizde
      // zaten tam bir VideoModel var, direkt player'ı başlat.
      currentVideo.value = argVideo;
      _startPlayerFlow();
      return;
    }

    // BUG FIX: Deep link ile (bkz. deep_link_service.dart) buraya
    // gelindiğinde Get.arguments HER ZAMAN null'dır — sadece route
    // parametresi olarak videoId taşınır (Get.toNamed(..., parameters:
    // {'videoId': videoId})). Önceden bu durumda currentVideo.value hep
    // null kalıyor, if bloğuna hiç girilmediği için _initPlayer() asla
    // çağrılmıyor ve isPlayerReady sonsuza kadar false kalıyordu — kullanıcı
    // player ekranında sonsuz bir yüklenme (CircularProgressIndicator)
    // görüyordu. Artık bu durumda videoId ile Supabase'ten tam VideoModel'i
    // ayrıca çekip öyle başlatıyoruz.
    final deepLinkVideoId = Get.parameters['videoId'];
    if (deepLinkVideoId != null && deepLinkVideoId.isNotEmpty) {
      _loadVideoByIdAndStart(deepLinkVideoId);
    }
  }

  /// Sadece videoId elimizdeyken (deep link senaryosu) tam VideoModel'i
  /// Supabase'ten çekip player akışını başlatır. Video bulunamazsa veya
  /// çekilirken hata olursa kullanıcıyı sonsuz spinner'da bırakmamak için
  /// hasPlayerError tetiklenir.
  Future<void> _loadVideoByIdAndStart(String videoId) async {
    try {
      final video = await videoRepository.getVideoById(videoId);
      if (video == null) {
        hasPlayerError.value = true;
        return;
      }
      currentVideo.value = video;
      _startPlayerFlow();
    } catch (e, stacktrace) {
      hasPlayerError.value = true;
      log(
        'Deep link videosu yüklenirken hata oluştu ($videoId): $e',
        error: e,
        stackTrace: stacktrace,
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

      // Analytics: video_play — recordView() sadece giriş yapmış kullanıcılar
      // için Supabase'e yazıldığından, misafir izlemelerini de yakalamak için
      // burada auth durumundan bağımsız ayrı bir event gönderiyoruz.
      AnalyticsService.instance.logVideoPlay(
        videoId: currentVideo.value!.videoId,
        title: currentVideo.value!.title,
      );

      // İzlemeye Devam Et: kaldığı yerden devam ettir + izleme takibini başlat.
      await _restoreSavedProgress();
      _startProgressTracking();
    });
  }

  // ─── İzlemeye Devam Et — Kaldığı Yerden Başlatma ─────────────────────────
  Future<void> _restoreSavedProgress() async {
    try {
      if (currentVideo.value == null || youtubeController == null) return;
      if (currentVideo.value!.isLiveBroadcast) return;

      final saved = await watchProgressRepository.getProgress(
        currentVideo.value!.videoId,
      );
      if (saved == null) return;
      if (saved.isNearlyFinished) return;
      if (saved.positionSeconds < 2) {
        return; // çok az izlenmişse baştan başlasın
      }

      // BUG FIX: _initPlayer() tamamlandığında YoutubePlayerController
      // sadece OLUŞTURULMUŞ olur; YouTube iframe'i videoyu henüz yüklemiş
      // (hazır) olmayabilir. Bu durumda seekTo() komutu çok erken gönderilip
      // sessizce yok sayılıyor ve video baştan oynamaya devam ediyordu.
      // Bu yüzden gerçekten hazır olana (duration okunabilir hale gelene)
      // kadar kısa aralıklarla bekliyoruz, ancak sonsuz beklememesi için
      // bir üst sınır koyuyoruz.
      final isReady = await _waitUntilPlayerReady();
      if (!isReady || youtubeController == null) return;

      await youtubeController!.seekTo(
        seconds: saved.positionSeconds.toDouble(),
        allowSeekAhead: true,
      );

      _lastPositionSeconds = saved.positionSeconds;
      _lastDurationSeconds = saved.durationSeconds;
    } catch (e, stacktrace) {
      log(
        'Kaydedilen izleme ilerlemesi geri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  /// YouTube iframe'i gerçekten videoyu yükleyip `duration` bilgisini
  /// dönebilir hale gelene kadar bekler (en fazla ~6 saniye dener).
  /// Player henüz metadata döndürmüyorsa `duration` 0 veya hata gelir.
  Future<bool> _waitUntilPlayerReady() async {
    for (var attempt = 0; attempt < 24; attempt++) {
      if (youtubeController == null) return false;
      try {
        final dur = await youtubeController!.duration;
        if (dur > 0) return true;
      } catch (_) {
        // Henüz hazır değil, tekrar dene.
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }

  // ─── İzlemeye Devam Et — İzleme Takibi ───────────────────────────────────
  // Video oynatılırken periyodik olarak konum/süre okunur ve yerel olarak
  // kaydedilir. Kullanıcı videoyu 1 saniye bile izlese (ilk tik'te) hemen
  // "İzlemeye Devam Et" listesine düşer; sonrasında izlemeye devam ettikçe
  // (tekrar açıp bitirmeden çıksa da) kayıt her seferinde güncellenir.
  void _startProgressTracking() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (youtubeController == null || currentVideo.value == null) return;
      if (currentVideo.value!.isLiveBroadcast) return;
      try {
        final dur = await youtubeController!.duration;
        final cur = await youtubeController!.currentTime;
        if (dur <= 0) return;

        _lastPositionSeconds = cur.round();
        _lastDurationSeconds = dur.round();

        final now = DateTime.now();
        final isFirstSave =
            !_firstProgressSaveDone &&
            _lastPositionSeconds >= _minSecondsForFirstSave;
        final intervalPassed =
            _lastProgressPersistAt == null ||
            now.difference(_lastProgressPersistAt!) >= _progressPersistInterval;

        if (isFirstSave || (intervalPassed && _firstProgressSaveDone)) {
          await _persistProgress();
          _firstProgressSaveDone = true;
          _lastProgressPersistAt = now;
        }
      } catch (_) {
        // Player henüz hazır değilse sessizce geç, bir sonraki tik'te dene.
      }
    });
  }

  Future<void> _persistProgress() async {
    if (currentVideo.value == null) return;
    if (_lastDurationSeconds <= 0) return;
    await watchProgressRepository.saveProgress(
      video: currentVideo.value!,
      positionSeconds: _lastPositionSeconds,
      durationSeconds: _lastDurationSeconds,
    );
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

  /// Player, kendi içindeki 30sn'lik paket zaman aşımından ÖNCE, daha kısa
  /// bir sürede (12sn) hazır olmazsa kullanıcıya "video açılamadı" durumunu
  /// gösterir. Player normal şekilde hazır olursa onInit() içindeki
  /// `_initWatchdog?.cancel()` bu timer'ı zaten iptal eder.
  void _startInitWatchdog() {
    _initWatchdog?.cancel();
    hasPlayerError.value = false;
    _initWatchdog = Timer(_playerInitWatchdogDuration, () {
      if (!isPlayerReady.value) {
        hasPlayerError.value = true;
        AnalyticsService.instance.recordError(
          TimeoutException(
            'YouTube player $_playerInitWatchdogDuration içinde hazır olmadı (watchdog)',
          ),
          StackTrace.current,
          reason: 'youtube_player_init_watchdog',
        );
      }
    });
  }

  /// Kullanıcı "tekrar dene" butonuna bastığında çağrılır: eski controller'ı
  /// temizler, hata durumunu sıfırlar ve player'ı yeniden başlatmayı dener.
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
      await _restoreSavedProgress();
      _startProgressTracking();
    } else {
      hasPlayerError.value = true;
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
      AnalyticsService.instance.recordError(
        e,
        stacktrace,
        reason: 'player_init_failed',
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
        video: currentVideo.value,
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
      AnalyticsService.instance.logEvent(
        'auth_wall_hit',
        parameters: {'action': 'like'},
      );
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
      // OPTİMİZASYON: getEngagementStats() çağrısı kaldırıldı.
      // appLikeCount zaten yukarıda optimistic olarak güncellendi — doğru delta kesin.
      AnalyticsService.instance.logEvent(
        wasLiked ? 'video_unlike' : 'video_like',
        parameters: {'video_id': currentVideo.value!.videoId},
      );
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
      AnalyticsService.instance.logEvent(
        'auth_wall_hit',
        parameters: {'action': 'favorite'},
      );
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
      AnalyticsService.instance.logFavorite(
        videoId: currentVideo.value!.videoId,
        added: wasAdding,
      );
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

    // Web fallback linki: paylaşım başarısız olup panoya kopyalama
    // gerekirse (aşağıdaki catch bloğu) kullanılıyor, çünkü panoya
    // kopyalanan içerik uygulaması olmayan biri için de çalışmalı.
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
        // OPTİMİZASYON: getEngagementStats() kaldırıldı — optimistic güncelleme yeterli.
        appShareCount.value += 1;
        _shareCountDeltaThisSession += 1;
      }
      AnalyticsService.instance.logShare(
        videoId: currentVideo.value!.videoId,
        method: 'share_sheet',
      );
    } catch (e, stacktrace) {
      log(
        'Video paylaşılırken hata oluştu, panoya kopyalanıyor: $e',
        error: e,
        stackTrace: stacktrace,
      );
      await Clipboard.setData(ClipboardData(text: videoUrl));
      snackbarMessage.value = 'Video bağlantısı panoya kopyalandı.';
      AnalyticsService.instance.logShare(
        videoId: currentVideo.value!.videoId,
        method: 'clipboard_fallback',
      );
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
      AnalyticsService.instance.logEvent(
        'auth_wall_hit',
        parameters: {'action': 'comment'},
      );
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
      _commentCountDeltaThisSession += 1;
      AnalyticsService.instance.logEvent(
        'comment_add',
        parameters: {'video_id': currentVideo.value!.videoId},
      );
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
      _commentCountDeltaThisSession -= 1;
    } catch (e, stacktrace) {
      log('Yorum silinirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  @override
  void onClose() {
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

    // İzlemeye Devam Et: kullanıcı videoyu bitirmeden ekrandan çıkıyor —
    // en son bilinen konumu (cached, controller'a async gitmeden) kaydet.
    // Timer henüz iptal edilmeden önce, en güncel değerleri yakalamak için
    // fire-and-forget bir final persist yapılır.
    //
    // BUG FIX: Eğer ticker'da hiç ilk kayıt yapılmadıysa (kullanıcı eşiğe
    // ulaşmadan çıktıysa) burada da YENİ bir kayıt OLUŞTURULMAMALI —
    // aksi halde "oynat tuşuna basmadan hemen geri dön" senaryosunda video
    // yine de listeye düşer. Zaten var olan bir kaydı güncellemek serbest.
    _progressTimer?.cancel();
    _initWatchdog?.cancel();
    final shouldPersistOnClose =
        _firstProgressSaveDone ||
        _lastPositionSeconds >= _minSecondsForFirstSave;
    if (currentVideo.value != null &&
        _lastDurationSeconds > 0 &&
        shouldPersistOnClose) {
      // Not: onClose senkron olduğundan await edilemez; ancak repository
      // çağrısı Hive'a yazmayı hemen kuyruğa alır, youtubeController.close()
      // ile yarışmaz çünkü zaten cache'lenmiş (senkron okunmuş) değerleri kullanır.
      unawaited(
        watchProgressRepository.saveProgress(
          video: currentVideo.value!,
          positionSeconds: _lastPositionSeconds,
          durationSeconds: _lastDurationSeconds,
        ),
      );
    }

    youtubeController?.close();
    super.onClose();
  }
}