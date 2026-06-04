// lib/data/repositories/profile_activity_repository.dart
//
// NOT: Visibility kontrolü tamamen DB katmanında (RLS) yapılır.
// can_view_profile() ve can_view_activity() SECURITY DEFINER fonksiyonları
// hangi kullanıcının ne göreceğine karar verir.
// Dart katmanı sadece Supabase'den veriyi çeker — boş dönerse gizlidir.

import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';

class ProfileActivityRepository {
  final SupabaseDataSource _supabase;

  ProfileActivityRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

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