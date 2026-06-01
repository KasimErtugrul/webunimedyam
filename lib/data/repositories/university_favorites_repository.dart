// lib/data/repositories/university_favorites_repository.dart

import 'dart:developer';
import 'dart:async';
import 'package:get/get.dart';

import '../datasources/remote/supabase_datasource.dart';
import '../models/university_model.dart';

/// Üniversite favori değişikliklerini taşıyan event sınıfı.
class UniversityFavoriteChange {
  final int universityId;
  final bool isFavorite;
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

  // ─── In-memory ID cache ──────────────────────────────────────────────────
  // OPTİMİZASYON: Her detay sayfasında tek satır Supabase sorgusu yerine
  // bu Set'e bakılır. Uygulama başladığında veya ilk gerektiğinde doldurulur.
  final Set<int> _cachedFavoriteIds = {};
  bool _isCacheLoaded = false;
  String? _cachedUserId;

  UniversityFavoritesRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── Cache Yönetimi ──────────────────────────────────────────────────────

  /// ID cache'ini Supabase'den doldurur (ilk çağrıda veya userId değişince).
  Future<void> _ensureCache(String userId) async {
    if (_isCacheLoaded && _cachedUserId == userId) return;
    try {
      log('🏛️☁️ [UniFav] ID cache dolduruluyor → $userId');
      final ids = await _supabase.getFavoriteUniversityIds(userId);
      _cachedFavoriteIds
        ..clear()
        ..addAll(ids);
      _cachedUserId = userId;
      _isCacheLoaded = true;
      log('🏛️✅ [UniFav] ID cache hazır → ${ids.length} üniversite');
    } catch (e) {
      log('🏛️❌ [UniFav] ID cache doldurulamadı: $e');
    }
  }

  void _invalidateCache() {
    _isCacheLoaded = false;
    _cachedUserId = null;
    _cachedFavoriteIds.clear();
  }

  // ─── OKUMA ──────────────────────────────────────────────────────────────

  /// Kullanıcının favori üniversite id listesini döner.
  Future<List<int>> getFavoriteUniversityIds(String userId) async {
    await _ensureCache(userId);
    return _cachedFavoriteIds.toList();
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

  /// OPTİMİZASYON: Supabase'e gitmeden in-memory cache'e bakar.
  /// Cache yüklü değilse otomatik doldurur.
  Future<bool> isUniversityFavorited(String userId, int universityId) async {
    await _ensureCache(userId);
    return _cachedFavoriteIds.contains(universityId);
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
      _cachedFavoriteIds.add(universityId); // cache'e de ekle
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
      _cachedFavoriteIds.remove(universityId); // cache'den de çıkar
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

  /// Kullanıcı çıkış yaptığında cache'i temizle.
  void clearCache() => _invalidateCache();

  @override
  void onClose() {
    _changeController.close();
    super.onClose();
  }
}