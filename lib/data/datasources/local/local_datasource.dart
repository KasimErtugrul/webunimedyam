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
    try {
      final prefs = await _p;
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setOnboardingCompleted() async {
    try {
      final prefs = await _p;
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      // Log yok, sessizce devam et
    }
  }

  // Video Cache
  Future<List<VideoModel>> getCachedVideos() async {
    try {
      final prefs = await _p;
      final jsonString = prefs.getString(_videoCacheKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => VideoModel.fromSupabase(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // FIX: OOM RİSKİ ÖNLENDİ. Artık sadece son 50 videoyu cache'liyor.
  Future<void> cacheVideos(List<VideoModel> videos) async {
    try {
      final prefs = await _p;
      final videosToCache = videos.take(50).toList();
      final jsonList = videosToCache.map((v) => v.toSupabase()).toList();
      await prefs.setString(_videoCacheKey, json.encode(jsonList));
      await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<bool> isCacheValid() async {
    try {
      final prefs = await _p;
      final cacheTimeString = prefs.getString(_cacheTimeKey);
      if (cacheTimeString == null) return false;

      final cacheTime = DateTime.tryParse(cacheTimeString);
      if (cacheTime == null) return false;

      final nowUtc = DateTime.now().toUtc();
      final cacheUtc = cacheTime.toUtc();
      final ageMinutes = nowUtc.difference(cacheUtc).inMinutes;

      final minuteOfDay = nowUtc.hour * 60 + nowUtc.minute;
      const cronStart = 8 * 60;
      const cronEnd = 22 * 60 + 45;

      // YouTube senkronizasyon cron'u sadece 08:00-22:45 UTC arası çalışıyor,
      // bu yüzden video metadata'sı (başlık, thumbnail vb.) bu pencere
      // dışında değişmez ve cache'i sık sık yenilemeye gerek yok.
      // FIX: appViewCount/appLikeCount gibi UYGULAMA İÇİ istatistikler ise
      // günün her saatinde değişebilir (kullanıcılar gece de video izleyebilir),
      // bu yüzden pencere dışında da cache SÜRESİZ değil, sadece daha gevşek
      // (60 dk) bir TTL ile geçerli sayılır.
      if (minuteOfDay < cronStart || minuteOfDay > cronEnd) {
        return ageMinutes < 60;
      }

      return ageMinutes < 15;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await _p;
      await prefs.remove(_videoCacheKey);
      await prefs.remove(_cacheTimeKey);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // Theme
  Future<String> getTheme() async {
    try {
      final prefs = await _p;
      return prefs.getString(_themeKey) ?? 'dark';
    } catch (e) {
      return 'dark';
    }
  }

  Future<void> setTheme(String theme) async {
    try {
      final prefs = await _p;
      await prefs.setString(_themeKey, theme);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // Language
  Future<String> getLanguage() async {
    try {
      final prefs = await _p;
      return prefs.getString(_languageKey) ?? 'tr';
    } catch (e) {
      return 'tr';
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      final prefs = await _p;
      await prefs.setString(_languageKey, language);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── User Settings Cache ──────────────────────────────────────────────────

  static const _userSettingsKey = 'user_settings';

  Future<Map<String, dynamic>?> getCachedUserSettings() async {
    try {
      final prefs = await _p;
      final s = prefs.getString(_userSettingsKey);
      if (s == null) return null;
      return Map<String, dynamic>.from(json.decode(s) as Map);
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheUserSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await _p;
      await prefs.setString(_userSettingsKey, json.encode(settings));
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearUserSettings() async {
    try {
      final prefs = await _p;
      await prefs.remove(_userSettingsKey);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── Favori Videolar ──────────────────────────────────────────────────────

  static const _favoriteVideosKey = 'favorite_videos';

  Future<List<VideoModel>> getFavoriteVideos() async {
    try {
      final prefs = await _p;
      final jsonString = prefs.getString(_favoriteVideosKey);
      if (jsonString == null) return [];
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => VideoModel.fromSupabase(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // FIX: OOM RİSKİ ÖNLENDİ. Liste 100'ü geçerse en eski favorileri siler.
  Future<void> saveFavoriteVideo(VideoModel video) async {
    try {
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
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> removeFavoriteVideo(String videoId) async {
    try {
      final prefs = await _p;
      final existing = await getFavoriteVideos();
      existing.removeWhere((v) => v.videoId == videoId);
      await prefs.setString(
        _favoriteVideosKey,
        json.encode(existing.map((v) => v.toSupabase()).toList()),
      );
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearFavoriteVideos() async {
    try {
      final prefs = await _p;
      await prefs.remove(_favoriteVideosKey);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── User Stats Cache ─────────────────────────────────────────────────────

  static const _userStatsKey = 'user_stats';
  static const _userStatsCacheTimeKey = 'user_stats_cache_time';
  static const _statsTtlMinutes = 60;

  Future<UserStatsModel?> getCachedUserStats() async {
    try {
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

      final map = Map<String, dynamic>.from(json.decode(jsonStr) as Map);
      return UserStatsModel.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheUserStats(UserStatsModel stats) async {
    try {
      final prefs = await _p;
      await prefs.setString(_userStatsKey, json.encode(stats.toMap()));
      await prefs.setString(
        _userStatsCacheTimeKey,
        DateTime.now().toUtc().toIso8601String(),
      );
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearUserStats() async {
    try {
      final prefs = await _p;
      await prefs.remove(_userStatsKey);
      await prefs.remove(_userStatsCacheTimeKey);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── Video Seksiyon Cache (30 dk TTL) ────────────────────────────────────

  static const _videoSectionPrefix = 'video_section_';
  static const _videoSectionTimePrefix = 'video_section_time_';
  static const _sectionTtlMinutes = 30;

  String _sectionKey(String key) => '$_videoSectionPrefix$key';
  String _sectionTimeKey(String key) => '$_videoSectionTimePrefix$key';

  Future<List<VideoEngagementModel>?> getCachedVideoSection(String key) async {
    try {
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
      final list = json.decode(jsonStr) as List;
      return list
          .map(
            (e) => VideoEngagementModel.fromMap(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheVideoSection(
    String key,
    List<VideoEngagementModel> items,
  ) async {
    try {
      final prefs = await _p;
      await prefs.setString(
        _sectionKey(key),
        json.encode(items.map((e) => e.toMap()).toList()),
      );
      await prefs.setString(
        _sectionTimeKey(key),
        DateTime.now().toUtc().toIso8601String(),
      );
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearVideoSectionCache() async {
    try {
      final prefs = await _p;
      final keys = prefs.getKeys().where(
        (k) =>
            k.startsWith(_videoSectionPrefix) ||
            k.startsWith(_videoSectionTimePrefix),
      );
      await Future.wait(keys.map((k) => prefs.remove(k)));
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── Profil Cache (TTL: 30 dk) ───────────────────────────────────────────

  static const _profileKey = 'cached_profile';
  static const _profileTimeKey = 'cached_profile_time';
  static const _profileTtlMinutes = 30;

  Future<Map<String, dynamic>?> getCachedProfile() async {
    try {
      final prefs = await _p;
      final timeStr = prefs.getString(_profileTimeKey);
      if (timeStr == null) return null;
      final cacheTime = DateTime.tryParse(timeStr);
      if (cacheTime == null) return null;
      final expired =
          DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes >=
          _profileTtlMinutes;
      if (expired) return null;
      final s = prefs.getString(_profileKey);
      if (s == null) return null;
      return Map<String, dynamic>.from(json.decode(s) as Map);
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheProfile(Map<String, dynamic> profile) async {
    try {
      final prefs = await _p;
      await prefs.setString(_profileKey, json.encode(profile));
      await prefs.setString(
        _profileTimeKey,
        DateTime.now().toUtc().toIso8601String(),
      );
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearProfile() async {
    try {
      final prefs = await _p;
      await prefs.remove(_profileKey);
      await prefs.remove(_profileTimeKey);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── Üniversite Cache (TTL: 30 dk) ───────────────────────────────────────

  static const _universityKey = 'cached_universities';
  static const _universityTimeKey = 'cached_universities_time';
  static const _universityTtlMinutes = 30;

  Future<bool> isUniversityCacheValid() async {
    try {
      final prefs = await _p;
      final timeStr = prefs.getString(_universityTimeKey);
      if (timeStr == null) return false;
      final cacheTime = DateTime.tryParse(timeStr);
      if (cacheTime == null) return false;
      return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes <
          _universityTtlMinutes;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getCachedUniversities() async {
    try {
      final prefs = await _p;
      final s = prefs.getString(_universityKey);
      if (s == null) return [];
      final list = json.decode(s) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> cacheUniversities(
    List<Map<String, dynamic>> universities,
  ) async {
    try {
      final prefs = await _p;
      await prefs.setString(_universityKey, json.encode(universities));
      await prefs.setString(
        _universityTimeKey,
        DateTime.now().toUtc().toIso8601String(),
      );
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearUniversities() async {
    try {
      final prefs = await _p;
      await prefs.remove(_universityKey);
      await prefs.remove(_universityTimeKey);
    } catch (e) {
      // Sessizce devam et
    }
  }
}
