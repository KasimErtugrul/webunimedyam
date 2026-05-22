// lib/presentation/screens/video_section_detail/video_section_detail_controller.dart

import 'dart:developer';

import 'package:get/get.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/models/video_engagement_model.dart';

export '../../data/repositories/video_repository.dart' show VideoSectionType;

class VideoSectionDetailController extends GetxController {
  final VideoRepository videoRepository;

  VideoSectionDetailController({required this.videoRepository});

  late VideoSectionType sectionType;
  late String sectionTitle;

  final items = <VideoEngagementModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  static const int _pageSize = 10;
  int _currentOffset = 0;

  // FIX: Ekrandan çıkıp geri dönünce sayfalar bellekte kalır — gereksiz
  // ağ isteği yapılmaz. Sadece pull-to-refresh tam sıfırlama yapar.
  final _pageCache = <int, List<VideoEngagementModel>>{};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    sectionType = args['type'] as VideoSectionType;
    sectionTitle = args['title'] as String;
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    _currentOffset = 0;
    hasMore.value = true;
    items.clear();
    _pageCache.clear();
    await _fetchPage();
  }

  Future<void> loadNextPage() async {
    if (isLoadingMore.value || !hasMore.value) return;
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    try {
      final isFirst = _currentOffset == 0;
      if (isFirst) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      // FIX: Daha önce yüklenen sayfa bellekte varsa tekrar istek atma.
      List<VideoEngagementModel> result;
      if (_pageCache.containsKey(_currentOffset)) {
        result = _pageCache[_currentOffset]!;
       // log('SECTION_DETAIL CACHE HIT: offset=$_currentOffset');
      } else {
        result = await videoRepository.getVideoSectionPage(
          sectionType: sectionType,
          offset: _currentOffset,
          limit: _pageSize,
        );
        _pageCache[_currentOffset] = result;
      }

      if (result.length < _pageSize) {
        hasMore.value = false;
      }

      items.addAll(result);
      _currentOffset += result.length;
    } catch (e) {
      log('VideoSectionDetailController._fetchPage error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
}
