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
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
    } catch (e, stackTrace) {
      log('Kayıt olurken hata oluştu: $e\n$stackTrace');
      throw Exception('Kayıt işlemi başarısız oldu. Lütfen tekrar deneyin.');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e, stackTrace) {
      log('Giriş yapılırken hata oluştu: $e\n$stackTrace');
      throw Exception('Giriş işlemi başarısız oldu. Lütfen tekrar deneyin.');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e, stackTrace) {
      log('Çıkış yapılırken hata oluştu: $e\n$stackTrace');
      throw Exception('Çıkış işlemi başarısız oldu. Lütfen tekrar deneyin.');
    }
  }

  // Profil
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;

      return ProfileModel.fromSupabase(data);
    } catch (e, stackTrace) {
      log('Profil getirilirken hata oluştu: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _client
          .from('profiles')
          .update(profile.toSupabase())
          .eq('id', profile.id);
    } catch (e, stackTrace) {
      log('Profil güncellenirken hata oluştu: $e\n$stackTrace');
      throw Exception('Profil güncellenemedi. Lütfen tekrar deneyin.');
    }
  }

  // Ayarlar
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    try {
      final data = await _client
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserSettingsModel.fromSupabase(data);
    } catch (e, stackTrace) {
      log('Kullanıcı ayarları getirilirken hata oluştu: $e\n$stackTrace');
      return null;
    }
  }

  Future<void> updateUserSettings(UserSettingsModel settings) async {
    try {
      await _client
          .from('user_settings')
          .update(settings.toSupabase())
          .eq('user_id', settings.userId);
    } catch (e, stackTrace) {
      log('Kullanıcı ayarları güncellenirken hata oluştu: $e\n$stackTrace');
      throw Exception('Ayarlar güncellenemedi. Lütfen tekrar deneyin.');
    }
  }

  // ─── Üniversiteler ────────────────────────────────────────────────────────
  Future<List<UniversityModel>> getUniversities({int limit = 500}) async {
    try {
      final data = await _client
          .from('universities')
          .select()
          .order('name', ascending: true)
          .limit(limit);
      return (data as List)
          .map((e) => UniversityModel.fromSupabase(e))
          .toList();
    } catch (e, stackTrace) {
      log('Üniversiteler getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Üniversiteler yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<UniversityModel> getUniversityById(int id) async {
    try {
      final data = await _client
          .from('universities')
          .select()
          .eq('id', id)
          .single();
      return UniversityModel.fromSupabase(data);
    } catch (e, stackTrace) {
      log('Üniversite getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Üniversite bulunamadı. Lütfen tekrar deneyin.');
    }
  }

  // ─── Video Cache ──────────────────────────────────────────────────────────

  Future<VideoModel?> getVideoById(String videoId) async {
    try {
      final data = await _client
          .from('videos_cache_with_engagement')
          .select()
          .eq('video_id', videoId)
          .maybeSingle();

      if (data == null) return null;

      return VideoModel.fromSupabase(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      log('Video getirilirken hata oluştu: $e\n$stackTrace');
      return null;
    }
  }

  Future<List<VideoModel>> getCachedVideos({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
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
    } catch (e, stackTrace) {
      log(
        'Önbelleğe alınmış videolar getirilirken hata oluştu: $e\n$stackTrace',
      );
      throw Exception('Videolar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  /// FIX: `videos_cache` tablosunda app_view_count/app_like_count vb. kolonlar
  /// yok — bu yüzden üniversite detay sayfasındaki videolar her zaman 0
  /// görünüyordu. Artık `videos_cache_with_engagement` view'inden okunuyor
  /// (video_engagement_stats matview'i ile JOIN'lenmiş, university_name dahil).
  Future<List<VideoModel>> getCachedVideosByUniversity(
    int universityId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = await _client
          .from('videos_cache_with_engagement')
          .select()
          .eq('university_id', universityId)
          .order('published_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data)
          .map((e) => VideoModel.fromSupabase(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stackTrace) {
      log('Üniversite videoları getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception(
        'Üniversite videoları yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<List<VideoModel>> getLatestVideoPerUniversity({
    int limit = 500,
    int offset = 0,
  }) async {
    try {
      final data = await _client
          .from('latest_videos_per_university')
          .select()
          .order('published_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List).map((e) => VideoModel.fromSupabase(e)).toList();
    } catch (e, stackTrace) {
      log(
        'Üniversitelere ait son videolar getirilirken hata oluştu: $e\n$stackTrace',
      );
      throw Exception('Videolar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  /// Her üniversiteden en son 1 shorts videoyu çeker.
  /// Sayfalama destekli: her çağrıda [limit] adet, [offset]'ten itibaren gelir.
  /// Sıralama deterministiktir (published_at DESC, video_id ASC) — sayfalar
  /// arasında tekrar/atlama olmaz.
  Future<List<ShortsModel>> getShortsPerUniversity({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final data = await _client.rpc(
        'get_shorts_per_university',
        params: {'p_limit': limit, 'p_offset': offset},
      );
      return (data as List)
          .map((e) => ShortsModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stackTrace) {
      log('Üniversite shortsları getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Shortslar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<void> upsertVideos(List<VideoModel> videos) async {
    try {
      final data = videos.map((v) => v.toSupabase()).toList();
      await _client.from('videos_cache').upsert(data, onConflict: 'video_id');
    } catch (e, stackTrace) {
      log('Videolar kaydedilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Videolar kaydedilemedi. Lütfen tekrar deneyin.');
    }
  }

  // ─── Favoriler ────────────────────────────────────────────────────────────
  // FIX: Eskiden sabit limit=20 ile çağrılıyordu ve hiç sıralama yoktu. Bu
  // fonksiyon, ana ekrandaki kalp ikonunun "favorilenmiş mi" durumunu belirleyen
  // TEK kaynak (favoriteIds set'i) — 20'den fazla favorisi olan kullanıcılarda
  // 21. ve sonrası "favorilenmemiş" görünüyordu. Tekrar kalbe basınca da
  // UNIQUE(user_id, video_id) ihlali sessizce hata fırlatıyordu. Bu sadece
  // üyelik kontrolü (Set.contains) için kullanıldığından, ID'leri sayfalama
  // olmadan TAMAMINI çekiyoruz — sadece video_id kolonu olduğu için maliyeti
  // ihmal edilebilir düzeyde.
  Future<List<String>> getFavoriteVideoIds(String userId) async {
    try {
      final data = await _client
          .from('favorites')
          .select('video_id')
          .eq('user_id', userId);
      // NULL video_id'li satırlar (örn. silinmiş video referansı) güvenle
      // atlanır; tek bir bozuk satır yüzünden tüm favori listesi kaybolmasın.
      return (data as List)
          .map((e) => e['video_id'] as String?)
          .whereType<String>()
          .toList();
    } catch (e, stackTrace) {
      log('Favori videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Favori videolar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<List<VideoModel>> getUserFavoriteVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
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
      return _attachEngagement(videos);
    } catch (e, stackTrace) {
      log('Favori videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Favori videolar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  // FIX: Eskiden düz insert kullanılıyordu — limit hatası düzelse de, stale
  // local cache / çift dokunma gibi yarış durumlarında UNIQUE(user_id, video_id)
  // ihlali fırlatıp toggleFavorite() içinde sessizce yutuluyordu (kalp donmuş
  // kalıyordu). ignoreDuplicates: true ile bu işlem artık idempotent — kayıt
  // zaten varsa hata fırlatmadan sessizce no-op olur.
  Future<void> addFavorite(String userId, String videoId) async {
    try {
      await _client
          .from('favorites')
          .upsert(
            {'user_id': userId, 'video_id': videoId},
            onConflict: 'user_id,video_id',
            ignoreDuplicates: true,
          );
    } catch (e, stackTrace) {
      log('Favori eklenirken hata oluştu: $e\n$stackTrace');
      throw Exception('Favori eklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<void> removeFavorite(String userId, String videoId) async {
    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('video_id', videoId);
    } catch (e, stackTrace) {
      log('Favori kaldırılırken hata oluştu: $e\n$stackTrace');
      throw Exception('Favori kaldırılamadı. Lütfen tekrar deneyin.');
    }
  }

  // ─── Yorumlar ─────────────────────────────────────────────────────────────
  Future<List<CommentModel>> getComments(
    String videoId, {
    int limit = 200,
    int offset = 0,
  }) async {
    try {
      final data = await _client
          .from('comments')
          .select('*, profiles(username, avatar_url)')
          .eq('video_id', videoId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return (data as List).map((e) => CommentModel.fromSupabase(e)).toList();
    } catch (e, stackTrace) {
      log('Yorumlar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Yorumlar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<void> addComment(String userId, String videoId, String content) async {
    try {
      await _client.from('comments').insert({
        'user_id': userId,
        'video_id': videoId,
        'content': content,
      });
    } catch (e, stackTrace) {
      log('Yorum eklenirken hata oluştu: $e\n$stackTrace');
      throw Exception('Yorum eklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _client.from('comments').delete().eq('id', commentId);
    } catch (e, stackTrace) {
      log('Yorum silinirken hata oluştu: $e\n$stackTrace');
      throw Exception('Yorum silinemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<void> updateComment(String commentId, String content) async {
    try {
      await _client
          .from('comments')
          .update({
            'content': content,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', commentId);
    } catch (e, stackTrace) {
      log('Yorum güncellenirken hata oluştu: $e\n$stackTrace');
      throw Exception('Yorum güncellenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<List<VideoModel>> getUserCommentedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
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
    } catch (e, stackTrace) {
      log('Yorum yapılan videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception(
        'Yorum yapılan videolar yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  // ─── Üniversiteler + İstatistikler ───────────────────────────────────────
  //
  // View; universities tablosundaki tüm kolonları + favorite_count + thumbnail_url içerir.
  // NOT: Bu view 'universities_with_stats' isminden 'universities_list_view'
  // olarak yeniden adlandırıldı (ağır 'university_leaderboard_mat' ile
  // isim karışıklığını önlemek için).

  Future<List<Map<String, dynamic>>> getUniversitiesWithVideoCount({
    int limit = 500,
  }) async {
    try {
      final data = await _client
          .from('universities_list_view')
          .select('*')
          .order('name', ascending: true)
          .limit(limit);

      return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e, stackTrace) {
      log(
        'Üniversiteler ve video sayıları getirilirken hata oluştu: $e\n$stackTrace',
      );
      throw Exception('Üniversiteler yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<List<Map<String, dynamic>>> getUniversitiesWithStats({
    int limit = 500,
  }) async {
    try {
      return await getUniversitiesWithVideoCount(limit: limit);
    } catch (e, stackTrace) {
      log(
        'Üniversite istatistikleri getirilirken hata oluştu: $e\n$stackTrace',
      );
      throw Exception(
        'Üniversite istatistikleri yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  // ─── Onboarding ──────────────────────────────────────────────────────────
  Future<bool> isOnboardingCompleted(String userId) async {
    try {
      final data = await _client
          .from('onboarding')
          .select('completed')
          .eq('user_id', userId)
          .maybeSingle();
      return data?['completed'] ?? false;
    } catch (e, stackTrace) {
      log('Onboarding durumu kontrol edilirken hata oluştu: $e\n$stackTrace');
      return false;
    }
  }

  Future<void> completeOnboarding(String userId) async {
    try {
      await _client.from('onboarding').upsert({
        'user_id': userId,
        'completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e, stackTrace) {
      log('Onboarding tamamlanırken hata oluştu: $e\n$stackTrace');
      throw Exception('Onboarding tamamlanamadı. Lütfen tekrar deneyin.');
    }
  }

  // ─── Arama ───────────────────────────────────────────────────────────────
  Future<List<VideoModel>> searchVideos(String query, {int limit = 30}) async {
    try {
      final data = await _client.rpc(
        'search_videos',
        params: {'search_term': query, 'result_limit': limit},
      );
      return (data as List)
          .map((e) => VideoModel.fromSupabase(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stackTrace) {
      log('Videolar aranırken hata oluştu: $e\n$stackTrace');
      throw Exception('Arama başarısız oldu. Lütfen tekrar deneyin.');
    }
  }

  // ─── Beğeni (likes) ──────────────────────────────────────────────────────
  Future<bool> isLiked(String userId, String videoId) async {
    try {
      final data = await _client
          .from('likes')
          .select('id')
          .eq('user_id', userId)
          .eq('video_id', videoId)
          .maybeSingle();
      return data != null;
    } catch (e, stackTrace) {
      log('Beğeni durumu kontrol edilirken hata oluştu: $e\n$stackTrace');
      return false;
    }
  }

  Future<void> addLike(String userId, String videoId) async {
    try {
      await _client
          .from('likes')
          .upsert(
            {'user_id': userId, 'video_id': videoId},
            onConflict: 'user_id,video_id',
            ignoreDuplicates: true,
          );
    } catch (e, stackTrace) {
      log('Beğeni eklenirken hata oluştu: $e\n$stackTrace');
      throw Exception('Beğeni eklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<void> removeLike(String userId, String videoId) async {
    try {
      await _client
          .from('likes')
          .delete()
          .eq('user_id', userId)
          .eq('video_id', videoId);
    } catch (e, stackTrace) {
      log('Beğeni kaldırılırken hata oluştu: $e\n$stackTrace');
      throw Exception('Beğeni kaldırılamadı. Lütfen tekrar deneyin.');
    }
  }

  Future<void> removeView(String userId, String videoId) async {
    try {
      await _client
          .from('content_views')
          .delete()
          .eq('user_id', userId)
          .eq('video_id', videoId);
    } catch (e, stackTrace) {
      log('İzleme kaydı silinirken hata oluştu: $e\n$stackTrace');
      throw Exception('İzleme kaydı silinemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<void> removeShared(String userId, String videoId) async {
    try {
      await _client
          .from('shared')
          .delete()
          .eq('user_id', userId)
          .eq('video_id', videoId);
    } catch (e, stackTrace) {
      log('Paylaşım kaydı silinirken hata oluştu: $e\n$stackTrace');
      throw Exception('Paylaşım kaydı silinemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<void> removeCommentsByVideo(String userId, String videoId) async {
    try {
      await _client
          .from('comments')
          .delete()
          .eq('user_id', userId)
          .eq('video_id', videoId);
    } catch (e, stackTrace) {
      log('Yorumlar silinirken hata oluştu: $e\n$stackTrace');
      throw Exception('Yorumlar silinemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<Set<String>> getLikedVideoIds(String userId) async {
    try {
      final data = await _client
          .from('likes')
          .select('video_id')
          .eq('user_id', userId)
          .not('video_id', 'is', null);

      return (data as List<dynamic>)
          .map((row) => row['video_id'] as String?)
          .whereType<String>()
          .toSet();
    } catch (e, stackTrace) {
      log('Beğenilen videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Beğenilen videolar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<Set<String>> getSharedVideoIds(String userId) async {
    try {
      final data = await _client
          .from('shared')
          .select('video_id')
          .eq('user_id', userId)
          .not('video_id', 'is', null);
      return (data as List<dynamic>)
          .map((row) => row['video_id'] as String?)
          .whereType<String>()
          .toSet();
    } catch (e, stackTrace) {
      log('Paylaşılan videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception(
        'Paylaşılan videolar yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<Set<String>> getCommentedVideoIds(String userId) async {
    try {
      final data = await _client
          .from('comments')
          .select('video_id')
          .eq('user_id', userId)
          .not('video_id', 'is', null);
      return (data as List<dynamic>)
          .map((row) => row['video_id'] as String?)
          .whereType<String>()
          .toSet();
    } catch (e, stackTrace) {
      log('Yorum yapılan videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception(
        'Yorum yapılan videolar yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  // ─── Görüntüleme (content_views) ─────────────────────────────────────────
  // FIX: Eskiden upsert sonrası her zaman "yeni izleyici" sayılıyordu, ama
  // unique(user_id, video_id) sayesinde tekrar izlemede satır eklenmiyor,
  // sadece updated_at güncelleniyordu — bu yüzden ekrandaki sayaç gerçekte
  // artmayan bir şeyi artırıyordu. created_at == updated_at ise satır az önce
  // İLK KEZ oluşturuldu (ikisi de aynı INSERT içinde now() ile dolduruldu);
  // farklıysa zaten var olan satır güncellendi (tekrar izleme, yeni izleyici
  // değil). Dönen bool, çağırana "bu gerçekten yeni bir izleyici mi" bilgisini verir.
  Future<bool> recordView(String userId, String videoId) async {
    try {
      final result = await _client
          .from('content_views')
          .upsert({
            'user_id': userId,
            'video_id': videoId,
          }, onConflict: 'user_id,video_id')
          .select('created_at, updated_at')
          .single();

      return result['created_at'] == result['updated_at'];
    } catch (e, stackTrace) {
      log('İzlenme kaydedilirken hata oluştu: $e\n$stackTrace');
      return false;
    }
  }

  Future<List<VideoModel>> getUserViewedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
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
      return _attachEngagement(videos);
    } catch (e, stackTrace) {
      log('İzlenen videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('İzlenen videolar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  // ─── Paylaşım (shared) ───────────────────────────────────────────────────
  Future<void> recordShare(String userId, String videoId) async {
    try {
      await _client.from('shared').upsert({
        'user_id': userId,
        'video_id': videoId,
      }, onConflict: 'user_id,video_id');
    } catch (e, stackTrace) {
      log('Paylaşım kaydedilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Paylaşım kaydedilemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<List<VideoModel>> getUserSharedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
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
      return _attachEngagement(videos);
    } catch (e, stackTrace) {
      log('Paylaşılan videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception(
        'Paylaşılan videolar yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<List<VideoModel>> getUserLikedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = await _client
          .from('likes')
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
      return _attachEngagement(videos);
    } catch (e, stackTrace) {
      log('Beğenilen videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception(
        'Beğenilen videolar yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  // FIX: favorites/content_views/shared tabloları 'videos_cache' tablosuna
  // FK ile bağlı olduğu için PostgREST embed'i doğrudan 'videos_cache'
  // tablosundan yapılıyor — ama bu tabloda app_view_count/app_like_count vb.
  // kolonlar YOK. Bu yüzden Profil sayfasındaki Favorilerim/İzlediklerim/
  // Paylaştıklarım sekmelerinde görüntülenme & beğeni sayısı her zaman 0
  // görünüyordu. Burada video_id'leri tek seferde 'video_engagement_live'
  // (canlı, anlık hesaplanan view) üzerinden çekip eşleştiriyoruz.
  Future<List<VideoModel>> _attachEngagement(List<VideoModel> videos) async {
    if (videos.isEmpty) return videos;
    final ids = videos.map((v) => v.videoId).toSet().toList();
    try {
      final stats = await _client
          .from('video_engagement_live')
          .select(
            'video_id, app_view_count, app_like_count, app_favorite_count, app_share_count, app_comment_count',
          )
          .inFilter('video_id', ids);

      final statsMap = <String, Map<String, dynamic>>{
        for (final row in (stats as List))
          row['video_id'] as String: Map<String, dynamic>.from(row),
      };

      return videos.map((v) {
        final s = statsMap[v.videoId];
        if (s == null) return v;
        return v.copyWith(
          appViewCount: (s['app_view_count'] as num?)?.toInt() ?? 0,
          appLikeCount: (s['app_like_count'] as num?)?.toInt() ?? 0,
          appFavoriteCount: (s['app_favorite_count'] as num?)?.toInt() ?? 0,
          appShareCount: (s['app_share_count'] as num?)?.toInt() ?? 0,
          appCommentCount: (s['app_comment_count'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e, stackTrace) {
      log('Etkileşim verileri eklenirken hata oluştu: $e\n$stackTrace');
      return videos;
    }
  }

  // ─── Etkileşim İstatistikleri ─────────────────────────────────────────────
  // FIX: Eskiden 'video_engagement_stats' (MATERIALIZED VIEW) okunuyordu;
  // bu view sadece pg_cron ile 10 dakikada bir yenileniyordu. Bir kullanıcı
  // videoyu izleyip hemen istatistiklere bakınca (recordView -> hemen ardından
  // getEngagementStats) her zaman GÜNCELLENMEMİŞ (genelde 0) veri görüyordu.
  // 'video_engagement_live' her sorguda anlık hesaplanan normal bir VIEW'dir,
  // bu yüzden gecikme olmaz.
  Future<Map<String, int>> getEngagementStats(String videoId) async {
    try {
      final data = await _client
          .from('video_engagement_live')
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
        'app_favorite_count':
            (data['app_favorite_count'] as num?)?.toInt() ?? 0,
        'app_share_count': (data['app_share_count'] as num?)?.toInt() ?? 0,
        'app_comment_count': (data['app_comment_count'] as num?)?.toInt() ?? 0,
      };
    } catch (e, stackTrace) {
      log('Etkileşim istatistikleri getirilirken hata oluştu: $e\n$stackTrace');
      return {
        'app_view_count': 0,
        'app_like_count': 0,
        'app_favorite_count': 0,
        'app_share_count': 0,
        'app_comment_count': 0,
      };
    }
  }

  // ─── Kullanıcı İstatistikleri ─────────────────────────────────────────────
  Future<Map<String, dynamic>?> getMyStats() async {
    try {
      final data = await _client.rpc('get_my_stats');
      if (data == null || (data as List).isEmpty) return null;
      // ignore: unnecessary_cast
      return Map<String, dynamic>.from((data as List).first as Map);
    } catch (e, stackTrace) {
      log('Kullanıcı istatistikleri getirilirken hata oluştu: $e\n$stackTrace');
      return null;
    }
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
    try {
      var query = _client.from('university_leaderboard_mat').select();

      if (filterColumn != null &&
          filterOperator != null &&
          filterValue != null) {
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
          .map(
            (e) => UniversityStatsModel.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList();
    } catch (e, stackTrace) {
      log(
        'Üniversite istatistik listesi getirilirken hata oluştu: $e\n$stackTrace',
      );
      throw Exception(
        'Üniversite istatistikleri yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
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
    try {
      var query = _client.from('video_engagement_stats').select();

      if (filterColumn != null &&
          filterOperator != null &&
          filterValue != null) {
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
    } catch (e, stackTrace) {
      log('Video etkileşim listesi getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception(
        'Video etkileşim verileri yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingVideos({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      return await getVideoEngagementList(
        orderBy: 'trending_score',
        limit: limit,
        offset: offset,
      );
    } catch (e, stackTrace) {
      log('Trend videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Trend videolar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<List<Map<String, dynamic>>> getMostWatchedVideos({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      return await getVideoEngagementList(
        orderBy: 'yt_view_count',
        limit: limit,
        offset: offset,
      );
    } catch (e, stackTrace) {
      log('En çok izlenen videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception(
        'En çok izlenen videolar yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  // ─── Öneri Sistemi ────────────────────────────────────────────────────────
  Future<List<VideoModel>> getSuggestedVideos(String videoId) async {
    try {
      final data = await _client.rpc(
        'get_suggested_videos',
        params: {'current_video_id': videoId},
      );
      return (data as List)
          .map((e) => VideoModel.fromSupabase(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stackTrace) {
      log('Önerilen videolar getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Önerilen videolar yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<List<Map<String, dynamic>>> getMostLikedVideos({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      return await getVideoEngagementList(
        orderBy: 'app_like_count',
        filterColumn: 'app_like_count',
        filterOperator: 'gt',
        filterValue: 0,
        limit: limit,
        offset: offset,
      );
    } catch (e, stackTrace) {
      log(
        'En çok beğenilen videolar getirilirken hata oluştu: $e\n$stackTrace',
      );
      throw Exception(
        'En çok beğenilen videolar yüklenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<List<VideoViewerModel>> getVideoViewers(
    String videoId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final data = await _client.rpc(
        'get_video_viewers',
        params: {'p_video_id': videoId, 'p_limit': limit, 'p_offset': offset},
      );
      return (data as List)
          .map((e) => VideoViewerModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stackTrace) {
      log('Video izleyicileri getirilirken hata oluştu: $e\n$stackTrace');
      throw Exception('Video izleyicileri yüklenemedi. Lütfen tekrar deneyin.');
    }
  }

  Future<List<Map<String, dynamic>>> getMostFavoritedVideos({
    int limit = 10,
    int offset = 0,
  }) {
    try {
      return getVideoEngagementList(
        orderBy: 'app_favorite_count',
        filterColumn: 'app_favorite_count',
        filterOperator: 'gt',
        filterValue: 0,
        limit: limit,
        offset: offset,
      );
    } catch (e, stacktrace) {
      log(
        'En çok favorilenen videolar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMostCommentedVideos({
    int limit = 10,
    int offset = 0,
  }) {
    try {
      return getVideoEngagementList(
        orderBy: 'app_comment_count',
        filterColumn: 'app_comment_count',
        filterOperator: 'gt',
        filterValue: 0,
        limit: limit,
        offset: offset,
      );
    } catch (e, stacktrace) {
      log(
        'En çok yorum alan videolar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  /// Keseßilmemiş videolar (app_view_count = 0).
  /// useRandomSampling=true VE offset == 0 ise rastgele örnekleme yap
  /// (sadece ana ekran section'ı için — her refresh'te farklı videolar).
  /// Detay sayfası (video_section_detail) useRandomSampling=false geçer,
  /// böylece "Tümünü Gör" ana ekranda gösterilenle aynı, deterministik
  /// sırayla başlar; offset > 0 zaten her zaman deterministiktir.
  Future<List<Map<String, dynamic>>> getNewAndUndiscoveredVideos({
    int limit = 10,
    int offset = 0,
    bool useRandomSampling = true,
  }) async {
    try {
      if (offset > 0 || !useRandomSampling) {
        return await getVideoEngagementList(
          orderBy: 'published_at',
          filterColumn: 'app_view_count',
          filterOperator: 'eq',
          filterValue: 0,
          limit: limit,
          offset: offset,
        );
      }
      // Ana ekran: rastgele örnekleme — get_new_undiscovered_videos RPC
      try {
        final data = await _client.rpc(
          'get_new_undiscovered_videos',
          params: {'p_limit': limit},
        );
        return List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
      } catch (e, stacktrace) {
        log(
          'RPC ile yeni ve keşfedilmemiş videolar getirilirken hata oluştu: $e',
          error: e,
          stackTrace: stacktrace,
        );
        // Fallback: published_at siralaması
        return await getVideoEngagementList(
          orderBy: 'published_at',
          filterColumn: 'app_view_count',
          filterOperator: 'eq',
          filterValue: 0,
          limit: limit,
          offset: 0,
        );
      }
    } catch (e, stacktrace) {
      log(
        'Yeni ve keşfedilmemiş videolar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  // ─── Üniversite Favorileri ────────────────────────────────────────────────

  Future<List<int>> getFavoriteUniversityIds(String userId) async {
    try {
      final data = await _client
          .from('university_favorites')
          .select('university_id')
          .eq('user_id', userId);
      return (data as List).map((e) => e['university_id'] as int).toList();
    } catch (e, stacktrace) {
      log(
        'Favori üniversite ID\'leri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<List<UniversityModel>> getFavoriteUniversities(String userId) async {
    try {
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
          UniversityModel.fromSupabase(
            Map<String, dynamic>.from(uniData as Map),
          ),
        );
      }
      return universities;
    } catch (e, stacktrace) {
      log(
        'Favori üniversiteler getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> addUniversityFavorite(String userId, int universityId) async {
    try {
      await _client
          .from('university_favorites')
          .upsert(
            {'user_id': userId, 'university_id': universityId},
            onConflict: 'user_id,university_id',
            ignoreDuplicates: true,
          );
    } catch (e, stacktrace) {
      log(
        'Üniversite favorilere eklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  // ─── Home RPC Bundle'ları ─────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getHomeUniversityStats() async {
    try {
      final data = await _client.rpc('get_home_university_stats');
      if (data == null) return null;
      return Map<String, dynamic>.from(data as Map);
    } catch (e, stacktrace) {
      log(
        'Ana sayfa üniversite istatistikleri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getHomeVideoSections() async {
    try {
      final data = await _client.rpc('get_home_video_sections');
      if (data == null) return null;
      return Map<String, dynamic>.from(data as Map);
    } catch (e, stacktrace) {
      log(
        'Ana sayfa video bölümleri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> removeUniversityFavorite(String userId, int universityId) async {
    try {
      await _client
          .from('university_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('university_id', universityId);
    } catch (e, stacktrace) {
      log(
        'Üniversite favorilerden çıkarılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<bool> isUniversityFavorited(String userId, int universityId) async {
    try {
      final data = await _client
          .from('university_favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('university_id', universityId)
          .maybeSingle();
      return data != null;
    } catch (e, stacktrace) {
      log(
        'Üniversite favori kontrolü yapılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  // ─── FCM Token Yönetimi ──────────────────────────────────────────────────

  Future<void> upsertFcmToken({
    required String userId,
    required String token,
    required String platform,
  }) async {
    try {
      await _client.from('fcm_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': platform,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token');
    } catch (e, stacktrace) {
      log(
        'FCM token kaydedilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> deleteFcmToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _client
          .from('fcm_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('token', token);
    } catch (e, stacktrace) {
      log(
        'FCM token silinirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> deleteAllFcmTokens(String userId) async {
    try {
      await _client.from('fcm_tokens').delete().eq('user_id', userId);
    } catch (e, stacktrace) {
      log(
        'Kullanıcının tüm FCM tokenları silinirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  // ─── Profil Görünürlüğü ───────────────────────────────────────────────────

  Future<void> updateProfileVisibility(String userId, String visibility) async {
    try {
      await _client
          .from('profiles')
          .update({'profile_visibility': visibility})
          .eq('id', userId);
    } catch (e, stacktrace) {
      log(
        'Profil görünürlüğü güncellenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }
  /* // ─── Takip Sistemi ────────────────────────────────────────────────────────

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
  } */

  Future<Map<String, dynamic>?> getPublicProfile(String userId) async {
    try {
      return await _client
          .from('profiles')
          .select(
            'id, username, full_name, avatar_url, created_at, profile_visibility',
          )
          .eq('id', userId)
          .maybeSingle();
    } catch (e, stacktrace) {
      log(
        'Profil bilgileri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }
}