// lib/data/repositories/university_favorites_repository.dart

import 'dart:developer';
import 'dart:async';
import 'package:get/get.dart';

import '../datasources/remote/supabase_datasource.dart';
import '../models/university_model.dart';

/// Üniversite favori değişikliklerini taşıyan event sınıfı.
class UniversityFavoriteChange {
  final int universityId;
  final bool isFavorite; // true: eklendi, false: silindi
  final UniversityModel? university;

  UniversityFavoriteChange({
    required this.universityId,
    required this.isFavorite,
    this.university,
  });
}

class UniversityFavoritesRepository extends GetxService {
  final SupabaseDataSource _supabase;

  // Favori değişimlerini yayınlayan broadcast stream
  final _changeController =
      StreamController<UniversityFavoriteChange>.broadcast();
  Stream<UniversityFavoriteChange> get onFavoriteChanged =>
      _changeController.stream;

  UniversityFavoritesRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── OKUMA ──────────────────────────────────────────────────────────────

  /// Kullanıcının favori üniversite id listesini döner.
  Future<List<int>> getFavoriteUniversityIds(String userId) async {
    try {
      log('🏛️☁️ [UniFav] ID\'ler çekiliyor → $userId');
      final ids = await _supabase.getFavoriteUniversityIds(userId);
      log('🏛️✅ [UniFav] ${ids.length} favori üniversite ID geldi');
      return ids;
    } catch (e) {
      log('🏛️❌ [UniFav] ID\'ler çekilemedi: $e');
      return [];
    }
  }

  /// Kullanıcının favori üniversitelerini tam model olarak döner.
  Future<List<UniversityModel>> getFavoriteUniversities(String userId) async {
    try {
      log('🏛️☁️ [UniFav] Favori üniversiteler çekiliyor → $userId');
      final universities = await _supabase.getFavoriteUniversities(userId);
      log('🏛️✅ [UniFav] ${universities.length} üniversite geldi');
      return universities;
    } catch (e) {
      log('🏛️❌ [UniFav] Üniversiteler çekilemedi: $e');
      return [];
    }
  }

  /// Tek bir üniversitenin favori durumunu döner.
  Future<bool> isUniversityFavorited(String userId, int universityId) async {
    try {
      return await _supabase.isUniversityFavorited(userId, universityId);
    } catch (e) {
      log('🏛️❌ [UniFav] Favori durumu kontrol edilemedi: $e');
      return false;
    }
  }

  // ─── YAZMA ──────────────────────────────────────────────────────────────

  /// Üniversiteyi favorilere ekler ve stream üzerinden event yayınlar.
  Future<void> addFavorite(
    String userId,
    int universityId, {
    UniversityModel? university,
  }) async {
    try {
      log('🏛️☁️➕ [UniFav] Ekleniyor → universityId: $universityId');
      await _supabase.addUniversityFavorite(userId, universityId);
      log('🏛️✅ [UniFav] Eklendi');
      _changeController.add(UniversityFavoriteChange(
        universityId: universityId,
        isFavorite: true,
        university: university,
      ));
    } catch (e) {
      log('🏛️❌ [UniFav] Eklenemedi: $e');
      rethrow;
    }
  }

  /// Üniversiteyi favorilerden çıkarır ve stream üzerinden event yayınlar.
  Future<void> removeFavorite(String userId, int universityId) async {
    try {
      log('🏛️☁️🗑️ [UniFav] Siliniyor → universityId: $universityId');
      await _supabase.removeUniversityFavorite(userId, universityId);
      log('🏛️✅ [UniFav] Silindi');
      _changeController.add(UniversityFavoriteChange(
        universityId: universityId,
        isFavorite: false,
      ));
    } catch (e) {
      log('🏛️❌ [UniFav] Silinemedi: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    _changeController.close();
    super.onClose();
  }
}