// lib/data/repositories/shorts_repository.dart

import 'dart:developer';

import '../datasources/remote/supabase_datasource.dart';
import '../models/shorts_model.dart';

class ShortsRepository {
  final SupabaseDataSource _supabase;

  ShortsRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  /// Her üniversiteden en son 1 shorts videoyu çeker.
  Future<List<ShortsModel>> getShortsPerUniversity() async {
    try {
      log('🎬📱 [Shorts] Shorts listesi RPC\'den çekiliyor...');
      final shorts = await _supabase.getShortsPerUniversity();
      log('🎬✅ [Shorts] ${shorts.length} üniversiteden shorts geldi');
      return shorts;
    } catch (e) {
      log('🎬❌ [Shorts] getShortsPerUniversity hata: $e');
      return [];
    }
  }
}