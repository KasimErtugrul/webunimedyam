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
  Future<List<UniversityModel>> getUniversities({int limit = 500}) async {
    final data = await _client
        .from('universities')
        .select()
        .order('name', ascending: true)
        .limit(limit); // FIX: Pagination
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

  // FIX: Tüm listelere limit ve offset eklendi.
  Future<List<VideoModel>> getCachedVideos({
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('videos_cache')
        .select('*, universities(name)')
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1); // FIX: Pagination

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
        .range(offset, offset + limit - 1); // FIX: Pagination

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
        .range(offset, offset + limit - 1); // FIX: Pagination

    return (data as List).map((e) => VideoModel.fromSupabase(e)).toList();
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
        .limit(limit); // FIX: Pagination
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
        .range(offset, offset + limit - 1); // FIX: Pagination

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
        .range(offset, offset + limit - 1); // FIX: Pagination
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
        .range(offset, offset + limit - 1); // FIX: Pagination

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
  Future<List<Map<String, dynamic>>> getUniversitiesWithVideoCount({
    int limit = 500,
  }) async {
    final data = await _client
        .from('universities_with_stats')
        .select('*')
        .order('name', ascending: true)
        .limit(limit); // FIX: Pagination

    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getUniversitiesWithStats({
    int limit = 500,
  }) => getUniversitiesWithVideoCount(limit: limit);

  // ─── Onboarding ──────────────────────────────────────────────────────────
  Future<bool> isOnboardingCompleted(String userId) async {
    final data = await _client
        .from('onboarding')
        .select('completed')
        .eq('user_id', userId)
        .maybeSingle();
    return data?['completed'] ?? false;
  }

  // lib/data/datasources/remote/supabase_datasource.dart
  Future<void> completeOnboarding(String userId) async {
    await _client.from('onboarding').upsert(
      // ← update → upsert
      {
        'user_id': userId, // ← id alanı eklendi
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
        .range(offset, offset + limit - 1); // FIX: Pagination

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
        .range(offset, offset + limit - 1); // FIX: Pagination

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

  // ─── Üniversite İstatistikleri ───────────────────────────────────────────
  // FIX: String filter hack'i kaldırıldı. Tip güvenli parametreler eklendi.
  Future<List<UniversityStatsModel>> getUniversityStatsList({
    required String orderBy,
    int limit = 10,
    int offset = 0,
    String? filterColumn,
    String? filterOperator, // 'gt', 'lt', 'eq', 'gte', 'lte', 'neq'
    dynamic filterValue,
  }) async {
    var query = _client.from('university_stats').select();

    // Tip güvenli filtreleme
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
        .range(offset, offset + limit - 1); // FIX: Pagination eklendi

    return (data as List)
        .map((e) => UniversityStatsModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ─── Video Engagement Stats ───────────────────────────────────────────────

  /// FIX: String filter hack'i kaldırıldı. Tip güvenli filtreleme ve tam pagination eklendi.
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

    // Tip güvenli filtreleme
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
        .range(offset, offset + limit - 1); // FIX: Pagination

    return List<Map<String, dynamic>>.from(data);
  }

  // Seksiyon bazlı wrapper metodlar (Eski hatalı string filter yerine tip güvenli hale getirildi)

  Future<List<Map<String, dynamic>>> getTrendingVideos({
    int limit = 10,
    int offset = 0,
  }) => getVideoEngagementList(
    orderBy: 'engagement_score',
    limit: limit,
    offset: offset,
  );

  Future<List<Map<String, dynamic>>> getMostWatchedVideos({
    int limit = 10,
    int offset = 0,
  }) => getVideoEngagementList(
    orderBy: 'yt_view_count',
    limit: limit,
    offset: offset,
  );

  Future<List<Map<String, dynamic>>> getMostLikedVideos({
    int limit = 10,
    int offset = 0,
  }) => getVideoEngagementList(
    orderBy: 'app_like_count',
    filterColumn: 'app_like_count',
    filterOperator: 'gt',
    filterValue: 0,
    limit: limit,
    offset: offset,
  );

  Future<List<Map<String, dynamic>>> getMostFavoritedVideos({
    int limit = 10,
    int offset = 0,
  }) => getVideoEngagementList(
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
  }) => getVideoEngagementList(
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
  }) => getVideoEngagementList(
    orderBy: 'published_at',
    filterColumn: 'app_view_count',
    filterOperator: 'eq',
    filterValue: 0,
    limit: limit,
    offset: offset,
  );

  // ─── Üniversite Favorileri ────────────────────────────────────────────────────

  /// Kullanıcının favori üniversite id'lerini getirir.
  Future<List<int>> getFavoriteUniversityIds(String userId) async {
    final data = await _client
        .from('university_favorites')
        .select('university_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['university_id'] as int).toList();
  }

  /// Kullanıcının favori üniversitelerini tam model olarak getirir.
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

  /// Üniversiteyi favorilere ekler.
  Future<void> addUniversityFavorite(String userId, int universityId) async {
    await _client.from('university_favorites').insert({
      'user_id': userId,
      'university_id': universityId,
    });
  }

  // ─── Home RPC Bundle'ları ─────────────────────────────────────────────────

  /// 8 ayrı university_stats çağrısını tek RPC'ye indirgir.
  Future<Map<String, dynamic>?> getHomeUniversityStats() async {
    final data = await _client.rpc('get_home_university_stats');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// 6 ayrı video_engagement_stats çağrısını tek RPC'ye indirgir.
  Future<Map<String, dynamic>?> getHomeVideoSections() async {
    final data = await _client.rpc('get_home_video_sections');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Üniversiteyi favorilerden çıkarır.
  Future<void> removeUniversityFavorite(String userId, int universityId) async {
    await _client
        .from('university_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('university_id', universityId);
  }

  /// Tek bir üniversitenin favori durumunu kontrol eder.
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

  /// FCM token'ını Supabase'e upsert eder (ekle veya güncelle).
  Future<void> upsertFcmToken({
    required String userId,
    required String token,
    required String platform, // 'android' | 'ios' | 'web'
  }) async {
    await _client.from('fcm_tokens').upsert({
      'user_id': userId,
      'token': token,
      'platform': platform,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,token');
  }

  /// Belirli bir token'ı siler (logout veya token yenileme).
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

  /// Kullanıcıya ait tüm FCM token'larını siler.
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

  /// Bir kullanıcıyı takip et (insert)
  /// Hedef profil private ise status='pending', değilse 'accepted'
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

  /// Takibi bırak (delete)
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

  /// Mevcut kullanıcının followingId'yi takip edip etmediğini döner.
  /// null → takip yok, FollowModel → takip var (status: pending/accepted)
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

  /// Bir kullanıcının TAKİPÇİLERİNİ listeler (beni takip edenler)
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

  /// Bir kullanıcının TAKİP ETTİKLERİNİ listeler
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

  /// Kullanıcının takipçi ve takip edilen sayılarını döner
  Future<Map<String, dynamic>?> getFollowCounts(String userId) async {
    return await _client
        .from('user_follow_counts')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  /// Bekleyen takip isteklerini döner (sadece kendi hesabı için)
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

  /// Takip isteğini kabul et
  Future<void> acceptFollowRequest(String followId) async {
    await _client
        .from('user_follows')
        .update({'status': 'accepted'})
        .eq('id', followId);
  }

  /// Takip isteğini reddet (sil)
  Future<void> rejectFollowRequest(String followId) async {
    await _client.from('user_follows').delete().eq('id', followId);
  }

  /// Verilen userId'nin profilini username ile birlikte çek
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
