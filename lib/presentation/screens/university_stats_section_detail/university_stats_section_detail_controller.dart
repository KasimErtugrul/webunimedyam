// lib/presentation/screens/university_stats_section_detail/university_stats_section_detail_controller.dart

import 'dart:developer';

import 'package:get/get.dart';

import '../../../data/models/university_stats_model.dart';
import '../../../data/repositories/university_stats_repository.dart';
import '../../../services/analytics_service.dart';

export '../../../data/repositories/university_stats_repository.dart'
    show UniversityStatsSectionType;

/// Kanal (üniversite) tab'ındaki 8 bölümün "Tümünü Gör" detay sayfası.
/// video_section_detail_controller.dart ile aynı sayfalama deseni.
class UniversityStatsSectionDetailController extends GetxController {
  final UniversityStatsRepository universityStatsRepository;

  UniversityStatsSectionDetailController({
    required this.universityStatsRepository,
  });

  late UniversityStatsSectionType sectionType;
  late String sectionTitle;

  final items = <UniversityStatsModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = RxnString();

  static const int _pageSize = 10;
  int _currentOffset = 0;

  final _pageCache = <int, List<UniversityStatsModel>>{};

  @override
  void onInit() {
    super.onInit();
    try {
      final args = Get.arguments;
      if (args is! Map<String, dynamic>) {
        errorMessage.value = 'Sayfa bilgisi alınamadı.';
        return;
      }
      sectionType = args['type'] as UniversityStatsSectionType;
      sectionTitle = args['title'] as String;

      AnalyticsService.instance.logEvent('university_stats_section_view', parameters: {
        'section_type': sectionType.name,
        'section_title': sectionTitle,
      });

      // BUG FIX / İYİLEŞTİRME: Ana sayfa zaten bu bölümün ilk 10 öğesini
      // (get_home_university_stats RPC'sinden) çekip bir Rx değişkende
      // tutuyor. "Tümünü Gör"e basıldığında bu veriyi tekrar API'den
      // istemek yerine, ana sayfadan aynı listeyi initialItems olarak
      // devralıp doğrudan gösteriyoruz — API'ye yalnızca 2. sayfa
      // istendiğinde (kaydırınca) gidiliyor. Sıralama, home RPC'si ile
      // getSectionPage()'in artık birebir aynı ORDER BY'ı kullanması
      // sayesinde (university_id ASC tiebreaker) sayfa 1 ile ana sayfa
      // listesi zaten aynı, dolayısıyla bu bir kısayoldan ibaret.
      final initialItems = args['initialItems'];
      if (initialItems is List<UniversityStatsModel> &&
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
        'UniversityStatsSectionDetailController başlatılırken hata oluştu: $e',
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
      errorMessage.value = null;
      items.clear();
      _pageCache.clear();
      await _fetchPage();
    } catch (e, stacktrace) {
      log('İlk sayfa yüklenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Sayfa yüklenirken hata oluştu.';
    }
  }

  Future<void> loadNextPage() async {
    if (isLoadingMore.value || !hasMore.value) return;
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    try {
      errorMessage.value = null;

      final isFirst = _currentOffset == 0;
      if (isFirst) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      List<UniversityStatsModel> result;
      if (_pageCache.containsKey(_currentOffset)) {
        result = _pageCache[_currentOffset]!;
      } else {
        result = await universityStatsRepository.getSectionPage(
          type: sectionType,
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
      log('Sayfa verisi getirilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Daha fazla kanal yüklenirken hata oluştu.';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> retry() async {
    try {
      if (_currentOffset > 0 && _pageCache.containsKey(_currentOffset - _pageSize)) {
        _pageCache.remove(_currentOffset - _pageSize);
      }
      await _fetchPage();
    } catch (e, stacktrace) {
      log('Yeniden deneme sırasında hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Yeniden yüklenirken hata oluştu.';
    }
  }
}
