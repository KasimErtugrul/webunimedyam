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
      final shorts = await _supabase.getShortsPerUniversity(
        limit: limit,
        offset: offset,
      );
      return shorts;
    } catch (e, stacktrace) {
      log(
        'Üniversite short videoları getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }
}
