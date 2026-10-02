import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/datasources/local/search_history_datasource.dart';
import '../../data/models/video_model.dart';
import '../../data/models/university_model.dart';

/// Arama ekranındaki "Arama Filtreleri" bottom sheet'inde seçilebilen
/// sıralama/filtre modları.
enum SearchSortMode { newest, mostViewed, liveOnly }

class VideoSearchController extends GetxController {
  final SearchRepository searchRepository;
  final SearchHistoryDataSource historyDataSource;

  VideoSearchController({
    required this.searchRepository,
    required this.historyDataSource,
  });

  // Ham (sunucudan gelen, sırasız/filtresiz) sonuçlar.
  final _rawResults = <VideoModel>[].obs;
  // Ekranda gösterilen, sortMode'a göre sıralanmış/filtrelenmiş sonuçlar.
  final results = <VideoModel>[].obs;
  final history = <String>[].obs;
  final isLoading = false.obs;
  final query = ''.obs;
  final sortMode = SearchSortMode.newest.obs;

  // FIX: Daha önce sabit/uydurma verilerdi ("#FormulaStudent" vb.). Artık
  // gerçek kullanıcı aramalarından (search_logs) ve gerçek üniversite
  // istatistiklerinden (universities_list_view) besleniyor.
  final trendingSearches = <Map<String, dynamic>>[].obs;
  final isTrendingLoading = false.obs;
  final popularUniversities = <UniversityModel>[].obs;
  final isPopularUniversitiesLoading = false.obs;

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 350);

  /// FIX: "Arama Filtreleri" bottom sheet'indeki chip'ler daha önce sadece
  /// Navigator.pop(ctx) çağırıp sheet'i kapatıyordu; seçilen sıralama hiçbir
  /// yere uygulanmıyordu. Artık seçim burada saklanıp _applySort ile sonuç
  /// listesine gerçekten uygulanıyor.
  void setSortMode(SearchSortMode mode) {
    sortMode.value = mode;
    _applySort();
  }

  void _applySort() {
    final list = List<VideoModel>.from(_rawResults);
    switch (sortMode.value) {
      case SearchSortMode.newest:
        list.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        break;
      case SearchSortMode.mostViewed:
        list.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case SearchSortMode.liveOnly:
        list
          ..retainWhere((v) => v.liveBroadcastContent == 'live')
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        break;
    }
    results.value = list;
  }

  @override
  void onReady() {
    super.onReady();
    _loadHistory();
    loadTrendingSearches();
    loadPopularUniversities();
  }

  Future<void> loadTrendingSearches() async {
    isTrendingLoading.value = true;
    try {
      trendingSearches.value = await searchRepository.getTrendingSearches();
    } catch (e, stacktrace) {
      log(
        'Trend aramalar yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      trendingSearches.clear();
    } finally {
      isTrendingLoading.value = false;
    }
  }

  Future<void> loadPopularUniversities() async {
    isPopularUniversitiesLoading.value = true;
    try {
      popularUniversities.value = await searchRepository
          .getPopularUniversities();
    } catch (e, stacktrace) {
      log(
        'Popüler üniversiteler yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      popularUniversities.clear();
    } finally {
      isPopularUniversitiesLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _loadHistory() async {
    try {
      history.value = await historyDataSource.getHistory();
    } catch (e, stacktrace) {
      log(
        'Arama geçmişi yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      history.clear(); // Hata olursa boş geç, uygulama çökmesin
    }
  }

  void onQueryChanged(String value) {
    try {
      query.value = value;
      _debounce?.cancel();

      if (value.trim().isEmpty) {
        _rawResults.clear();
        results.clear();
        isLoading.value = false;
        return;
      }

      isLoading.value = true;
      _debounce = Timer(_debounceDuration, () => _doSearch(value.trim()));
    } catch (e, stacktrace) {
      log(
        'Sorgu değişikliği işlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> _doSearch(String q) async {
    try {
      final data = await searchRepository.searchVideos(q);
      _rawResults.value = data;
      _applySort();
    } catch (e, stacktrace) {
      log('Arama yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      _rawResults.clear();
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// FIX: Bu metod arka planda arama yapıp geçmişe kaydediyordu ama
  /// `query` observable'ını hiç güncellemiyordu. Arama ekranı hangi view'ı
  /// göstereceğine (keşif/geçmiş view'i mi, sonuç listesi mi) `query.value`
  /// boş mu değil mi diye bakarak karar veriyor. Trend etiketi, kategori
  /// kartı veya üniversite chip'ine dokunulduğunda submitQuery çağrılıyor
  /// ama query hiç değişmediği için ekran hep "keşif" görünümünde kalıp
  /// arama hiç aktifleşmemiş gibi görünüyordu. Artık query burada da set
  /// ediliyor.
  Future<void> submitQuery(String q) async {
    try {
      final trimmed = q.trim();
      if (trimmed.isEmpty) return;

      query.value = trimmed;

      // FIX: Local veritabanına yazarken hata olursa (örn depolama dolu) uygulama çökmemeli
      try {
        await historyDataSource.addQuery(trimmed);
        await _loadHistory();
      } catch (e, stacktrace) {
        log(
          'Arama geçmişine eklenirken hata oluştu: $e',
          error: e,
          stackTrace: stacktrace,
        );
      }

      // Debounce'u iptal edip hemen ara
      _debounce?.cancel();
      isLoading.value = true;
      await _doSearch(trimmed);

      // Analytics: search — GA4'ün önerdiği standart event ismiyle.
      // Not: onQueryChanged() sırasındaki debounce aramaları burada değil,
      // sadece kullanıcının kesin bir arama yaptığı bu noktada loglanıyor,
      // aksi halde her tuş vuruşu ayrı event olurdu.

      if (results.isEmpty) {}

      // Trend başlıklar gerçek arama verisinden beslendiği için her
      // aramayı arka planda logluyoruz (hata olursa akışı etkilemez) ve
      // listeyi tazeliyoruz ki kullanıcı kendi aradığı şeyin de trendlere
      // katkı sağladığını zamanla görebilsin.
      unawaited(
        searchRepository
            .logSearchQuery(trimmed)
            .then((_) => loadTrendingSearches()),
      );
    } catch (e, stacktrace) {
      log(
        'Sorgu gönderilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // FIX: Local veritabanından silerken de hata yönetimi eklendi
  Future<void> removeHistory(String q) async {
    try {
      await historyDataSource.removeQuery(q);
      history.remove(q);
    } catch (e, stacktrace) {
      log(
        'Arama geçmişinden silinirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> clearHistory() async {
    try {
      await historyDataSource.clearAll();
      history.clear();
    } catch (e, stacktrace) {
      log(
        'Arama geçmişi temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }
}
