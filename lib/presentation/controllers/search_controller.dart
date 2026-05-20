import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/datasources/local/search_history_datasource.dart';
import '../../data/models/video_model.dart';

class SearchController extends GetxController {
  final SearchRepository searchRepository;
  final SearchHistoryDataSource historyDataSource;

  SearchController({
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
    history.value = await historyDataSource.getHistory();
  }

  void onQueryChanged(String value) {
    query.value = value;
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      results.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _debounce = Timer(_debounceDuration, () => _doSearch(value.trim()));
  }

  Future<void> _doSearch(String q) async {
    try {
      final data = await searchRepository.searchVideos(q);
      results.value = data;
    } catch (e) {
      log('_doSearch error: $e');
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitQuery(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;
    await historyDataSource.addQuery(trimmed);
    await _loadHistory();
    // Debounce'u iptal edip hemen ara
    _debounce?.cancel();
    isLoading.value = true;
    await _doSearch(trimmed);
  }

  Future<void> removeHistory(String q) async {
    await historyDataSource.removeQuery(q);
    history.remove(q);
  }

  Future<void> clearHistory() async {
    await historyDataSource.clearAll();
    history.clear();
  }
}
