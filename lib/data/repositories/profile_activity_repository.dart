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

  Future<List<VideoModel>> getUserViewedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _supabase.getUserViewedVideos(userId, limit: limit, offset: offset);
    } catch (e, stacktrace) {
      log(
        'Kullanıcının izlediği videolar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  Future<List<VideoModel>> getUserCommentedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _supabase.getUserCommentedVideos(userId, limit: limit, offset: offset);
    } catch (e, stacktrace) {
      log(
        'Kullanıcının yorum yaptığı videolar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  Future<List<VideoModel>> getUserSharedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _supabase.getUserSharedVideos(userId, limit: limit, offset: offset);
    } catch (e, stacktrace) {
      log(
        'Kullanıcının paylaştığı videolar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  Future<List<VideoModel>> getUserLikedVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _supabase.getUserLikedVideos(userId, limit: limit, offset: offset);
    } catch (e, stacktrace) {
      log(
        'Kullanıcının beğendiği videolar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }
}
