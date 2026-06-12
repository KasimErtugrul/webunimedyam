import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/shorts_model.dart';
import '../../models/university_stats_model.dart';
import '../../models/video_model.dart';
import '../../models/university_model.dart';
import '../../models/profile_model.dart';
import '../../models/user_settings_model.dart';
import '../../models/comment_model.dart';
import '../../models/video_viewer_model.dart';

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
  Future<List<UniversityModel>> getUniversities({int limit = 500}) async {
    final data = await _client
        .from('universities')
        .select()
        .order('name', ascending: true)
        .limit(limit);
    return (data as List).map((e) => UniversityModel.fromSupabase(e)).toList();
  }

  Future<UniversityModel> getUniversityById(int id) async {
    final data = await _client
        .from('universities')
        .select()
        .eq('id', id)
        .single();
    return UniversityModel.fromSupabase(data);
  }

  // ─── Video Cache ──────────────────────────────────────────────────────────

  Future<VideoModel?> getVideoById(String videoId) async {
    final data = await _client
        .from('videos_cache')
        .select('*, universities(name)')
        .eq('video_id', videoId)
        .maybeSingle();

    if (data == null) return null;
    final row = Map<String, dynamic>.from(data);
    if (row['universities'] != null) {
      row['university_name'] = row['universities']['name'];
    }
    row.remove('universities');
    return VideoModel.fromSupabase(row);
  }

  Future<List<VideoModel>> getCachedVideos({
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('videos_cache')
        .select('*, universities(name)')
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((e) {
      final row = Map<String, dynamic>.from(e);
      if (row['universities'] != null) {
        row['university_name'] = row['universities']['name'];
      }
      row.remove('universities');
      return VideoModel.fromSupabase(row);
    }).toList();
  }

  Future<List<VideoModel>> getCachedVideosByUniversity(
    int universityId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('videos_cache')
        .select('*, universities(name)')
        .eq('university_id', universityId)
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((e) {
      final row = Map<String, dynamic>.from(e);
      if (row['universities'] != null) {
        row['university_name'] = row['universities']['name'];
      }
      row.remove('universities');
      return VideoModel.fromSupabase(row);
    }).toList();
  }

  Future<List<VideoModel>> getLatestVideoPerUniversity({
    int limit = 500,
    int offset = 0,
  }) async {
    final data = await _client
        .from('latest_videos_per_university')
        .select()
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((e) => VideoModel.fromSupabase(e)).toList();
  }

  /// Her üniversiteden en son 1 shorts videoyu çeker.
  /// VOLATILE RPC — her seferinde taze veri, yayınlanma tarihine göre sıralı.
  Future<List<ShortsModel>> getShortsPerUniversity() async {
    final data = await _client.rpc('get_shorts_per_university');
    return (data as List)
        .map((e) => ShortsModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> upsertVideos(List<VideoModel> videos) async {
    final data = videos.map((v) => v.toSupabase()).toList();
    await _client.from('videos_cache').upsert(data, onConflict: 'video_id');
  }

  // ─── Favoriler ────────────────────────────────────────────────────────────
  Future<List<String>> getFavoriteVideoIds(
    String userId, {
    int limit = 20,
  }) async {
    final data = await _client
        .from('favorites')
        .select('video_id')
        .eq('user_id', userId)
        .limit(limit);
    return (data as List).map((e) => e['video_id'] as String).toList();
  }

  Future<List<VideoModel>> getUserFavoriteVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('favorites')
        .select('video_id, created_at, videos_cache(*, universities(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

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
  Future<List<CommentModel>> getComments(
    String videoId, {
    int limit = 200,
    int offset = 0,
  }) async {
    final data = await _client
        .from('comments')
        .select('*, profiles(username, avatar_url)')
        .eq('video_id', videoId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
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

  Future<List<VideoModel>> getUserCommentedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('comments')
        .select('video_id, created_at, videos_cache(*, universities(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

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

  // ─── Üniversiteler + İstatistikler ───────────────────────────────────────
  //
  // FIX: Daha önce mevcut olmayan 'universities_with_stats' view'ı çağrılıyordu.
  // Bu view artık Supabase'de oluşturuldu.
  // View; universities tablosundaki tüm kolonları + favorite_count + thumbnail_url içerir.

  Future<List<Map<String, dynamic>>> getUniversitiesWithVideoCount({
    int limit = 500,
  }) async {
    final data = await _client
        .from('universities_with_stats') // ✅ View artık mevcut
        .select('*')
        .order('name', ascending: true)
        .limit(limit);

    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getUniversitiesWithStats({
    int limit = 500,
  }) =>
      getUniversitiesWithVideoCount(limit: limit);

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
    await _client.from('onboarding').upsert(
      {
        'user_id': userId,
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
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

  Future<Set<String>> getLikedVideoIds(String userId) async {
    final data = await _client
        .from('likes')
        .select('video_id')
        .eq('user_id', userId);
    return (data as List<dynamic>)
        .map((row) => row['video_id'] as String)
        .toSet();
  }

  // ─── Görüntüleme (content_views) ─────────────────────────────────────────
  Future<void> recordView(String userId, String videoId) async {
    await _client.from('content_views').upsert({
      'user_id': userId,
      'video_id': videoId,
    }, onConflict: 'user_id,video_id');
  }

  Future<List<VideoModel>> getUserViewedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('content_views')
        .select('video_id, created_at, videos_cache(*, universities(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

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

  Future<List<VideoModel>> getUserSharedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('shared')
        .select('video_id, created_at, videos_cache(*, universities(name))')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

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
    log(
      'supabase datasource getengagementstats fonksiyonu: getEngagementStats videoId: $videoId',
    );
    final data = await _client
        .from('video_engagement_stats')
        .select()
        .eq('video_id', videoId)
        .maybeSingle();

    log(
      'supabase datasource getengagementstats fonksiyonu: getEngagementStats data: $data',
    );
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

  // ─── Üniversite İstatistikleri ───────────────────────────────────────────
  Future<List<UniversityStatsModel>> getUniversityStatsList({
    required String orderBy,
    int limit = 10,
    int offset = 0,
    String? filterColumn,
    String? filterOperator,
    dynamic filterValue,
  }) async {
    var query = _client.from('university_stats').select();

    if (filterColumn != null && filterOperator != null && filterValue != null) {
      switch (filterOperator) {
        case 'gt':
          query = query.gt(filterColumn, filterValue);
          break;
        case 'lt':
          query = query.lt(filterColumn, filterValue);
          break;
        case 'eq':
          query = query.eq(filterColumn, filterValue);
          break;
        case 'gte':
          query = query.gte(filterColumn, filterValue);
          break;
        case 'lte':
          query = query.lte(filterColumn, filterValue);
          break;
        case 'neq':
          query = query.neq(filterColumn, filterValue);
          break;
      }
    }

    final data = await query
        .order(orderBy, ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List)
        .map((e) => UniversityStatsModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ─── Video Engagement Stats ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getVideoEngagementList({
    required String orderBy,
    bool ascending = false,
    int limit = 10,
    int offset = 0,
    String? filterColumn,
    String? filterOperator,
    dynamic filterValue,
  }) async {
    var query = _client.from('video_engagement_stats').select();

    if (filterColumn != null && filterOperator != null && filterValue != null) {
      switch (filterOperator) {
        case 'gt':
          query = query.gt(filterColumn, filterValue);
          break;
        case 'lt':
          query = query.lt(filterColumn, filterValue);
          break;
        case 'eq':
          query = query.eq(filterColumn, filterValue);
          break;
        case 'gte':
          query = query.gte(filterColumn, filterValue);
          break;
        case 'lte':
          query = query.lte(filterColumn, filterValue);
          break;
        case 'neq':
          query = query.neq(filterColumn, filterValue);
          break;
      }
    }

    final data = await query
        .order(orderBy, ascending: ascending)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(data);
  }

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

  // ─── Öneri Sistemi ────────────────────────────────────────────────────────
  Future<List<VideoModel>> getSuggestedVideos(String videoId) async {
    final data = await _client.rpc(
      'get_suggested_videos',
      params: {'current_video_id': videoId},
    );
    return (data as List)
        .map((e) => VideoModel.fromSupabase(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getMostLikedVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'app_like_count',
        filterColumn: 'app_like_count',
        filterOperator: 'gt',
        filterValue: 0,
        limit: limit,
        offset: offset,
      );

  Future<List<VideoViewerModel>> getVideoViewers(
    String videoId, {
    int limit = 10,
    int offset = 0,
  }) async {
    final data = await _client.rpc(
      'get_video_viewers',
      params: {
        'p_video_id': videoId,
        'p_limit': limit,
        'p_offset': offset,
      },
    );
    return (data as List)
        .map((e) => VideoViewerModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getMostFavoritedVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'app_favorite_count',
        filterColumn: 'app_favorite_count',
        filterOperator: 'gt',
        filterValue: 0,
        limit: limit,
        offset: offset,
      );

  Future<List<Map<String, dynamic>>> getMostCommentedVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'app_comment_count',
        filterColumn: 'app_comment_count',
        filterOperator: 'gt',
        filterValue: 0,
        limit: limit,
        offset: offset,
      );

  Future<List<Map<String, dynamic>>> getNewAndUndiscoveredVideos({
    int limit = 10,
    int offset = 0,
  }) =>
      getVideoEngagementList(
        orderBy: 'published_at',
        filterColumn: 'app_view_count',
        filterOperator: 'eq',
        filterValue: 0,
        limit: limit,
        offset: offset,
      );

  // ─── Üniversite Favorileri ────────────────────────────────────────────────

  Future<List<int>> getFavoriteUniversityIds(String userId) async {
    final data = await _client
        .from('university_favorites')
        .select('university_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['university_id'] as int).toList();
  }

  Future<List<UniversityModel>> getFavoriteUniversities(String userId) async {
    final data = await _client
        .from('university_favorites')
        .select('university_id, created_at, universities(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<UniversityModel> universities = [];
    for (final row in (data as List)) {
      final uniData = row['universities'];
      if (uniData == null) continue;
      universities.add(
        UniversityModel.fromSupabase(Map<String, dynamic>.from(uniData as Map)),
      );
    }
    return universities;
  }

  Future<void> addUniversityFavorite(String userId, int universityId) async {
    await _client.from('university_favorites').insert({
      'user_id': userId,
      'university_id': universityId,
    });
  }

  // ─── Home RPC Bundle'ları ─────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getHomeUniversityStats() async {
    final data = await _client.rpc('get_home_university_stats');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>?> getHomeVideoSections() async {
    final data = await _client.rpc('get_home_video_sections');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> removeUniversityFavorite(String userId, int universityId) async {
    await _client
        .from('university_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('university_id', universityId);
  }

  Future<bool> isUniversityFavorited(String userId, int universityId) async {
    final data = await _client
        .from('university_favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('university_id', universityId)
        .maybeSingle();
    return data != null;
  }

  // ─── FCM Token Yönetimi ──────────────────────────────────────────────────

  Future<void> upsertFcmToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    await _client.from('fcm_tokens').upsert({
      'user_id': userId,
      'token': token,
      'platform': platform,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,token');
  }

  Future<void> deleteFcmToken({
    required String userId,
    required String token,
  }) async {
    await _client
        .from('fcm_tokens')
        .delete()
        .eq('user_id', userId)
        .eq('token', token);
  }

  Future<void> deleteAllFcmTokens(String userId) async {
    await _client.from('fcm_tokens').delete().eq('user_id', userId);
  }

  // ─── Profil Görünürlüğü ───────────────────────────────────────────────────

  Future<void> updateProfileVisibility(String userId, String visibility) async {
    await _client
        .from('profiles')
        .update({'profile_visibility': visibility})
        .eq('id', userId);
  }

  // ─── Takip Sistemi ────────────────────────────────────────────────────────

  Future<void> followUser({
    required String followerId,
    required String followingId,
    bool requireApproval = false,
  }) async {
    await _client.from('user_follows').insert({
      'follower_id': followerId,
      'following_id': followingId,
      'status': requireApproval ? 'pending' : 'accepted',
    });
  }

  Future<void> unfollowUser({
    required String followerId,
    required String followingId,
  }) async {
    await _client
        .from('user_follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', followingId);
  }

  Future<Map<String, dynamic>?> getFollowStatus({
    required String followerId,
    required String followingId,
  }) async {
    return await _client
        .from('user_follows')
        .select()
        .eq('follower_id', followerId)
        .eq('following_id', followingId)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> getFollowers(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('user_follows')
        .select('''
          id, follower_id, following_id, status, created_at,
          follower_profile:profiles!follower_id (
            id, username, full_name, avatar_url, profile_visibility
          )
        ''')
        .eq('following_id', userId)
        .eq('status', 'accepted')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getFollowing(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('user_follows')
        .select('''
          id, follower_id, following_id, status, created_at,
          following_profile:profiles!following_id (
            id, username, full_name, avatar_url, profile_visibility
          )
        ''')
        .eq('follower_id', userId)
        .eq('status', 'accepted')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getFollowCounts(String userId) async {
    return await _client
        .from('user_follow_counts')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> getPendingFollowRequests(
    String userId, {
    int limit = 50,
  }) async {
    final data = await _client
        .from('user_follows')
        .select('''
          id, follower_id, following_id, status, created_at,
          follower_profile:profiles!follower_id (
            id, username, full_name, avatar_url
          )
        ''')
        .eq('following_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> acceptFollowRequest(String followId) async {
    await _client
        .from('user_follows')
        .update({'status': 'accepted'})
        .eq('id', followId);
  }

  Future<void> rejectFollowRequest(String followId) async {
    await _client.from('user_follows').delete().eq('id', followId);
  }

  Future<Map<String, dynamic>?> getPublicProfile(String userId) async {
    return await _client
        .from('profiles')
        .select(
          'id, username, full_name, avatar_url, profile_visibility, created_at',
        )
        .eq('id', userId)
        .maybeSingle();
  }
}