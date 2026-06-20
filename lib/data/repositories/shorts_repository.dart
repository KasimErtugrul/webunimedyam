// lib/data/repositories/shorts_repository.dart

import 'dart:developer';

import '../datasources/remote/supabase_datasource.dart';
import '../models/shorts_model.dart';

class ShortsRepository {
  final SupabaseDataSource _supabase;

  ShortsRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  /// Sayfalama destekli: her çağrıda [limit] adet, [offset]'ten itibaren.
  Future<List<ShortsModel>> getShortsPerUniversity({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      log('🎬📱 [Shorts] Shorts listesi RPC\'den çekiliyor (limit=$limit, offset=$offset)...');
      final shorts = await _supabase.getShortsPerUniversity(
        limit: limit,
        offset: offset,
      );
      log('🎬✅ [Shorts] ${shorts.length} üniversiteden shorts geldi');
      return shorts;
    } catch (e) {
      log('🎬❌ [Shorts] getShortsPerUniversity hata: $e');
      return [];
    }
  }
}