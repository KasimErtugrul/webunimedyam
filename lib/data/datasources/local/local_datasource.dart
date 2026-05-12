import 'package:shared_preferences/shared_preferences.dart';
import '../../models/video_model.dart';
import 'dart:convert';

class LocalDataSource {
  static const _onboardingKey = 'onboarding_completed';
  static const _videoCacheKey = 'videos_cache';
  static const _cacheTimeKey = 'cache_time';
  static const _themeKey = 'theme';
  static const _languageKey = 'language';

  // Onboarding
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // Video Cache
  Future<List<VideoModel>> getCachedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_videoCacheKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => VideoModel.fromSupabase(e)).toList();
  }

  Future<void> cacheVideos(List<VideoModel> videos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = videos.map((v) => v.toSupabase()).toList();
    await prefs.setString(_videoCacheKey, json.encode(jsonList));
    await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
  }

  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheTimeString = prefs.getString(_cacheTimeKey);
    if (cacheTimeString == null) return false;

    final cacheTime = DateTime.tryParse(cacheTimeString);
    if (cacheTime == null) return false;

    // 10 dakika cache geçerli
    return DateTime.now().difference(cacheTime).inMinutes < 10;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_videoCacheKey);
    await prefs.remove(_cacheTimeKey);
  }

  // Theme
  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'dark';
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  // Language
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'tr';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
}