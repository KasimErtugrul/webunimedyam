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

  // FIX: Pagination sırasında ağ hatası olursa UI'ın haberdar olması için eklendi.
  final errorMessage = RxnString();

  static const int _pageSize = 10;
  int _currentOffset = 0;

  final _pageCache = <int, List<VideoEngagementModel>>{};

  @override
  void onInit() {
    super.onInit();
    try {
      final args = Get.arguments;
      if (args is! Map<String, dynamic>) {
        errorMessage.value = 'Sayfa bilgisi alınamadı.';
        return;
      }
      sectionType = args['type'] as VideoSectionType;
      sectionTitle = args['title'] as String;

      // Hangi kürasyon bölümünün (trend/en çok izlenen/en çok beğenilen vb.)
      // "tümünü gör" ile en çok tıklandığını ölçmek için.

      // BUG FIX / İYİLEŞTİRME: Ana sayfa bu bölümün ilk 10 videosunu zaten
      // çekip bir Rx değişkende tutuyor. "Tümünü Gör"e basıldığında aynı
      // veriyi tekrar API'den istemek yerine initialItems olarak devralıp
      // doğrudan gösteriyoruz; API'ye yalnızca 2. sayfa istendiğinde
      // gidilir. Kanal tab'ındaki UniversityStatsSectionDetailController
      // ile aynı desen.
      final initialItems = args['initialItems'];
      if (initialItems is List<VideoEngagementModel> &&
          initialItems.isNotEmpty) {
        items.assignAll(initialItems);
        _pageCache[0] = initialItems;
        _currentOffset = initialItems.length;
        hasMore.value = initialItems.length >= _pageSize;
        isLoading.value = false;
        return;
      }

      loadFirstPage();
    } catch (e, stacktrace) {
      log(
        'VideoSectionDetailController başlatılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Sayfa yüklenirken hata oluştu.';
    }
  }

  Future<void> loadFirstPage() async {
    try {
      _currentOffset = 0;
      hasMore.value = true;
      errorMessage.value = null; // Hata mesajını temizle
      items.clear();
      _pageCache.clear();
      await _fetchPage();
    } catch (e, stacktrace) {
      log(
        'İlk sayfa yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Sayfa yüklenirken hata oluştu.';
    }
  }

  Future<void> loadNextPage() async {
    if (isLoadingMore.value || !hasMore.value) return;
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    try {
      errorMessage.value = null; // Yeni isteğe başlarken hatayı temizle

      final isFirst = _currentOffset == 0;
      if (isFirst) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      List<VideoEngagementModel> result;
      if (_pageCache.containsKey(_currentOffset)) {
        result = _pageCache[_currentOffset]!;
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
    } catch (e, stacktrace) {
      log(
        'Sayfa verisi getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      // FIX: Hata olursa UI'a bildir. Kullanıcı "Yeniden Dene" butonu görebilir.
      errorMessage.value = 'Daha fazla video yüklenirken hata oluştu.';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ─── Yeniden Dene ─────────────────────────────────────────────────────────

  Future<void> retry() async {
    try {
      // Cache'deki son sayfayı temizle ve tekrar dene
      if (_currentOffset > 0 &&
          _pageCache.containsKey(_currentOffset - _pageSize)) {
        _pageCache.remove(_currentOffset - _pageSize);
      }
      await _fetchPage();
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
