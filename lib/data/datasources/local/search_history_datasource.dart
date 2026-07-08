// lib/data/datasources/local/search_history_datasource.dart

import 'package:hive_ce/hive.dart';

import 'app_cache_box.dart';

class SearchHistoryDataSource {
  static const _key = 'search_history';
  static const _maxItems = 15;

  Box get _box => AppCacheBox.instance;

  Future<List<String>> getHistory() async {
    try {
      final raw = _box.get(_key) as List?;
      return raw?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> addQuery(String query) async {
    try {
      final q = query.trim();
      if (q.isEmpty) return;
      final history = await getHistory();
      history.remove(q); // varsa eski konumdan kaldır
      history.insert(0, q); // başa ekle
      if (history.length > _maxItems) history.removeLast();
      await _box.put(_key, history);
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> removeQuery(String query) async {
    try {
      final history = await getHistory();
      history.remove(query);
      await _box.put(_key, history);
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearAll() async {
    try {
      await _box.delete(_key);
    } catch (e) {
      // Sessizce devam et
    }
  }
}