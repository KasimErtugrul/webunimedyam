import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';

class EngagementRepository {
  final SupabaseDataSource _supabase;

  EngagementRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── OKUMA İŞLEMLERİ (Read) ──────────────────────────────────────────────
  // İnternet yoksa varsayılan değerler döner, uygulama çökmez.

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
      return false; // Offline ise beğenilmemiş say
    }
  }

  // ─── YAZMA İŞLEMLERİ (Write) ──────────────────────────────────────────────
  // BU METOTLARDA TRY-CATCH YOK!
  // Hata olursa Exception fırlatır ki PlayerController yakalayıp Optimistic UI'ı geri alsın.

  Future<void> addLike(String userId, String videoId) async {
    log('👍☁️➕ [Engagement] Beğeni Supabase\'e ekleniyor');
    await _supabase.addLike(userId, videoId);
  }

  Future<void> removeLike(String userId, String videoId) async {
    log('👍☁️🗑️ [Engagement] Beğeni Supabase\'den siliniyor');
    await _supabase.removeLike(userId, videoId);
  }

  // Görüntülenme ve Paylaşım arka plan işlemleridir. 
  // Optimistic UI gerektirmediği için hataları burada yutabiliriz (loglayıp geçeriz).
  Future<void> recordView(String userId, String videoId) async {
    try {
      await _supabase.recordView(userId, videoId);
    } catch (e) {
      log('👁️❌ [Engagement] Görüntülenme kaydedilemedi: $e');
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