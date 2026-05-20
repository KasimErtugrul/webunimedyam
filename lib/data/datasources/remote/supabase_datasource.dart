import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// Bu fonksiyonun Amacı:
  /// Kullanıcı kaydı (sign-up) işlemi için Supabase'in auth.signUp metodunu kullanır. Kullanıcıdan email, password ve username bilgilerini alır ve bu bilgileri Supabase'e gönderir.
  /// Supabase, kullanıcıyı kaydeder ve doğrulama email'i gönderir (eğer email doğrulaması açıksa). Bu fonksiyon, kullanıcı kaydı sürecini başlatmak için kullanılır ve başarılı olursa yeni bir kullanıcı oluşturur. Eğer kayıt sırasında bir hata oluşursa, bu hatayı yakalayarak uygun şekilde ele alabilirsiniz (örneğin, kullanıcı zaten kayıtlıysa veya geçersiz bilgiler sağlanırsa).
  /// Kullanıcı girişi (sign-in) işlemi için Supabase'in auth.signInWithPassword metodunu kullanır. Kullanıcıdan email ve password bilgilerini alır ve bu bilgileri Supabase'e gönderir.
  /// Supabase, sağlanan email ve password bilgilerini doğrular. Eğer bilgiler doğruysa, kullanıcıyı giriş yapmış olarak işaretler ve bir oturum başlatır. Bu fonksiyon, kullanıcı girişi sürecini başlatmak için kullanılır ve başarılı olursa kullanıcıyı uygulamaya giriş yapmış olarak tanımlar. Eğer giriş sırasında bir hata oluşursa, bu hatayı yakalayarak uygun şekilde ele alabilirsiniz (örneğin, yanlış şifre veya kayıtlı olmayan email gibi durumlarda).
  /// Kullanıcı çıkışı (sign-out) işlemi için Supabase'in auth.signOut metodunu kullanır. Bu fonksiyon, mevcut kullanıcı oturumunu sonlandırır ve kullanıcıyı çıkış yapmış olarak işaretler. Kullanıcı çıkışı işlemi, kullanıcıların uygulamadan güvenli bir şekilde çıkmalarını sağlar ve genellikle kullanıcı arayüzünde bir "Çıkış Yap" düğmesi aracılığıyla tetiklenir. Bu fonksiyon çağrıldığında, Supabase oturumu temizler ve kullanıcıyı uygulamadan çıkarır.

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

  /// Bu fonksiyonun Amacı:
  /// Kullanıcı girişi (sign-in) işlemi için Supabase'in auth.signInWithPassword metodunu kullanır. Kullanıcıdan email ve password bilgilerini alır ve bu bilgileri Supabase'e gönderir.
  /// Supabase, sağlanan email ve password bilgilerini doğrular. Eğer bilgiler doğruysa, kullanıcıyı giriş yapmış olarak işaretler ve bir oturum başlatır. Bu fonksiyon, kullanıcı girişi sürecini başlatmak için kullanılır ve başarılı olursa kullanıcıyı uygulamaya giriş yapmış olarak tanımlar. Eğer giriş sırasında bir hata oluşursa, bu hatayı yakalayarak uygun şekilde ele alabilirsiniz (örneğin, yanlış şifre veya kayıtlı olmayan email gibi durumlarda).
  /// Kullanıcı çıkışı (sign-out) işlemi için Supabase'in auth.signOut metodunu kullanır. Bu fonksiyon, mevcut kullanıcı oturumunu sonlandırır ve kullanıcıyı çıkış yapmış olarak işaretler. Kullanıcı çıkışı işlemi, kullanıcıların uygulamadan güvenli bir şekilde çıkmalarını sağlar ve genellikle kullanıcı arayüzünde bir "Çıkış Yap" düğmesi aracılığıyla tetiklenir. Bu fonksiyon çağrıldığında, Supabase oturumu temizler ve kullanıcıyı uygulamadan çıkarır.
  /// Kullanıcı kaydı (sign-up) işlemi için Supabase'in auth.signUp metodunu kullanır. Kullanıcıdan email, password ve username bilgilerini alır ve bu bilgileri Supabase'e gönderir. Supabase, kullanıcıyı kaydeder ve doğrulama email'i gönderir (eğer email doğrulaması açıksa). Bu fonksiyon, kullanıcı kaydı sürecini başlatmak için kullanılır ve başarılı olursa yeni bir kullanıcı oluşturur. Eğer kayıt sırasında bir hata oluşursa, bu hatayı yakalayarak uygun şekilde ele alabilirsiniz (örneğin, kullanıcı zaten kayıtlıysa veya geçersiz bilgiler sağlanırsa).

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Profil
  /// Bu fonksiyonun Amacı:
  /// Kullanıcı profil bilgilerini almak için Supabase'in from('profiles').select() metodunu kullanır. Kullanıcı ID'si (userId) parametresi alır ve bu ID'ye sahip profil bilgilerini Supabase'ten çeker. Eğer belirtilen kullanıcı ID'sine sahip bir profil bulunmazsa, fonksiyon null döner. Bu fonksiyon, kullanıcıların profil bilgilerini görüntülemek veya düzenlemek gibi işlemler için kullanılabilir.
  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromSupabase(data);
  }

  /// Bu fonksiyonun Amacı:
  /// Kullanıcı profil bilgilerini güncellemek için Supabase'in from('profiles').update() metodunu kullanır. ProfileModel türünde bir profile parametresi alır ve bu profil bilgilerini Supabase'teki 'profiles' tablosunda günceller. Güncelleme işlemi, profilin ID'sine (profile.id) göre gerçekleştirilir. Bu fonksiyon, kullanıcıların profil bilgilerini düzenlemelerine olanak tanır ve başarılı bir şekilde çalıştığında, belirtilen profil bilgileri Supabase veritabanında güncellenir.
  Future<void> updateProfile(ProfileModel profile) async {
    await _client
        .from('profiles')
        .update(profile.toSupabase())
        .eq('id', profile.id);
  }

  // Ayarlar
  /// Bu fonksiyonun Amacı:
  /// Kullanıcı ayar bilgilerini almak için Supabase'in from('user_settings').select() metodunu kullanır. Kullanıcı ID'si (userId) parametresi alır ve bu ID'ye sahip ayar bilgilerini Supabase'ten çeker. Eğer belirtilen kullanıcı ID'sine sahip ayar bilgileri bulunmazsa, fonksiyon null döner. Bu fonksiyon, kullanıcıların uygulama içi tercihlerini veya diğer kişiselleştirilmiş ayarlarını görüntülemek veya düzenlemek gibi işlemler için kullanılabilir.
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    final data = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return UserSettingsModel.fromSupabase(data);
  }

  /// Bu fonksiyonun Amacı:
  /// Kullanıcı ayar bilgilerini güncellemek için Supabase'in from('user_settings').update() metodunu kullanır. UserSettingsModel türünde bir settings parametresi alır ve bu ayar bilgilerini Supabase'teki 'user_settings' tablosunda günceller. Güncelleme işlemi, ayarların user_id'sine (settings.userId) göre gerçekleştirilir. Bu fonksiyon, kullanıcıların uygulama içi tercihlerini veya diğer kişiselleştirilmiş ayarlarını düzenlemelerine olanak tanır ve başarılı bir şekilde çalıştığında, belirtilen ayar bilgileri Supabase veritabanında güncellenir.
  Future<void> updateUserSettings(UserSettingsModel settings) async {
    await _client
        .from('user_settings')
        .update(settings.toSupabase())
        .eq('user_id', settings.userId);
  }

  // ─── Üniversiteler ────────────────────────────────────────────────────────
  /// Bu fonksiyonun Amacı:
  /// Üniversite bilgilerini almak için Supabase'in from('universities').select() metodunu kullanır.
  /// Bu fonksiyon, 'universities' tablosundaki tüm üniversite kayıtlarını çeker ve bunları UniversityModel
  /// türünde bir liste olarak döner. Üniversiteler genellikle uygulamanın ana sayfasında veya üniversite
  /// seçimi gibi bölümlerde görüntülenir, bu nedenle bu fonksiyon, üniversite verilerini almak ve uygulama
  /// içinde kullanmak için temel bir veri kaynağı sağlar.
  ///
  Future<List<UniversityModel>> getUniversities() async {
    final data = await _client
        .from('universities')
        .select()
        .order('name', ascending: true);
    return (data as List).map((e) => UniversityModel.fromSupabase(e)).toList();
  }

  // ─── Video Cache ──────────────────────────────────────────────────────────
  /// Bu fonksiyonun Amacı:
  /// Video verilerini Supabase'teki 'videos_cache' tablosundan çekmek için kullanılır.
  /// Bu fonksiyon, 'videos_cache' tablosundaki tüm video kayıtlarını çeker ve bunları
  /// VideoModel türünde bir liste olarak döner. Ayrıca, her video kaydıyla ilişkili üniversite
  /// adını da çekmek için 'universities' tablosuyla birleştirme (join) işlemi yapar.
  /// Sonuç olarak, her video kaydında ilgili üniversitenin adı da bulunur.
  /// Bu fonksiyon, uygulamanın ana sayfasında veya video listelerinde görüntülenecek
  /// video verilerini almak için kullanılır ve genellikle önbelleğe alınmış (cached) video verilerini sağlar.
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

  /// Bu fonksiyonun Amacı:
  /// Belirli bir üniversiteye ait video verilerini Supabase'teki 'videos_cache' tablosundan çekmek için kullanılır.
  /// Bu fonksiyon, üniversite ID'si (universityId) parametresi alır ve bu ID'ye sahip videoları 'videos_cache'
  /// tablosundan çeker. Ayrıca, her video kaydıyla ilişkili üniversite adını da çekmek için 'universities'
  /// tablosuyla birleştirme (join) işlemi yapar. Sonuç olarak, belirtilen üniversiteye ait video kayıtları,
  /// ilgili üniversitenin adıyla birlikte VideoModel türünde bir liste olarak döner. Bu fonksiyon, belirli
  /// bir üniversitenin videolarını görüntülemek veya filtrelemek gibi işlemler için kullanılır.

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

  /// Bu fonksiyonun Amacı:
  /// 'latest_videos_per_university' adlı view'dan her üniversitenin en son videosunu çekmek için kullanılır.
  /// Bu fonksiyon, 'latest_videos_per_university' view'ındaki tüm kayıtları çeker ve bunları VideoModel
  /// türünde bir liste olarak döner. Her kayıt, ilgili üniversitenin adıyla birlikte gelir.
  /// Bu fonksiyon, uygulamanın ana sayfasında veya üniversite bazında video listelerinde görüntülenecek
  /// en son video verilerini almak için kullanılır. Bu view, her üniversite için sadece en son video kaydını içerdiğinden,
  /// bu fonksiyonun amacı her üniversitenin en güncel videosunu hızlı bir şekilde sağlamaktır.
  Future<List<VideoModel>> getLatestVideoPerUniversity() async {
    final data = await _client
        .from('latest_videos_per_university')
        .select()
        .order('published_at', ascending: false);

    return (data as List).map((e) => VideoModel.fromSupabase(e)).toList();
  }

  /// Bu fonksiyonun Amacı:
  /// Video verilerini öncelikle local cache'ten çekmeye çalışır. Eğer cache geçerli ve doluysa, cache'teki verileri döner.
  /// Eğer cache süresi dolmuşsa veya cache boşsa, Supabase'ten en son video verilerini çeker. Supabase'ten çekilen
  /// veriler daha sonra local cache'e kaydedilir, böylece bir sonraki açılışta cache'ten hızlıca erişilebilir hale gelir.
  /// Eğer Supabase'ten veri çekme sırasında bir hata oluşursa (örneğin, ağ hatası), fonksiyon eski cache verilerini döner.
  /// Bu fonksiyon, uygulamanın ana sayfasında veya üniversite bazında video listelerinde görüntülenecek video verilerini
  /// almak için kullanılır ve öncelikle hızlı erişim için cache'i kullanır, ardından gerektiğinde Supabase'e başvurur.
  ///
  Future<void> upsertVideos(List<VideoModel> videos) async {
    final data = videos.map((v) => v.toSupabase()).toList();
    await _client.from('videos_cache').upsert(data, onConflict: 'video_id');
  }

  // ─── Favoriler ────────────────────────────────────────────────────────────
  /// Bu fonksiyonun Amacı:
  /// Kullanıcının favori video ID'lerini Supabase'teki 'favorites' tablosundan çekmek için kullanılır.
  /// Bu fonksiyon, kullanıcı ID'si (userId) parametresi alır ve bu ID'ye sahip favori video kayıtlarını 'favorites' tablosundan çeker.
  /// Sonuç olarak, kullanıcının favori videolarının ID'lerini içeren bir liste döner. Bu fonksiyon, kullanıcıların
  /// favori videolarını görüntülemek veya yönetmek gibi işlemler için kullanılabilir.
  Future<List<String>> getFavoriteVideoIds(String userId) async {
    final data = await _client
        .from('favorites')
        .select('video_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['video_id'] as String).toList();
  }

  /// Bu fonksiyonun Amacı:
  /// Kullanıcının favori video ID'lerini Supabase'teki 'favorites' tablosundan çekmek için kullanılır.
  /// Bu fonksiyon, kullanıcı ID'si (userId) parametresi alır ve bu ID'ye sahip favori video kayıtlarını 'favorites' tablosundan çeker.
  /// Sonuç olarak, kullanıcının favori videolarının ID'lerini içeren bir liste döner. Bu fonksiyon, kullanıcıların
  /// favori videolarını görüntülemek veya yönetmek gibi işlemler için kullanılabilir.
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

  /// Bu fonksiyonun Amacı:
  /// 'universities_with_stats' adlı view'dan üniversiteleri ve her üniversitenin video sayısını çekmek için kullanılır.
  /// Bu fonksiyon, 'universities_with_stats' view'ındaki tüm kayıtları çeker ve bunları Map< String, dynamic >
  /// türünde bir liste olarak döner. Her kayıt, üniversitenin ID'si, adı, kanal ID'si, video sayısı,
  /// küçük resim URL'si ve logo URL'si gibi bilgileri içerir. Bu fonksiyon, uygulamanın ana sayfasında veya üniversite
  /// listelerinde görüntülenecek üniversite verilerini almak için kullanılır ve her üniversitenin video sayısını da sağlar.
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
        .update({'content': content, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', commentId);
  }

  /// Kullanıcının yorum yaptığı videoları döner (tekrarsız, en yeni önce).
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
        .select('id, name, channel_id, video_count, thumbnail_url, logo_url')
        .order('name', ascending: true);

    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

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

  /// Kullanıcı bu videoyu beğenmiş mi?
  Future<bool> isLiked(String userId, String videoId) async {
    final data = await _client
        .from('likes')
        .select('id')
        .eq('user_id', userId)
        .eq('video_id', videoId)
        .maybeSingle();
    return data != null;
  }

  /// Beğeni ekle (conflict'i yoksay — zaten ekliyse hata vermez).
  Future<void> addLike(String userId, String videoId) async {
    await _client.from('likes').upsert({
      'user_id': userId,
      'video_id': videoId,
    }, onConflict: 'user_id,video_id');
  }

  /// Beğeniyi kaldır.
  Future<void> removeLike(String userId, String videoId) async {
    await _client
        .from('likes')
        .delete()
        .eq('user_id', userId)
        .eq('video_id', videoId);
  }

  // ─── Görüntüleme (content_views) ─────────────────────────────────────────

  /// Video izlendiğinde bir kez çağır (aynı kullanıcı için tekrar eklenmez).
  Future<void> recordView(String userId, String videoId) async {
    await _client.from('content_views').upsert({
      'user_id': userId,
      'video_id': videoId,
    }, onConflict: 'user_id,video_id');
  }

  /// Kullanıcının izlediği videoları döner (en yeni önce).
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

  /// Kullanıcı paylaştığında çağır (tekrar eklenmez).
  Future<void> recordShare(String userId, String videoId) async {
    await _client.from('shared').upsert({
      'user_id': userId,
      'video_id': videoId,
    }, onConflict: 'user_id,video_id');
  }

  /// Kullanıcının paylaştığı videoları döner (en yeni önce).
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

  /// video_engagement_stats view'ından tek videonun istatistiklerini çeker.
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
}
