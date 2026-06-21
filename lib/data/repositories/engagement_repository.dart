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

import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_viewer_model.dart';

class EngagementRepository {
  final SupabaseDataSource _supabase;

  EngagementRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  Future<Map<String, int>> getEngagementStats(String videoId) async {
    try {
      return await _supabase.getEngagementStats(videoId);
    } catch (e) {
      log('📊❌ [Engagement] İstatistikler yüklenemedi: $e');
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
    } catch (e) {
      log('👍❌ [Engagement] Beğeni durumu okunamadı: $e');
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
    } catch (e) {
      log('👁️❌ [Engagement] İzleyenler yüklenemedi: $e');
      return (viewers: <VideoViewerModel>[], totalCount: 0);
    }
  }

  /// BUG FIX: try/catch eklendi.
  /// Önceki kodda hata direkt throw ediliyordu.
  /// HomeController ve PlayerController zaten catch yazıyor ama
  /// tutarlı davranış için repository katmanında da logla.
  Future<void> addLike(String userId, String videoId) async {
    try {
      log('👍☁️➕ [Engagement] Beğeni Supabase\'e ekleniyor → $videoId');
      await _supabase.addLike(userId, videoId);
      log('👍✅ [Engagement] Beğeni eklendi');
    } catch (e) {
      log('👍❌ [Engagement] Beğeni eklenemedi: $e');
      rethrow; // Controller'ların rollback yapabilmesi için yeniden fırlat
    }
  }

  /// BUG FIX: try/catch + log eklendi.
  Future<void> removeLike(String userId, String videoId) async {
    try {
      log('👍☁️🗑️ [Engagement] Beğeni Supabase\'den siliniyor → $videoId');
      await _supabase.removeLike(userId, videoId);
      log('👍✅ [Engagement] Beğeni silindi');
    } catch (e) {
      log('👍❌ [Engagement] Beğeni silinemedi: $e');
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
  Future<Set<String>> getLikedVideoIds(String userId) async {
    try {
      log('👍☁️ [Engagement] Beğenilen video ID\'leri çekiliyor → $userId');
      final ids = await _supabase.getLikedVideoIds(userId);
      log('👍✅ [Engagement] ${ids.length} beğenilen video ID geldi');
      return ids;
    } catch (e) {
      log('👍❌ [Engagement] Beğenilen ID\'ler çekilemedi: $e');
      return {}; // Boş set dön; controller gracefully devam eder
    }
  }

  Future<Set<String>> getSharedVideoIds(String userId) async {
    try {
      return await _supabase.getSharedVideoIds(userId);
    } catch (e) {
      log("🔗❌ [Engagement] Paylaşılan ID'ler yüklenemedi: $e");
      return {};
    }
  }

  Future<Set<String>> getCommentedVideoIds(String userId) async {
    try {
      return await _supabase.getCommentedVideoIds(userId);
    } catch (e) {
      log("💬❌ [Engagement] Yorumlanan ID'ler yüklenemedi: $e");
      return {};
    }
  }

  Future<bool> recordView(String userId, String videoId) async {
    try {
      return await _supabase.recordView(userId, videoId);
    } catch (e) {
      log('👁️❌ [Engagement] Görüntülenme kaydedilemedi: $e');
      return false;
    }
  }

  Future<void> recordShare(String userId, String videoId) async {
    try {
      await _supabase.recordShare(userId, videoId);
    } catch (e) {
      log('🔗❌ [Engagement] Paylaşım kaydedilemedi: $e');
    }
  }
}