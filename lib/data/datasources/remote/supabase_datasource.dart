import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/university_stats_model.dart';
import '../../models/video_model.dart';
import '../../models/university_model.dart';
import '../../models/profile_model.dart';
import '../../models/user_settings_model.dart';
import '../../models/comment_model.dart';

class SupabaseDataSource {
  final _client = Supabase.instance.client;

  // Auth
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Profil
  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromSupabase(data);
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await _client
        .from('profiles')
        .update(profile.toSupabase())
        .eq('id', profile.id);
  }

  // Ayarlar
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    final data = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return UserSettingsModel.fromSupabase(data);
  }

  Future<void> updateUserSettings(UserSettingsModel settings) async {
    await _client
        .from('user_settings')
        .update(settings.toSupabase())
        .eq('user_id', settings.userId);
  }

  // ─── Üniversiteler ────────────────────────────────────────────────────────
  Future<List<UniversityModel>> getUniversities() async {
    final data = await _client
        .from('universities')
        .select()
        .order('name', ascending: true);
    return (data as List).map((e) => UniversityModel.fromSupabase(e)).toList();
  }

  // ─── Video Cache ──────────────────────────────────────────────────────────
  Future<List<VideoModel>> getCachedVideos() async {
    final data = await _client
        .from('videos_cache')
        .select('*, universities(name)')
        .order('published_at', ascending: false);

    return (data as List).map((e) {
      final row = Map<String, dynamic>.from(e);
      if (row['universities'] != null) {
        row['university_name'] = row['universities']['name'];
      }
      row.remove('universities');
      return VideoModel.fromSupabase(row);
    }).toList();
  }

  Future<List<VideoModel>> getCachedVideosByUniversity(int universityId) async {
    final data = await _client
        .from('videos_cache')
        .select('*, universities(name)')
        .eq('university_id', universityId)
        .order('published_at', ascending: false);

    return (data as List).map((e) {
      final row = Map<String, dynamic>.from(e);
      if (row['universities'] != null) {
        row['university_name'] = row['universities']['name'];
      }
      row.remove('universities');
      return VideoModel.fromSupabase(row);
    }).toList();
  }

  Future<List<VideoModel>> getLatestVideoPerUniversity() async {
    final data = await _client
        .from('latest_videos_per_university')
        .select()
        .order('published_at', ascending: false);

    return (data as List).map((e) => VideoModel.fromSupabase(e)).toList();
  }

  Future<void> upsertVideos(List<VideoModel> videos) async {
    final data = videos.map((v) => v.toSupabase()).toList();
    await _client.from('videos_cache').upsert(data, onConflict: 'video_id');
  }

  // ─── Favoriler ────────────────────────────────────────────────────────────
  Future<List<String>> getFavoriteVideoIds(String userId) async {
    final data = await _client
        .from('favorites')
        .select('video_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['video_id'] as String).toList();
  }

  Future<List<VideoModel>> getUserFavoriteVideos(String userId) async {
    final data = await _client
        .from('favorites')
        .select('video_id, created_at, videos_cache(*, universities(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<VideoModel> videos = [];
    for (final row in (data as List)) {
      final videoData = row['videos_cache'];
      if (videoData == null) continue;
      final map = Map<String, dynamic>.from(videoData as Map);
      if (map['universities'] != null) {
        map['university_name'] = map['universities']['name'];
      }
      map.remove('universities');
      videos.add(VideoModel.fromSupabase(map));
    }
    return videos;
  }

  Future<void> addFavorite(String userId, String videoId) async {
    await _client.from('favorites').insert({
      'user_id': userId,
      'video_id': videoId,
    });
  }

  Future<void> removeFavorite(String userId, String videoId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('video_id', videoId);
  }

  // ─── Yorumlar ─────────────────────────────────────────────────────────────
  Future<List<CommentModel>> getComments(String videoId) async {
    final data = await _client
        .from('comments')
        .select('*, profiles(username, avatar_url)')
        .eq('video_id', videoId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => CommentModel.fromSupabase(e)).toList();
  }

  Future<void> addComment(String userId, String videoId, String content) async {
    await _client.from('comments').insert({
      'user_id': userId,
      'video_id': videoId,
      'content': content,
    });
  }

  Future<void> deleteComment(String commentId) async {
    await _client.from('comments').delete().eq('id', commentId);
  }

  Future<void> updateComment(String commentId, String content) async {
    await _client
        .from('comments')
        .update({
          'content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', commentId);
  }

  Future<List<VideoModel>> getUserCommentedVideos(String userId) async {
    final data = await _client
        .from('comments')
        .select('video_id, created_at, videos_cache(*, universities(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final seen = <String>{};
    final List<VideoModel> videos = [];
    for (final row in (data as List)) {
      final videoData = row['videos_cache'];
      if (videoData == null) continue;
      final map = Map<String, dynamic>.from(videoData as Map);
      final videoId = map['video_id'] as String? ?? '';
      if (seen.contains(videoId)) continue;
      seen.add(videoId);
      if (map['universities'] != null) {
        map['university_name'] = map['universities']['name'];
      }
      map.remove('universities');
      videos.add(VideoModel.fromSupabase(map));
    }
    return videos;
  }

  // ─── Oynatma Listeleri ────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getUniversitiesWithVideoCount() async {
    final data = await _client
        .from('universities_with_stats')
        .select(
          'id, name, channel_id, video_count, thumbnail_url, logo_url, uploads_playlist_id',
        )
        .order('name', ascending: true);

    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // FIX: Alias - tek sorgu ile hem UniversityModel hem PlaylistModel beslenir.
  Future<List<Map<String, dynamic>>> getUniversitiesWithStats() =>
      getUniversitiesWithVideoCount();

  // ─── Onboarding ──────────────────────────────────────────────────────────
  Future<bool> isOnboardingCompleted(String userId) async {
    final data = await _client
        .from('onboarding')
        .select('completed')
        .eq('user_id', userId)
        .maybeSingle();
    return data?['completed'] ?? false;
  }

  Future<void> completeOnboarding(String userId) async {
    await _client
        .from('onboarding')
        .update({
          'completed': true,
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
  }

  // ─── Arama ───────────────────────────────────────────────────────────────
  Future<List<VideoModel>> searchVideos(String query, {int limit = 30}) async {
    final data = await _client.rpc(
      'search_videos',
      params: {'search_term': query, 'result_limit': limit},
    );
    return (data as List)
        .map((e) => VideoModel.fromSupabase(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ─── Beğeni (likes) ──────────────────────────────────────────────────────
  Future<bool> isLiked(String userId, String videoId) async {
    final data = await _client
        .from('likes')
        .select('id')
        .eq('user_id', userId)
        .eq('video_id', videoId)
        .maybeSingle();
    return data != null;
  }

  Future<void> addLike(String userId, String videoId) async {
    await _client.from('likes').upsert({
      'user_id': userId,
      'video_id': videoId,
    }, onConflict: 'user_id,video_id');
  }

  Future<void> removeLike(String userId, String videoId) async {
    await _client
        .from('likes')
        .delete()
        .eq('user_id', userId)
        .eq('video_id', videoId);
  }

  // ─── Görüntüleme (content_views) ─────────────────────────────────────────
  Future<void> recordView(String userId, String videoId) async {
    await _client.from('content_views').upsert({
      'user_id': userId,
      'video_id': videoId,
    }, onConflict: 'user_id,video_id');
  }

  Future<List<VideoModel>> getUserViewedVideos(String userId) async {
    final data = await _client
        .from('content_views')
        .select('video_id, created_at, videos_cache(*, universities(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<VideoModel> videos = [];
    for (final row in (data as List)) {
      final videoData = row['videos_cache'];
      if (videoData == null) continue;
      final map = Map<String, dynamic>.from(videoData as Map);
      if (map['universities'] != null) {
        map['university_name'] = map['universities']['name'];
      }
      map.remove('universities');
      videos.add(VideoModel.fromSupabase(map));
    }
    return videos;
  }

  // ─── Paylaşım (shared) ───────────────────────────────────────────────────
  Future<void> recordShare(String userId, String videoId) async {
    await _client.from('shared').upsert({
      'user_id': userId,
      'video_id': videoId,
    }, onConflict: 'user_id,video_id');
  }

  Future<List<VideoModel>> getUserSharedVideos(String userId) async {
    final data = await _client
        .from('shared')
        .select('video_id, created_at, videos_cache(*, universities(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<VideoModel> videos = [];
    for (final row in (data as List)) {
      final videoData = row['videos_cache'];
      if (videoData == null) continue;
      final map = Map<String, dynamic>.from(videoData as Map);
      if (map['universities'] != null) {
        map['university_name'] = map['universities']['name'];
      }
      map.remove('universities');
      videos.add(VideoModel.fromSupabase(map));
    }
    return videos;
  }

  // ─── Etkileşim İstatistikleri ─────────────────────────────────────────────
  Future<Map<String, int>> getEngagementStats(String videoId) async {
    final data = await _client
        .from('video_engagement_stats')
        .select()
        .eq('video_id', videoId)
        .maybeSingle();

    if (data == null) {
      return {
        'app_view_count': 0,
        'app_like_count': 0,
        'app_favorite_count': 0,
        'app_share_count': 0,
        'app_comment_count': 0,
      };
    }

    return {
      'app_view_count': (data['app_view_count'] as num?)?.toInt() ?? 0,
      'app_like_count': (data['app_like_count'] as num?)?.toInt() ?? 0,
      'app_favorite_count': (data['app_favorite_count'] as num?)?.toInt() ?? 0,
      'app_share_count': (data['app_share_count'] as num?)?.toInt() ?? 0,
      'app_comment_count': (data['app_comment_count'] as num?)?.toInt() ?? 0,
    };
  }

  // ─── Kullanıcı İstatistikleri ─────────────────────────────────────────────
  Future<Map<String, dynamic>?> getMyStats() async {
    final data = await _client.rpc('get_my_stats');
    if (data == null || (data as List).isEmpty) return null;
    // ignore: unnecessary_cast
    return Map<String, dynamic>.from((data as List).first as Map);
  }

  // ─── Üniversite İstatistikleri (university_stats view) ───────────────────
  Future<List<UniversityStatsModel>> getUniversityStatsList({
    required String orderBy,
    int limit = 10,
    String? filter,
  }) async {
    final base = _client.from('university_stats').select();

    final filtered = (filter != null)
        ? () {
            final parts = filter.split('.');
            if (parts.length == 3) {
              final val = num.tryParse(parts[2]) ?? parts[2];
              return base.filter(parts[0], parts[1], val);
            }
            return base;
          }()
        : base;

    final data = await filtered
        .order(orderBy, ascending: false)
        .limit(limit);

    return (data as List)
        .map((e) => UniversityStatsModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ─── Video Engagement Stats ───────────────────────────────────────────────

  /// video_engagement_stats view'inden sayfalı liste çeker.
  /// [orderBy]  : kolon adı (ör. 'engagement_score')
  /// [ascending]: sıralama yönü (genellikle false)
  /// [filter]   : opsiyonel koşul — 'kolon.operator.değer' formatında
  ///              Ör: 'app_view_count.gt.0'  →  app_view_count > 0
  /// [limit]    : sayfa boyutu (ana sayfa için 10, detay için 10)
  /// [offset]   : kaçıncı kayıttan başlanacak (pagination için)
  Future<List<Map<String, dynamic>>> getVideoEngagementList({
    required String orderBy,
    bool ascending = false,
    String? filter,
    int limit = 10,
    int offset = 0,
  }) async {
    final base = _client.from('video_engagement_stats').select();

    final filtered = _applyFilter(base, filter);

    final data = await filtered
        .order(orderBy, ascending: ascending)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(data);
  }

  /// Filter string'ini 'kolon.operator.değer' formatında parse eder.
  dynamic _applyFilter(dynamic query, String? filter) {
    if (filter == null) return query;
    final parts = filter.split('.');
    if (parts.length == 3) {
      final val = num.tryParse(parts[2]) ?? parts[2];
      return query.filter(parts[0], parts[1], val);
    }
    return query;
  }

  // Seksiyon bazlı wrapper metodlar

  Future<List<Map<String, dynamic>>> getTrendingVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'engagement_score',
        limit: limit,
        offset: offset,
      );

  Future<List<Map<String, dynamic>>> getMostWatchedVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'yt_view_count',
        limit: limit,
        offset: offset,
      );

  Future<List<Map<String, dynamic>>> getMostLikedVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'app_like_count',
        filter: 'app_like_count.gt.0',
        limit: limit,
        offset: offset,
      );

  Future<List<Map<String, dynamic>>> getMostFavoritedVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'app_favorite_count',
        filter: 'app_favorite_count.gt.0',
        limit: limit,
        offset: offset,
      );

  Future<List<Map<String, dynamic>>> getMostCommentedVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'app_comment_count',
        filter: 'app_comment_count.gt.0',
        limit: limit,
        offset: offset,
      );

  Future<List<Map<String, dynamic>>> getNewAndUndiscoveredVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'published_at',
        filter: 'app_view_count.eq.0',
        limit: limit,
        offset: offset,
      );
}
