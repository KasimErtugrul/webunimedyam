import 'package:shared_preferences/shared_preferences.dart';
import '../../models/video_model.dart';
import '../../models/user_stats_model.dart';
import '../../models/video_engagement_model.dart';
import 'dart:convert';

class LocalDataSource {
  static const _onboardingKey = 'onboarding_completed';
  static const _videoCacheKey = 'videos_cache';
  static const _cacheTimeKey = 'cache_time';
  static const _themeKey = 'theme';
  static const _languageKey = 'language';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Onboarding
  Future<bool> isOnboardingCompleted() async {
    final prefs = await _p;
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    final prefs = await _p;
    await prefs.setBool(_onboardingKey, true);
  }

  // Video Cache
  Future<List<VideoModel>> getCachedVideos() async {
    final prefs = await _p;
    final jsonString = prefs.getString(_videoCacheKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => VideoModel.fromSupabase(e)).toList();
  }

  // FIX: OOM RİSKİ ÖNLENDİ. Artık sadece son 50 videoyu cache'liyor.
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final prefs = await _p;
    final videosToCache = videos.take(50).toList();
    final jsonList = videosToCache.map((v) => v.toSupabase()).toList();
    await prefs.setString(_videoCacheKey, json.encode(jsonList));
    await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
  }

  Future<bool> isCacheValid() async {
    final prefs = await _p;
    final cacheTimeString = prefs.getString(_cacheTimeKey);
    if (cacheTimeString == null) return false;

    final cacheTime = DateTime.tryParse(cacheTimeString);
    if (cacheTime == null) return false;

    final nowUtc = DateTime.now().toUtc();

    final minuteOfDay = nowUtc.hour * 60 + nowUtc.minute;
    const cronStart = 8 * 60;
    const cronEnd = 22 * 60 + 45;
    if (minuteOfDay < cronStart || minuteOfDay > cronEnd) return true;

    //final nowUtc = DateTime.now().toUtc();
    final cacheUtc = cacheTime.toUtc();
    return nowUtc.difference(cacheUtc).inMinutes < 15;
  }

  Future<void> clearCache() async {
    final prefs = await _p;
    await prefs.remove(_videoCacheKey);
    await prefs.remove(_cacheTimeKey);
  }

  // Theme
  Future<String> getTheme() async {
    final prefs = await _p;
    return prefs.getString(_themeKey) ?? 'dark';
  }

  Future<void> setTheme(String theme) async {
    final prefs = await _p;
    await prefs.setString(_themeKey, theme);
  }

  // Language
  Future<String> getLanguage() async {
    final prefs = await _p;
    return prefs.getString(_languageKey) ?? 'tr';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await _p;
    await prefs.setString(_languageKey, language);
  }

  // ─── User Settings Cache ──────────────────────────────────────────────────

  static const _userSettingsKey = 'user_settings';

  Future<Map<String, dynamic>?> getCachedUserSettings() async {
    final prefs = await _p;
    final s = prefs.getString(_userSettingsKey);
    if (s == null) return null;
    return Map<String, dynamic>.from(json.decode(s) as Map);
  }

  Future<void> cacheUserSettings(Map<String, dynamic> settings) async {
    final prefs = await _p;
    await prefs.setString(_userSettingsKey, json.encode(settings));
  }

  Future<void> clearUserSettings() async {
    final prefs = await _p;
    await prefs.remove(_userSettingsKey);
  }

  // ─── Favori Videolar ──────────────────────────────────────────────────────

  static const _favoriteVideosKey = 'favorite_videos';

  Future<List<VideoModel>> getFavoriteVideos() async {
    final prefs = await _p;
    final jsonString = prefs.getString(_favoriteVideosKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => VideoModel.fromSupabase(e)).toList();
  }

  // FIX: OOM RİSKİ ÖNLENDİ. Liste 100'ü geçerse en eski favorileri siler.
  Future<void> saveFavoriteVideo(VideoModel video) async {
    final prefs = await _p;
    final existing = await getFavoriteVideos();
    if (existing.any((v) => v.videoId == video.videoId)) return;

    existing.insert(0, video);

    // Limit control
    const maxFavorites = 100;
    if (existing.length > maxFavorites) {
      existing.removeRange(maxFavorites, existing.length);
    }

    await prefs.setString(
      _favoriteVideosKey,
      json.encode(existing.map((v) => v.toSupabase()).toList()),
    );
  }

  Future<void> removeFavoriteVideo(String videoId) async {
    final prefs = await _p;
    final existing = await getFavoriteVideos();
    existing.removeWhere((v) => v.videoId == videoId);
    await prefs.setString(
      _favoriteVideosKey,
      json.encode(existing.map((v) => v.toSupabase()).toList()),
    );
  }

  Future<void> clearFavoriteVideos() async {
    final prefs = await _p;
    await prefs.remove(_favoriteVideosKey);
  }

  // ─── User Stats Cache ─────────────────────────────────────────────────────

  static const _userStatsKey = 'user_stats';
  static const _userStatsCacheTimeKey = 'user_stats_cache_time';
  static const _statsTtlMinutes = 60;

  Future<UserStatsModel?> getCachedUserStats() async {
    final prefs = await _p;
    final timeStr = prefs.getString(_userStatsCacheTimeKey);
    if (timeStr == null) return null;

    final cacheTime = DateTime.tryParse(timeStr);
    if (cacheTime == null) return null;

    final expired =
        DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes >=
        _statsTtlMinutes;
    if (expired) return null;

    final jsonStr = prefs.getString(_userStatsKey);
    if (jsonStr == null) return null;

    try {
      final map = Map<String, dynamic>.from(json.decode(jsonStr) as Map);
      return UserStatsModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheUserStats(UserStatsModel stats) async {
    final prefs = await _p;
    await prefs.setString(_userStatsKey, json.encode(stats.toMap()));
    await prefs.setString(
      _userStatsCacheTimeKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> clearUserStats() async {
    final prefs = await _p;
    await prefs.remove(_userStatsKey);
    await prefs.remove(_userStatsCacheTimeKey);
  }

  // ─── Video Seksiyon Cache (30 dk TTL) ────────────────────────────────────

  static const _videoSectionPrefix = 'video_section_';
  static const _videoSectionTimePrefix = 'video_section_time_';
  static const _sectionTtlMinutes = 30;

  String _sectionKey(String key) => '$_videoSectionPrefix$key';
  String _sectionTimeKey(String key) => '$_videoSectionTimePrefix$key';

  Future<List<VideoEngagementModel>?> getCachedVideoSection(String key) async {
    final prefs = await _p;
    final timeStr = prefs.getString(_sectionTimeKey(key));
    if (timeStr == null) return null;
    final cacheTime = DateTime.tryParse(timeStr);
    if (cacheTime == null) return null;
    final expired =
        DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes >=
        _sectionTtlMinutes;
    if (expired) return null;
    final jsonStr = prefs.getString(_sectionKey(key));
    if (jsonStr == null) return null;
    try {
      final list = json.decode(jsonStr) as List;
      return list
          .map(
            (e) => VideoEngagementModel.fromMap(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheVideoSection(
    String key,
    List<VideoEngagementModel> items,
  ) async {
    final prefs = await _p;
    await prefs.setString(
      _sectionKey(key),
      json.encode(items.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      _sectionTimeKey(key),
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> clearVideoSectionCache() async {
    final prefs = await _p;
    final keys = prefs.getKeys().where(
      (k) =>
          k.startsWith(_videoSectionPrefix) ||
          k.startsWith(_videoSectionTimePrefix),
    );
    await Future.wait(keys.map((k) => prefs.remove(k)));
  }
}
