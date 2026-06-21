import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryDataSource {
  static const _key = 'search_history';
  static const _maxItems = 15;

  Future<List<String>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> addQuery(String query) async {
    try {
      final q = query.trim();
      if (q.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_key) ?? [];
      history.remove(q); // varsa eski konumdan kaldır
      history.insert(0, q); // başa ekle
      if (history.length > _maxItems) history.removeLast();
      await prefs.setStringList(_key, history);
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> removeQuery(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_key) ?? [];
      history.remove(query);
      await prefs.setStringList(_key, history);
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (e) {
      // Sessizce devam et
    }
  }
}
