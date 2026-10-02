// lib/presentation/controllers/video_viewers_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import '../../data/models/video_viewer_model.dart';
import '../../data/repositories/engagement_repository.dart';

class VideoViewersController extends GetxController {
  final EngagementRepository engagementRepository;
  final String videoId;
  final int totalViewCount; // PlayerController'dan gelen görüntülenme sayısı

  VideoViewersController({
    required this.engagementRepository,
    required this.videoId,
    required this.totalViewCount,
  });

  static const int _pageSize = 10;

  final viewers = <VideoViewerModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final publicCount = 0.obs; // watch_history_visibility = public olan sayısı
  final hiddenCount = 0.obs; // gizleyen kullanıcı sayısı
  final errorMessage = RxnString();

  int _offset = 0;

  @override
  void onInit() {
    super.onInit();
    // Bu ekranın (izleyici listesi) hiç kullanılıp kullanılmadığını ölçmek
    // için — niş bir özellik, açılma sıklığı ürün kararı için değerli.

    loadViewers();
  }

  Future<void> loadViewers() async {
    if (isLoading.value) return;
    _offset = 0;
    isLoading.value = true;
    hasMore.value = true;
    viewers.clear();
    errorMessage.value = null;

    try {
      final result = await engagementRepository.getVideoViewers(
        videoId,
        limit: _pageSize,
        offset: _offset,
      );
      viewers.assignAll(result.viewers);
      publicCount.value = result.totalCount;
      hiddenCount.value = totalViewCount - result.totalCount;
      if (hiddenCount.value < 0) hiddenCount.value = 0;
      _offset = viewers.length;
      hasMore.value = viewers.length == _pageSize;
    } catch (e, stacktrace) {
      log(
        'Video izleyicileri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'İzleyiciler yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    errorMessage.value = null;

    try {
      final result = await engagementRepository.getVideoViewers(
        videoId,
        limit: _pageSize,
        offset: _offset,
      );
      viewers.addAll(result.viewers);
      _offset = viewers.length;
      hasMore.value = result.viewers.length == _pageSize;
    } catch (e, stacktrace) {
      log(
        'Daha fazla izleyici yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Daha fazla izleyici yüklenemedi.';
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> retry() async {
    try {
      errorMessage.value = null;
      if (viewers.isEmpty) {
        await loadViewers();
      } else {
        await loadMore();
      }
    } catch (e, stacktrace) {
      log(
        'Yeniden deneme sırasında hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Yeniden yüklenirken hata oluştu.';
    }
  }
}
