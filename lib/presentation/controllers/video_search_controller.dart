import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/datasources/local/search_history_datasource.dart';
import '../../data/models/video_model.dart';

class VideoSearchController extends GetxController {
  final SearchRepository searchRepository;
  final SearchHistoryDataSource historyDataSource;

  VideoSearchController({
    required this.searchRepository,
    required this.historyDataSource,
  });

  final results = <VideoModel>[].obs;
  final history = <String>[].obs;
  final isLoading = false.obs;
  final query = ''.obs;

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 350);

  @override
  void onReady() {
    super.onReady();
    _loadHistory();
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
      log('Arama geçmişi yüklenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      history.clear(); // Hata olursa boş geç, uygulama çökmesin
    }
  }

  void onQueryChanged(String value) {
    try {
      query.value = value;
      _debounce?.cancel();

      if (value.trim().isEmpty) {
        results.clear();
        isLoading.value = false;
        return;
      }

      isLoading.value = true;
      _debounce = Timer(_debounceDuration, () => _doSearch(value.trim()));
    } catch (e, stacktrace) {
      log('Sorgu değişikliği işlenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  Future<void> _doSearch(String q) async {
    try {
      final data = await searchRepository.searchVideos(q);
      results.value = data;
    } catch (e, stacktrace) {
      log('Arama yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitQuery(String q) async {
    try {
      final trimmed = q.trim();
      if (trimmed.isEmpty) return;

      // FIX: Local veritabanına yazarken hata olursa (örn depolama dolu) uygulama çökmemeli
      try {
        await historyDataSource.addQuery(trimmed);
        await _loadHistory();
      } catch (e, stacktrace) {
        log('Arama geçmişine eklenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      }

      // Debounce'u iptal edip hemen ara
      _debounce?.cancel();
      isLoading.value = true;
      await _doSearch(trimmed);
    } catch (e, stacktrace) {
      log('Sorgu gönderilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  // FIX: Local veritabanından silerken de hata yönetimi eklendi
  Future<void> removeHistory(String q) async {
    try {
      await historyDataSource.removeQuery(q);
      history.remove(q);
    } catch (e, stacktrace) {
      log('Arama geçmişinden silinirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  Future<void> clearHistory() async {
    try {
      await historyDataSource.clearAll();
      history.clear();
    } catch (e, stacktrace) {
      log('Arama geçmişi temizlenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }
}