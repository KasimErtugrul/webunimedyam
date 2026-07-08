// lib/data/datasources/local/local_datasource.dart

import 'package:hive_ce/hive.dart';

import 'app_cache_box.dart';
import '../../models/video_model.dart';
import '../../models/user_stats_model.dart';
import '../../models/video_engagement_model.dart';

class LocalDataSource {
  static const _onboardingKey = 'onboarding_completed';
  static const _videoCacheKey = 'videos_cache';
  static const _cacheTimeKey = 'cache_time';
  static const _themeKey = 'theme';
  static const _languageKey = 'language';

  Box get _box => AppCacheBox.instance;

  Map<String, dynamic> _asMap(dynamic v) =>
      Map<String, dynamic>.from(v as Map);

  // Onboarding
  Future<bool> isOnboardingCompleted() async {
    try {
      return (_box.get(_onboardingKey) as bool?) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setOnboardingCompleted() async {
    try {
      await _box.put(_onboardingKey, true);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // Video Cache
  Future<List<VideoModel>> getCachedVideos() async {
    try {
      final raw = _box.get(_videoCacheKey) as List?;
      if (raw == null) return [];
      return raw.map((e) => VideoModel.fromSupabase(_asMap(e))).toList();
    } catch (e) {
      return [];
    }
  }

  // FIX: OOM RİSKİ ÖNLENDİ. Artık sadece son 50 videoyu cache'liyor.
  Future<void> cacheVideos(List<VideoModel> videos) async {
    try {
      final videosToCache = videos.take(50).toList();
      await _box.put(
        _videoCacheKey,
        videosToCache.map((v) => v.toSupabase()).toList(),
      );
      await _box.put(_cacheTimeKey, DateTime.now().toUtc());
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<bool> isCacheValid() async {
    try {
      final cacheTime = _box.get(_cacheTimeKey) as DateTime?;
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
      await _box.delete(_videoCacheKey);
      await _box.delete(_cacheTimeKey);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // Theme
  Future<String> getTheme() async {
    try {
      return (_box.get(_themeKey) as String?) ?? 'dark';
    } catch (e) {
      return 'dark';
    }
  }

  Future<void> setTheme(String theme) async {
    try {
      await _box.put(_themeKey, theme);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // Language
  Future<String> getLanguage() async {
    try {
      return (_box.get(_languageKey) as String?) ?? 'tr';
    } catch (e) {
      return 'tr';
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      await _box.put(_languageKey, language);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── User Settings Cache ──────────────────────────────────────────────────

  static const _userSettingsKey = 'user_settings';

  Future<Map<String, dynamic>?> getCachedUserSettings() async {
    try {
      final raw = _box.get(_userSettingsKey);
      if (raw == null) return null;
      return _asMap(raw);
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheUserSettings(Map<String, dynamic> settings) async {
    try {
      await _box.put(_userSettingsKey, settings);
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearUserSettings() async {
    try {
      await _box.delete(_userSettingsKey);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── Favori Videolar ──────────────────────────────────────────────────────

  static const _favoriteVideosKey = 'favorite_videos';

  Future<List<VideoModel>> getFavoriteVideos() async {
    try {
      final raw = _box.get(_favoriteVideosKey) as List?;
      if (raw == null) return [];
      return raw.map((e) => VideoModel.fromSupabase(_asMap(e))).toList();
    } catch (e) {
      return [];
    }
  }

  // FIX: OOM RİSKİ ÖNLENDİ. Liste 100'ü geçerse en eski favorileri siler.
  Future<void> saveFavoriteVideo(VideoModel video) async {
    try {
      final existing = await getFavoriteVideos();
      if (existing.any((v) => v.videoId == video.videoId)) return;

      existing.insert(0, video);

      // Limit control
      const maxFavorites = 100;
      if (existing.length > maxFavorites) {
        existing.removeRange(maxFavorites, existing.length);
      }

      await _box.put(
        _favoriteVideosKey,
        existing.map((v) => v.toSupabase()).toList(),
      );
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> removeFavoriteVideo(String videoId) async {
    try {
      final existing = await getFavoriteVideos();
      existing.removeWhere((v) => v.videoId == videoId);
      await _box.put(
        _favoriteVideosKey,
        existing.map((v) => v.toSupabase()).toList(),
      );
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearFavoriteVideos() async {
    try {
      await _box.delete(_favoriteVideosKey);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── User Stats Cache ─────────────────────────────────────────────────────

  static const _userStatsKey = 'user_stats';
  static const _userStatsCacheTimeKey = 'user_stats_cache_time';

  // GÜNCELLEME: Artık TTL/süre kontrolü yapılmıyor. İlk senkronizasyondan
  // (Supabase'den ilk çekilişten) sonra bu cache, uygulama içi aksiyonlarla
  // (izleme/beğeni/favori/yorum/paylaşım) recordLocal*** metotlarıyla
  // doğrudan güncellenen "canlı" veri kaynağı haline geliyor. Süre dolduğu
  // gerekçesiyle bu veriyi görmezden gelip gereksiz yere Supabase'e tekrar
  // gitmemize gerek yok — istatistik ekranı artık tamamen buradan besleniyor.
  Future<UserStatsModel?> getCachedUserStats() async {
    try {
      final raw = _box.get(_userStatsKey);
      if (raw == null) return null;
      return UserStatsModel.fromMap(_asMap(raw));
    } catch (e) {
      return null;
    }
  }

  /// Supabase'den taze veri geldiğinde (ilk açılış veya elle "yenile")
  /// çağrılır; yerel cache'i sunucudaki son duruma sıfırlar.
  Future<void> cacheUserStats(UserStatsModel stats) async {
    try {
      await _box.put(_userStatsKey, stats.toMap());
      await _box.put(_userStatsCacheTimeKey, DateTime.now().toUtc());
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearUserStats() async {
    try {
      await _box.delete(_userStatsKey);
      await _box.delete(_userStatsCacheTimeKey);
    } catch (e) {
      // Sessizce devam et
    }
  }

  // ─── Uygulama İçi Aksiyonları Local'e Yansıtma (Mirror) ──────────────────
  //
  // Mantık: Supabase'e bir yazma işlemi (beğeni/favori/yorum/paylaşım/izleme)
  // gittiğinde AYNI ANDA yerel istatistik kopyasına da aynı değişiklik
  // uygulanır — sunucudaki karmaşık view/SQL hesaplamalarını burada tekrar
  // üretmeye çalışmıyoruz, sadece "sunucuya ne gittiyse local'e de o gider"
  // basit kuralını izliyoruz.
  //
  // Henüz hiç senkron yapılmamışsa (cache boşsa) hiçbir şey yapılmaz; bir
  // sonraki getUserStats() çağrısı zaten Supabase'den taze veriyi çekip
  // cache'i oluşturacaktır — bu yüzden action'lar sessizce no-op olur.

  Future<void> _mutateUserStats(
    UserStatsModel Function(UserStatsModel current) mutate,
  ) async {
    try {
      final raw = _box.get(_userStatsKey);
      if (raw == null) return; // İlk senkron henüz yapılmadı, dokunma.
      final current = UserStatsModel.fromMap(_asMap(raw));
      final updated = mutate(current);
      // NOT: _userStatsCacheTimeKey kasıtlı olarak burada güncellenmiyor;
      // o alan yalnızca "en son Supabase senkronu ne zaman oldu" bilgisini
      // taşıyor, mirror güncellemeleriyle karışmaması için ayrı tutuluyor.
      await _box.put(_userStatsKey, updated.toMap());
    } catch (e) {
      // Sessizce devam et
    }
  }

  int _nonNegative(int value) => value < 0 ? 0 : value;

  /// Bir video Supabase'e İLK KEZ izlenme olarak kaydedildiğinde
  /// (recordView → isNewView == true) çağrılır.
  Future<void> recordLocalVideoWatched({VideoModel? video}) async {
    final now = DateTime.now().toUtc();
    await _mutateUserStats(
      (s) => s.copyWith(
        totalWatched: s.totalWatched + 1,
        firstWatchAt: s.firstWatchAt ?? now,
        lastWatchAt: now,
        lastWatchedAt: now,
        lastWatchedTitle: video?.title ?? s.lastWatchedTitle,
        lastWatchedThumbnail: video?.bestThumbnail ?? s.lastWatchedThumbnail,
      ),
    );
  }

  /// Bir video beğenildiğinde (added: true) veya beğenisi geri
  /// alındığında (added: false) — Supabase'e addLike/removeLike ile aynı
  /// anda — çağrılır.
  Future<void> recordLocalLikeChange({
    required bool added,
    VideoModel? video,
  }) async {
    final now = DateTime.now().toUtc();
    await _mutateUserStats((s) {
      final newTotal = _nonNegative(s.totalLiked + (added ? 1 : -1));
      if (!added) return s.copyWith(totalLiked: newTotal);
      return s.copyWith(
        totalLiked: newTotal,
        lastLikedAt: now,
        lastLikedTitle: video?.title ?? s.lastLikedTitle,
        lastLikedThumbnail: video?.bestThumbnail ?? s.lastLikedThumbnail,
      );
    });
  }

  /// Bir video favorilere eklendiğinde/çıkarıldığında — Supabase'e
  /// addFavorite/removeFavorite ile aynı anda — çağrılır.
  Future<void> recordLocalFavoriteChange({required bool added}) async {
    await _mutateUserStats(
      (s) => s.copyWith(
        totalFavorited: _nonNegative(s.totalFavorited + (added ? 1 : -1)),
      ),
    );
  }

  /// Bir yorum eklendiğinde/silindiğinde — Supabase'e addComment/
  /// deleteComment ile aynı anda — çağrılır.
  Future<void> recordLocalCommentChange({required bool added}) async {
    await _mutateUserStats(
      (s) => s.copyWith(
        totalCommented: _nonNegative(s.totalCommented + (added ? 1 : -1)),
      ),
    );
  }

  /// Bir video paylaşıldığında — Supabase'e recordShare ile aynı anda —
  /// çağrılır.
  Future<void> recordLocalShare() async {
    await _mutateUserStats(
      (s) => s.copyWith(totalShared: s.totalShared + 1),
    );
  }

  // ─── Video Seksiyon Cache (30 dk TTL) ────────────────────────────────────

  static const _videoSectionPrefix = 'video_section_';
  static const _videoSectionTimePrefix = 'video_section_time_';
  static const _sectionTtlMinutes = 30;

  String _sectionKey(String key) => '$_videoSectionPrefix$key';
  String _sectionTimeKey(String key) => '$_videoSectionTimePrefix$key';

  Future<List<VideoEngagementModel>?> getCachedVideoSection(String key) async {
    try {
      final cacheTime = _box.get(_sectionTimeKey(key)) as DateTime?;
      if (cacheTime == null) return null;

      final expired =
          DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes >=
          _sectionTtlMinutes;
      if (expired) return null;

      final raw = _box.get(_sectionKey(key)) as List?;
      if (raw == null) return null;

      return raw
          .map((e) => VideoEngagementModel.fromMap(_asMap(e)))
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
      await _box.put(_sectionKey(key), items.map((e) => e.toMap()).toList());
      await _box.put(_sectionTimeKey(key), DateTime.now().toUtc());
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearVideoSectionCache() async {
    try {
      final keys = _box.keys.where(
        (k) =>
            k is String &&
            (k.startsWith(_videoSectionPrefix) ||
                k.startsWith(_videoSectionTimePrefix)),
      );
      await _box.deleteAll(keys);
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
      final cacheTime = _box.get(_profileTimeKey) as DateTime?;
      if (cacheTime == null) return null;

      final expired =
          DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes >=
          _profileTtlMinutes;
      if (expired) return null;

      final raw = _box.get(_profileKey);
      if (raw == null) return null;

      return _asMap(raw);
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheProfile(Map<String, dynamic> profile) async {
    try {
      await _box.put(_profileKey, profile);
      await _box.put(_profileTimeKey, DateTime.now().toUtc());
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearProfile() async {
    try {
      await _box.delete(_profileKey);
      await _box.delete(_profileTimeKey);
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
      final cacheTime = _box.get(_universityTimeKey) as DateTime?;
      if (cacheTime == null) return false;
      return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes <
          _universityTtlMinutes;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getCachedUniversities() async {
    try {
      final raw = _box.get(_universityKey) as List?;
      if (raw == null) return [];
      return raw.map((e) => _asMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> cacheUniversities(
    List<Map<String, dynamic>> universities,
  ) async {
    try {
      await _box.put(_universityKey, universities);
      await _box.put(_universityTimeKey, DateTime.now().toUtc());
    } catch (e) {
      // Sessizce devam et
    }
  }

  Future<void> clearUniversities() async {
    try {
      await _box.delete(_universityKey);
      await _box.delete(_universityTimeKey);
    } catch (e) {
      // Sessizce devam et
    }
  }
}