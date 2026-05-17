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

  /// Cron takvimi: Pzt-Cmt, 08:00-22:45 Türkiye saati, her 15 dakikada bir.
  ///
  /// Algoritma:
  ///   1. Şu an cron aktif saatler dışındaysa (gece/Pazar) → cache geçerli,
  ///      Supabase'e istek gitmesin.
  ///   2. Aktif saatler içindeyse → son cache'ten bu yana 15 dk geçti mi?
  ///        GEÇMEDİ → cache geçerli (cron henüz çalışmadı)
  ///        GEÇTİ   → cache süresi dolmuş, remote'dan çek
  ///   3. Cache hiç yoksa → remote'dan çek (ilk açılış).
  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheTimeString = prefs.getString(_cacheTimeKey);
    if (cacheTimeString == null) return false;

    final cacheTime = DateTime.tryParse(cacheTimeString);
    if (cacheTime == null) return false;

    // Türkiye saati (UTC+3)
    final now = DateTime.now().toUtc().add(const Duration(hours: 3));

    // Pazar (7) → cron çalışmıyor, cache her zaman geçerli
    if (now.weekday == DateTime.sunday) return true;

    // Saat 08:00-22:45 dışı → cron çalışmıyor, cache geçerli
    final minuteOfDay = now.hour * 60 + now.minute;
    const cronStart = 8 * 60;       // 08:00
    const cronEnd   = 22 * 60 + 45; // 22:45
    if (minuteOfDay < cronStart || minuteOfDay > cronEnd) return true;

    // Aktif saatler içinde → 15 dk geçti mi?
    final nowUtc = DateTime.now().toUtc();
    final cacheUtc = cacheTime.toUtc();
    return nowUtc.difference(cacheUtc).inMinutes < 15;
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

  // ─── User Settings Cache ──────────────────────────────────────────────────

  static const _userSettingsKey = 'user_settings';

  Future<Map<String, dynamic>?> getCachedUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_userSettingsKey);
    if (s == null) return null;
    return Map<String, dynamic>.from(json.decode(s) as Map);
  }

  Future<void> cacheUserSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userSettingsKey, json.encode(settings));
  }

  Future<void> clearUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSettingsKey);
  }

  // ─── Favori Videolar ──────────────────────────────────────────────────────

  static const _favoriteVideosKey = 'favorite_videos';

  /// Kaydedilmiş tüm favori videoları döner.
  Future<List<VideoModel>> getFavoriteVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoriteVideosKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => VideoModel.fromSupabase(e)).toList();
  }

  /// Bir videoyu favorilere ekler (zaten varsa tekrar eklenmez).
  Future<void> saveFavoriteVideo(VideoModel video) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getFavoriteVideos();
    if (existing.any((v) => v.videoId == video.videoId)) return;
    existing.insert(0, video); // en yeni başa
    await prefs.setString(
      _favoriteVideosKey,
      json.encode(existing.map((v) => v.toSupabase()).toList()),
    );
  }

  /// Bir videoyu favorilerden kaldırır.
  Future<void> removeFavoriteVideo(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getFavoriteVideos();
    existing.removeWhere((v) => v.videoId == videoId);
    await prefs.setString(
      _favoriteVideosKey,
      json.encode(existing.map((v) => v.toSupabase()).toList()),
    );
  }

  /// Tüm favorileri temizler (çıkış yapılınca kullanılabilir).
  Future<void> clearFavoriteVideos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoriteVideosKey);
  }
}