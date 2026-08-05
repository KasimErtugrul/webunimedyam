// lib/presentation/controllers/university_detail_controller.dart
//
// BUG FIX özeti:
//   1) toggleFavorite() artık addFavorite/removeFavorite'in bool dönüşünü
//      kullanıyor. Hata durumunda snackbar gösteriyor.
//      Önceki kodda repository rethrow yapıyordu; bu controller yakalıyor
//      ama UI mesajı veriyordu. Ancak repository rethrow kaldırıldığından
//      artık bool kontrol edilmeli.
//   2) isFavorite optimistic olarak repository event'inden geliyor
//      (stream listener). toggleFavorite() içinde manuel set() yok;
//      bu hem tutarlı hem de çift kaynak sorununu önlüyor.

import 'dart:developer';
import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/university_model.dart';
import '../../data/models/video_model.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../services/analytics_service.dart';

class UniversityDetailController extends GetxController {
  final VideoRepository videoRepository;
  final UniversityFavoritesRepository universityFavoritesRepository;

  UniversityDetailController({
    required this.videoRepository,
    required this.universityFavoritesRepository,
  });

  final university = Rxn<UniversityModel>();
  final videos = <VideoModel>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMoreVideos = true.obs;
  final errorMessage = ''.obs;

  static const int _pageSize = 10;
  int _offset = 0;

  final isFavorite = false.obs;
  final isFavoriteLoading = false.obs;

  // ─── Canlı Yayınlar ("Canlı" sekmesi) ──────────────────────────────────────
  final liveVideos = <VideoModel>[].obs;
  final isLoadingLive = true.obs;
  final liveErrorMessage = ''.obs;

  late final StreamSubscription<UniversityFavoriteChange> _favSub;

  List<VideoModel> get videoOnly => videos.where((v) => !v.isShorts).toList();
  List<VideoModel> get shortsOnly => videos.where((v) => v.isShorts).toList();

  @override
  void onInit() {
    super.onInit();

    // Favori değişimlerini stream'den dinle — optimistic update buradan geliyor.
    // BUG FIX: isFavorite manuel set edilmiyor; stream tek kaynak.
    _favSub = universityFavoritesRepository.onFavoriteChanged.listen((event) {
      try {
        if (event.universityId == university.value?.id) {
          isFavorite.value = event.isFavorite;
        }
      } catch (e, stacktrace) {
        log(
          'Favori değişikliği işlenirken hata oluştu: $e',
          error: e,
          stackTrace: stacktrace,
        );
      }
    });

    try {
      final args = Get.arguments;
      if (args is UniversityModel) {
        university.value = args;
        _loadFavoriteStatus();
        loadVideos();
        loadLiveVideos();
        AnalyticsService.instance.logEvent(
          'university_view',
          parameters: {
            'university_id': args.id ?? -1,
            'university_name': args.name ?? 'unknown',
          },
        );
      } else if (args is int) {
        _loadUniversityById(args);
      } else {
        errorMessage.value = 'Üniversite bilgisi alınamadı.';
        isLoading.value = false;
      }
    } catch (e, stacktrace) {
      log(
        'UniversityDetail başlatılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Üniversite bilgisi alınamadı.';
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    try {
      _favSub.cancel();
    } catch (e, stacktrace) {
      log(
        'Favori aboneliği iptal edilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
    super.onClose();
  }

  // ─── Yükleme ──────────────────────────────────────────────────────────────

  Future<void> _loadUniversityById(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      university.value = await videoRepository.getUniversityById(id);
      await _loadFavoriteStatus();
      await loadVideos();
      await loadLiveVideos();
      AnalyticsService.instance.logEvent(
        'university_view',
        parameters: {
          'university_id': id,
          'university_name': university.value?.name ?? 'unknown',
        },
      );
    } catch (e, stacktrace) {
      log(
        'Üniversite ID ile yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Üniversite bilgileri yüklenemedi.';
      isLoading.value = false;
    }
  }

  Future<void> loadVideos() async {
    final id = university.value?.id;
    if (id == null) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _offset = 0;
      _autoFillAttempts = 0;
      hasMoreVideos.value = true;
      final result = await videoRepository.getVideosByUniversity(
        id,
        limit: _pageSize,
        offset: _offset,
      );
      videos.value = result;
      _offset = result.length;
      if (result.length < _pageSize) hasMoreVideos.value = false;
    } catch (e, stacktrace) {
      log(
        'Üniversite videoları yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Videolar yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
    // Video/Shorts sekmeleri aynı karışık listeden client-side filtreleniyor.
    // Bir sayfa (10 kayıt) tamamen tek türde gelirse (ör. hepsi shorts),
    // diğer sekme boş/eksik görünür ve liste kısa olduğu için scroll hiç
    // tetiklenmeyip "daha fazla yükle" mekanizması hiç çalışmaz. Bu yüzden
    // her iki filtrelenmiş liste de en az bir sayfa dolana kadar arka planda
    // otomatik olarak ek sayfalar çekiyoruz (sonsuz döngüye karşı sınırlı).
    unawaited(_autoFillIfNeeded());
  }

  /// Sayfalama: her çağrıda 10 video daha çeker ve mevcut listeye ekler.
  Future<void> loadMoreVideos() async {
    final id = university.value?.id;
    if (id == null || isLoadingMore.value || !hasMoreVideos.value) return;
    try {
      isLoadingMore.value = true;
      final result = await videoRepository.getVideosByUniversity(
        id,
        limit: _pageSize,
        offset: _offset,
      );
      if (result.isEmpty) {
        hasMoreVideos.value = false;
      } else {
        videos.addAll(result);
        _offset += result.length;
        if (result.length < _pageSize) hasMoreVideos.value = false;
      }
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

  /// "Canlı" sekmesi için üniversitenin şu an yayında olan videolarını
  /// yükler. `videos` listesinden bağımsızdır — sadece son N video arasında
  /// değil, gerçekten canlı olan tüm yayınları getirir.
  Future<void> loadLiveVideos() async {
    final id = university.value?.id;
    if (id == null) return;
    try {
      isLoadingLive.value = true;
      liveErrorMessage.value = '';
      liveVideos.value = await videoRepository.getLiveVideosByUniversity(id);
    } catch (e, stacktrace) {
      log(
        'Canlı yayınlar yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      liveErrorMessage.value = 'Canlı yayınlar yüklenemedi.';
    } finally {
      isLoadingLive.value = false;
    }
  }

  int _autoFillAttempts = 0;
  static const int _maxAutoFillAttempts = 8;

  /// Video ve Shorts sekmelerinden herhangi biri henüz bir sayfa kadar
  /// (ör. 10) öğeye sahip değilse ve daha fazla veri varsa, kullanıcı hiç
  /// scroll yapmadan da arka planda otomatik olarak sonraki sayfaları çeker.
  /// Sonsuz/aşırı istek atmayı önlemek için deneme sayısı sınırlıdır.
  Future<void> _autoFillIfNeeded() async {
    if (!hasMoreVideos.value || isLoadingMore.value) return;
    if (_autoFillAttempts >= _maxAutoFillAttempts) {
      _autoFillAttempts = 0;
      return;
    }
    final needsMore = videoOnly.length < _pageSize || shortsOnly.length < _pageSize;
    if (!needsMore) {
      _autoFillAttempts = 0;
      return;
    }
    _autoFillAttempts++;
    await loadMoreVideos();
    await _autoFillIfNeeded();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final uniId = university.value?.id;
      if (userId == null || uniId == null) return;
      isFavorite.value = await universityFavoritesRepository
          .isUniversityFavorited(userId, uniId);
    } catch (e, stacktrace) {
      log(
        'Favori durumu yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Favori Toggle ─────────────────────────────────────────────────────────

  /// BUG FIX: addFavorite / removeFavorite artık bool döndürüyor.
  /// Hata durumunda (false) snackbar gösteriliyor.
  /// isFavorite optimistic olarak repository event stream'inden geliyor;
  /// burada manuel set yok — stream tek kaynak of truth.
  Future<void> toggleFavorite() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final uni = university.value;
      if (userId == null || uni?.id == null) {
        Get.snackbar(
          'Giriş Gerekli',
          'Favorilere eklemek için giriş yapmalısınız.',
          snackPosition: SnackPosition.BOTTOM,
        );
        if (userId == null) {
          AnalyticsService.instance.logEvent(
            'auth_wall_hit',
            parameters: {'action': 'university_favorite'},
          );
        }
        return;
      }

      if (isFavoriteLoading.value) return;
      isFavoriteLoading.value = true;

      try {
        bool success;
        if (isFavorite.value) {
          success = await universityFavoritesRepository.removeFavorite(
            userId,
            uni!.id!,
          );
          if (success) {
            Get.snackbar(
              'Favorilerden Çıkarıldı',
              '${uni.name} favorilerden çıkarıldı.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
            AnalyticsService.instance.logEvent(
              'university_unfavorite',
              parameters: {'university_id': uni.id!, 'university_name': uni.name ?? 'unknown'},
            );
          } else {
            Get.snackbar(
              'Hata',
              'İşlem gerçekleştirilemedi. Lütfen tekrar deneyin.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          success = await universityFavoritesRepository.addFavorite(
            userId,
            uni!.id!,
            university: uni,
          );
          if (success) {
            Get.snackbar(
              'Favorilere Eklendi',
              '${uni.name} favorilerinize eklendi.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
            AnalyticsService.instance.logEvent(
              'university_favorite',
              parameters: {'university_id': uni.id!, 'university_name': uni.name ?? 'unknown'},
            );
          } else {
            Get.snackbar(
              'Hata',
              'İşlem gerçekleştirilemedi. Lütfen tekrar deneyin.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      } catch (e, stacktrace) {
        // Repository artık throw etmiyor ama savunmacı olalım
        log(
          'Favori toggle işlemi sırasında beklenmeyen hata: $e',
          error: e,
          stackTrace: stacktrace,
        );
        Get.snackbar(
          'Hata',
          'İşlem gerçekleştirilemedi. Lütfen tekrar deneyin.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isFavoriteLoading.value = false;
      }
    } catch (e, stacktrace) {
      log(
        'Favori toggle işlemi sırasında hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Yardımcı Formatlar ────────────────────────────────────────────────────

  String get formattedSubscriberCount {
    try {
      final count = university.value?.subscriberCount ?? 0;
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1)}M';
      } else if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(0)}K';
      }
      return count.toString();
    } catch (e, stacktrace) {
      log(
        'Abone sayısı formatlanırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return '0';
    }
  }

  String get formattedViewCount {
    try {
      final count = university.value?.viewCount ?? 0;
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1)}M';
      } else if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(0)}K';
      }
      return count.toString();
    } catch (e, stacktrace) {
      log(
        'Görüntülenme sayısı formatlanırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return '0';
    }
  }
}