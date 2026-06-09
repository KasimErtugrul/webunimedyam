// lib/data/repositories/engagement_repository.dart

import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_viewer_model.dart';

class EngagementRepository {
  final SupabaseDataSource _supabase;

  EngagementRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── OKUMA İŞLEMLERİ (Read) ──────────────────────────────────────────────

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

  /// Videoyu kimlerin izlediğini sayfalı olarak getirir.
  /// watch_history_visibility = 'private' olan kullanıcılar filtrelenir.
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

  // ─── YAZMA İŞLEMLERİ (Write) ──────────────────────────────────────────────

  Future<void> addLike(String userId, String videoId) async {
    log('👍☁️➕ [Engagement] Beğeni Supabase\'e ekleniyor');
    await _supabase.addLike(userId, videoId);
  }

  Future<void> removeLike(String userId, String videoId) async {
    log('👍☁️🗑️ [Engagement] Beğeni Supabase\'den siliniyor');
    await _supabase.removeLike(userId, videoId);
  }

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