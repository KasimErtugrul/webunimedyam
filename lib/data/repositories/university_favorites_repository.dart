// lib/data/repositories/university_favorites_repository.dart
//
// BUG FIX özeti:
//   1) addFavorite() içindeki rethrow kaldırıldı — artık hata loglanır ve
//      false döner; çağıran (HomeController, UniversityDetailController)
//      try/catch yazmak zorunda kalmaz, UI sessiz kalmaz.
//
//      Eski davranış:
//        addFavorite() → _supabase.addUniversityFavorite() (insert, hata fırlatır)
//        → rethrow → HomeController.catch(e) { log(...) } — hata yutulur, hiçbir
//        şey olmaz; kullanıcıya geri bildirim yok, cache senkronize olmaz.
//
//      Yeni davranış:
//        addFavorite() → _supabase.addUniversityFavorite() (upsert, hata yok)
//        Cache güncellenir, event yayınlanır, bool döner.
//        Hata olursa: log + false dön; çağıran koda göre UI mesajı gösterir.
//
//   2) removeFavorite() aynı şekilde bool döndürecek şekilde güncellendi —
//      çağıran controller UI feedback'i bu değere göre verebilir.
//
//   3) _ensureCache() → race condition: iki eş zamanlı çağrı aynı anda
//      _isCacheLoaded == false görüp iki kez Supabase'e gidebilir.
//      _isLoading flag'i ile çözdük.

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

  final _changeController =
      StreamController<UniversityFavoriteChange>.broadcast();
  Stream<UniversityFavoriteChange> get onFavoriteChanged =>
      _changeController.stream;

  // ─── In-memory ID cache ──────────────────────────────────────────────────
  final Set<int> _cachedFavoriteIds = {};
  bool _isCacheLoaded = false;
  // BUG FIX: Eş zamanlı _ensureCache() çağrılarında double-fetch'i önler
  bool _isCacheLoading = false;
  String? _cachedUserId;

  UniversityFavoritesRepository({required SupabaseDataSource supabase})
    : _supabase = supabase;

  // ─── Cache Yönetimi ──────────────────────────────────────────────────────

  /// BUG FIX: _isCacheLoading flag'i eklendi.
  /// Önceki halde iki eş zamanlı çağrı (örn: HomeController + UniversityDetailController
  /// aynı anda init olunca) her ikisi de _isCacheLoaded == false görüp
  /// iki kez Supabase'e gidiyordu.
  Future<void> _ensureCache(String userId) async {
    if (_isCacheLoaded && _cachedUserId == userId) return;
    if (_isCacheLoading) {
      // Yüklenme devam ediyor, bitene kadar bekle (poll)
      while (_isCacheLoading) {
        await Future.delayed(const Duration(milliseconds: 30));
      }
      return;
    }
    _isCacheLoading = true;
    try {
      final ids = await _supabase.getFavoriteUniversityIds(userId);
      _cachedFavoriteIds
        ..clear()
        ..addAll(ids);
      _cachedUserId = userId;
      _isCacheLoaded = true;
    } catch (e, stacktrace) {
      log(
        'Üniversite favori ID\'leri cache\'e yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    } finally {
      _isCacheLoading = false;
    }
  }

  void _invalidateCache() {
    _isCacheLoaded = false;
    _isCacheLoading = false;
    _cachedUserId = null;
    _cachedFavoriteIds.clear();
  }

  // ─── OKUMA ──────────────────────────────────────────────────────────────

  Future<List<int>> getFavoriteUniversityIds(String userId) async {
    await _ensureCache(userId);
    return _cachedFavoriteIds.toList();
  }

  Future<List<UniversityModel>> getFavoriteUniversities(String userId) async {
    try {
      final universities = await _supabase.getFavoriteUniversities(userId);
      return universities;
    } catch (e, stacktrace) {
      log(
        'Favori üniversiteler getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  Future<bool> isUniversityFavorited(String userId, int universityId) async {
    await _ensureCache(userId);
    return _cachedFavoriteIds.contains(universityId);
  }

  // ─── YAZMA ──────────────────────────────────────────────────────────────

  /// Üniversiteyi favorilere ekler.
  ///
  /// BUG FIX #1: rethrow kaldırıldı.
  ///   Önceki kodda _supabase.addUniversityFavorite() → düz INSERT → çakışmada
  ///   23505 unique_violation → rethrow → HomeController.catch(e) sessizce yutar.
  ///   Artık _supabase katmanında upsert (ignoreDuplicates) kullanılıyor;
  ///   DB hatası gelmez. Ağ hatası gibi gerçek hatalar burada yakalanır,
  ///   cache dokunulmaz, false döner; çağıran UI mesajı gösterebilir.
  ///
  /// BUG FIX #2: Optimistic cache update.
  ///   Önceki kodda cache hemen güncelleniyor, event yayınlanıyordu — bu
  ///   doğru. Ama hata sonrası cache'i geri almıyordu. Artık hata durumunda
  ///   cache'den temizleniyor.
  ///
  /// Dönüş: true → başarılı, false → hata
  Future<bool> addFavorite(
    String userId,
    int universityId, {
    UniversityModel? university,
  }) async {
    // Optimistic: önce cache'e ekle
    _cachedFavoriteIds.add(universityId);
    _changeController.add(
      UniversityFavoriteChange(
        universityId: universityId,
        isFavorite: true,
        university: university,
      ),
    );

    try {
      await _supabase.addUniversityFavorite(userId, universityId);
      return true;
    } catch (e, stacktrace) {
      // Rollback: cache'den geri çıkar, event'i geri al
      _cachedFavoriteIds.remove(universityId);
      _changeController.add(
        UniversityFavoriteChange(universityId: universityId, isFavorite: false),
      );
      log(
        'Üniversite favorilere eklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return false;
    }
  }

  /// Üniversiteyi favorilerden çıkarır.
  ///
  /// BUG FIX: rethrow → bool dönüşü + optimistic rollback.
  ///
  /// Dönüş: true → başarılı, false → hata
  Future<bool> removeFavorite(String userId, int universityId) async {
    // Optimistic: önce cache'den çıkar
    _cachedFavoriteIds.remove(universityId);
    _changeController.add(
      UniversityFavoriteChange(universityId: universityId, isFavorite: false),
    );

    try {
      await _supabase.removeUniversityFavorite(userId, universityId);
      return true;
    } catch (e, stacktrace) {
      // Rollback: cache'e geri ekle, event'i geri al
      _cachedFavoriteIds.add(universityId);
      _changeController.add(
        UniversityFavoriteChange(universityId: universityId, isFavorite: true),
      );
      log(
        'Üniversite favorilerden çıkarılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return false;
    }
  }

  void clearCache() => _invalidateCache();

  @override
  void onClose() {
    _changeController.close();
    super.onClose();
  }
}
