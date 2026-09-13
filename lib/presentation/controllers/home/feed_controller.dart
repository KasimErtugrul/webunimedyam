import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';

import '../../../data/models/university_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/models/watch_progress_model.dart';
import '../../../data/repositories/video_repository.dart';
import '../../../data/repositories/watch_progress_repository.dart';
import 'discovery_controller.dart';

/// Ana feed + sayfalama + üniversite filtresi + "İzlemeye Devam Et".
class FeedController extends GetxController {
  FeedController({
    required this.videoRepository,
    required this.watchProgressRepository,
  });

  final VideoRepository videoRepository;
  final WatchProgressRepository watchProgressRepository;

  static const _pageSize = 10;

  final videos = <VideoModel>[].obs;
  final currentPage = 0.obs;
  final hasMoreVideos = true.obs;
  final isLoadingMore = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedUniversity = Rxn<UniversityModel>();

  /// Global view-count override (VideoCardWidget her yerde kullanabilsin).
  final viewCountOverrides = <String, int>{}.obs;

  /// İzlemeye Devam Et — tamamen local.
  final continueWatching = <WatchProgressModel>[].obs;
  final isContinueWatchingLoading = false.obs;

  late final StreamSubscription<WatchProgressChange> _watchProgressSub;

  @override
  void onInit() {
    super.onInit();
    _watchProgressSub =
        watchProgressRepository.onProgressChanged.listen((_) => loadContinueWatching());
  }

  @override
  void onClose() {
    _watchProgressSub.cancel();
    super.onClose();
  }

  // ─── Feed ────────────────────────────────────────────────────────────────

  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final uni = selectedUniversity.value;

      if (uni != null) {
        videos.value = await videoRepository.getVideosByUniversity(uni.id!);
      } else {
        final firstPage =
            await videoRepository.getLatestVideosPerUniversity(page: 0);
        videos.value = firstPage;
        currentPage.value = 0;
        hasMoreVideos.value = firstPage.length >= _pageSize;
      }
    } catch (e, st) {
      log('Videolar yüklenirken hata oluştu: $e', error: e, stackTrace: st);
      errorMessage.value = 'Videolar yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreVideos() async {
    if (isLoadingMore.value || !hasMoreVideos.value) return;
    if (selectedUniversity.value != null) return;
    try {
      isLoadingMore.value = true;
      final nextPage = currentPage.value + 1;
      final newVideos =
          await videoRepository.getLatestVideosPerUniversity(page: nextPage);
      final existing = videos.map((v) => v.videoId).toSet();
      final unique = newVideos.where((v) => existing.add(v.videoId)).toList();
      videos.addAll(unique);
      currentPage.value = nextPage;
      hasMoreVideos.value = newVideos.length >= _pageSize;
    } catch (e, st) {
      log('Daha fazla video yüklenirken hata oluştu: $e',
          error: e, stackTrace: st);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshVideos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await videoRepository.refreshVideos();
      await loadVideos();
      if (Get.isRegistered<DiscoveryController>()) {
        await Get.find<DiscoveryController>().loadVideoSections();
      }
    } catch (e, st) {
      log('Videolar yenilenirken hata oluştu: $e', error: e, stackTrace: st);
      errorMessage.value = 'Videolar yenilenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectUniversity(UniversityModel? university) async {
    try {
      selectedUniversity.value = university;
      await loadVideos();
    } catch (e, st) {
      log('Üniversite seçilirken hata oluştu: $e', error: e, stackTrace: st);
    }
  }

  // ─── Sayaç güncellemeleri (EngagementController çağırır) ────────────────

  void updateLikeCount(String videoId, int delta) {
    final idx = videos.indexWhere((v) => v.videoId == videoId);
    if (idx == -1) return;
    videos[idx] = videos[idx]
        .copyWith(appLikeCount: (videos[idx].appLikeCount + delta).clamp(0, 999999999));
  }

  void updateFavoriteCount(String videoId, int delta) {
    final idx = videos.indexWhere((v) => v.videoId == videoId);
    if (idx == -1) return;
    videos[idx] = videos[idx].copyWith(
        appFavoriteCount: (videos[idx].appFavoriteCount + delta).clamp(0, 999999999));
  }

  void updateShareCount(String videoId, int delta) {
    final idx = videos.indexWhere((v) => v.videoId == videoId);
    if (idx == -1) return;
    videos[idx] = videos[idx].copyWith(
        appShareCount: (videos[idx].appShareCount + delta).clamp(0, 999999999));
  }

  void updateViewCount(String videoId, int newCount) {
    final idx = videos.indexWhere((v) => v.videoId == videoId);
    if (idx == -1) return;
    if (videos[idx].appViewCount >= newCount) return;
    videos[idx] = videos[idx].copyWith(appViewCount: newCount);
  }

  void syncViewCountFromPlayer(String videoId, int viewCount) {
    final current = viewCountOverrides[videoId] ?? 0;
    if (viewCount > current) {
      viewCountOverrides[videoId] = viewCount;
    }
    updateViewCount(videoId, viewCount);
  }

  // ─── İzlemeye Devam Et ──────────────────────────────────────────────────

  Future<void> loadContinueWatching() async {
    try {
      isContinueWatchingLoading.value = true;
      continueWatching.value =
          await watchProgressRepository.getContinueWatching();
    } catch (e, st) {
      log('İzlemeye devam et listesi yüklenirken hata oluştu: $e',
          error: e, stackTrace: st);
    } finally {
      isContinueWatchingLoading.value = false;
    }
  }

  Future<void> removeFromContinueWatching(String videoId) async {
    final removedIndex =
        continueWatching.indexWhere((w) => w.video.videoId == videoId);
    if (removedIndex == -1) return;
    final removedItem = continueWatching[removedIndex];
    continueWatching.removeAt(removedIndex);
    try {
      await watchProgressRepository.removeProgress(videoId);
    } catch (e, st) {
      continueWatching.insert(removedIndex, removedItem);
      log('İzlemeye devam et kaydı kaldırılırken hata oluştu: $e',
          error: e, stackTrace: st);
    }
  }
}