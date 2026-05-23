import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';

class ProfileActivityRepository {
  final SupabaseDataSource _supabase;

  ProfileActivityRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── OKUMA İŞLEMLERİ (Read) ──────────────────────────────────────────────
  // Tümü try-catch'li. Offline ise boş liste döner, profil ekranı çökmez.

  Future<List<VideoModel>> getUserViewedVideos(String userId) async {
    try {
      return await _supabase.getUserViewedVideos(userId);
    } catch (e) {
      log('👁️❌ [ProfileActivity] İzlenen videolar yüklenemedi: $e');
      return [];
    }
  }

  Future<List<VideoModel>> getUserCommentedVideos(String userId) async {
    try {
      return await _supabase.getUserCommentedVideos(userId);
    } catch (e) {
      log('💬❌ [ProfileActivity] Yorumlanan videolar yüklenemedi: $e');
      return [];
    }
  }

  Future<List<VideoModel>> getUserSharedVideos(String userId) async {
    try {
      return await _supabase.getUserSharedVideos(userId);
    } catch (e) {
      log('🔗❌ [ProfileActivity] Paylaşılan videolar yüklenemedi: $e');
      return [];
    }
  }
}