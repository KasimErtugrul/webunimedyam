// lib/data/repositories/engagement_repository.dart
//
// BUG FIX özeti:
//   1) addLike() → upsert ile idempotent hale getirildi.
//      Önceki kodda düz upsert vardı (supabase_datasource.dart'ta) ama
//      engagementRepository.addLike() hata fırlatırsa
//      PlayerController / HomeController zaten rollback yapıyor.
//      Asıl sorun: getLikedVideoIds() hata yönetimi eksikti — try/catch yok,
//      hata yukarı taşınıyor, HomeController'da loadLikedVideoIds() crash.
//
//   2) getLikedVideoIds() → try/catch eklendi (diğer metodlarla tutarlı hale getirildi).
//      Önceki kodda tek başına try/catch yoktu; hata olursa
//      HomeController.loadLikedVideoIds() exception ile patlar,
//      _likedIds hiç doldurulmaz → tüm videolar "beğenilmemiş" görünür.
//
//   3) addLike() / removeLike() → try/catch + log eklendi.
//      Önceki kodda hata direkt throw ediliyordu; controller'lar zaten
//      kendi catch bloklarını yazıyor ama tutarsız davranış önlendi.
//
//   4) FIX: addLike/removeLike/recordShare/recordView → başarılı mutasyon
//      sonrası _local.clearUserStats() eklendi. Önceden bu metodlar
//      user_stats cache'ini (60 dk TTL) hiç invalidate etmiyordu; kullanıcı
//      beğeni/paylaşım/izleme yaptıktan hemen sonra istatistik ekranına
//      girdiğinde eski (stale) sayılar görünüyordu.

import 'dart:developer';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_viewer_model.dart';
import '../models/video_model.dart';

class EngagementRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;

  EngagementRepository({
    required SupabaseDataSource supabase,
    required LocalDataSource local,
  }) : _supabase = supabase,
       _local = local;

  Future<Map<String, int>> getEngagementStats(String videoId) async {
    try {
      return await _supabase.getEngagementStats(videoId);
    } catch (e, stacktrace) {
      log(
        'Video etkileşim istatistikleri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return {
        'app_view_count': 0,
        'app_like_count': 0,
        'app_favorite_count': 0,
        'app_share_count': 0,
        'app_comment_count': 0,
      };
    }
  }

  Future<bool> isLiked(String userId, String videoId) async {
    try {
      return await _supabase.isLiked(userId, videoId);
    } catch (e, stacktrace) {
      log(
        'Beğeni durumu kontrol edilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return false;
    }
  }

  Future<({List<VideoViewerModel> viewers, int totalCount})> getVideoViewers(
    String videoId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final viewers = await _supabase.getVideoViewers(
        videoId,
        limit: limit,
        offset: offset,
      );
      final total = viewers.isNotEmpty ? viewers.first.totalCount : 0;
      return (viewers: viewers, totalCount: total);
    } catch (e, stacktrace) {
      log(
        'Video izleyicileri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return (viewers: <VideoViewerModel>[], totalCount: 0);
    }
  }

  /// BUG FIX: try/catch eklendi.
  /// Önceki kodda hata direkt throw ediliyordu.
  /// HomeController ve PlayerController zaten catch yazıyor ama
  /// tutarlı davranış için repository katmanında da logla.
  Future<void> addLike(String userId, String videoId, {VideoModel? video}) async {
    try {
      await _supabase.addLike(userId, videoId);
      // GÜNCELLEME: Artık cache'i silip bir sonraki açılışta Supabase'e
      // tekrar gitmiyoruz — aynı beğeniyi doğrudan yerel istatistik
      // kopyasına da yansıtıyoruz (mirror).
      await _local.recordLocalLikeChange(added: true, video: video);
      // FIX: liked_video_ids cache'i de mirror'la — TTL dolmadan da
      // getLikedVideoIds() güncel sonucu local'den dönebilsin.
      await _local.addLocalLikedId(videoId);
    } catch (e, stacktrace) {
      log(
        'Beğeni eklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow; // Controller'ların rollback yapabilmesi için yeniden fırlat
    }
  }

  /// BUG FIX: try/catch + log eklendi.
  Future<void> removeLike(String userId, String videoId, {VideoModel? video}) async {
    try {
      await _supabase.removeLike(userId, videoId);
      await _local.recordLocalLikeChange(added: false, video: video);
      await _local.removeLocalLikedId(videoId);
    } catch (e, stacktrace) {
      log(
        'Beğeni silinirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow; // Controller'ların rollback yapabilmesi için yeniden fırlat
    }
  }

  /// BUG FIX: try/catch eklendi.
  ///
  /// Önceki kodda bu metodun try/catch'i YOKTU; diğer tüm metodların
  /// aksine hata direkt throw ediliyordu.
  /// HomeController.loadLikedVideoIds() çağırırken:
  ///   try { final ids = await engagementRepository.getLikedVideoIds(userId); }
  ///   catch (e) { log(...) }  ← vardı, ama tutarsız
  ///
  /// Daha kritik: getLikedVideoIds hata fırlatınca _likedIds hiç
  /// doldurulmaz, _likeCache boş kalır → video listesinde tüm kalpler
  /// boş görünür; ilk beğeni tıklamasında isLiked() DB sorgusu atılır
  /// (gereksiz round-trip).
  /// FIX: local-first + TTL cache eklendi.
  ///
  /// Önceki davranış: her çağrıda (yani her app açılışında, HomeController
  /// onReady() üzerinden) doğrudan Supabase'e gidip `likes` tablosundan
  /// TÜM satırları (limit yok) çekiyordu. Kullanıcının beğeni sayısı
  /// binlere çıktıkça bu, her cold start'ta gereksiz büyük bir network
  /// isteğine dönüşüyordu.
  ///
  /// Yeni davranış: 30 dk TTL'li local cache önce kontrol edilir (bkz.
  /// LocalDataSource.isLikedIdsCacheValid). Cache geçerliyse Supabase'e
  /// hiç gidilmez. Cache süresi dolmuşsa/yoksa Supabase'den tam liste
  /// çekilir ve cache yeniden yazılır. Kullanıcı beğeni/beğeni-kaldırma
  /// yaptıkça cache, addLike()/removeLike() içinde ayrıca mirror'lanır —
  /// yani TTL dolmadan da güncel kalır.
  Future<Set<String>> getLikedVideoIds(String userId) async {
    try {
      if (await _local.isLikedIdsCacheValid()) {
        return await _local.getCachedLikedVideoIds();
      }

      final ids = await _supabase.getLikedVideoIds(userId);
      await _local.cacheLikedVideoIds(ids);
      return ids;
    } catch (e, stacktrace) {
      log(
        'Beğenilen video ID\'leri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      // Network hatasında son çare: elimizdeki (muhtemelen bayat) cache'i
      // dön — boş dönüp tüm kalpleri sıfırlamaktan daha iyi bir UX.
      final stale = await _local.getCachedLikedVideoIds();
      return stale;
    }
  }

  Future<Set<String>> getSharedVideoIds(String userId) async {
    try {
      return await _supabase.getSharedVideoIds(userId);
    } catch (e, stacktrace) {
      log(
        'Paylaşılan video ID\'leri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return {};
    }
  }

  Future<Set<String>> getCommentedVideoIds(String userId) async {
    try {
      return await _supabase.getCommentedVideoIds(userId);
    } catch (e, stacktrace) {
      log(
        'Yorum yapılan video ID\'leri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return {};
    }
  }

  Future<bool> recordView(String userId, String videoId, {VideoModel? video}) async {
    try {
      final result = await _supabase.recordView(userId, videoId);
      // GÜNCELLEME: sadece gerçekten YENİ bir izlemeyse (result == true,
      // yani bu video bu kullanıcı için ilk kez kaydedildi) yerel
      // istatistiğe +1 yansıt. Tekrar izlemelerde sunucu da saymıyor,
      // biz de saymıyoruz.
      if (result) {
        await _local.recordLocalVideoWatched(video: video);
      }
      return result;
    } catch (e, stacktrace) {
      log(
        'Görüntülenme kaydedilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return false;
    }
  }

  Future<void> recordShare(String userId, String videoId) async {
    try {
      await _supabase.recordShare(userId, videoId);
      // GÜNCELLEME: totalShared'i doğrudan yerelde de +1 yapıyoruz.
      await _local.recordLocalShare();
    } catch (e, stacktrace) {
      log(
        'Paylaşım kaydedilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }
}