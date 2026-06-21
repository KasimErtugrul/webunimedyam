// lib/presentation/controllers/settings_controller.dart

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_settings_model.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import 'auth_controller.dart';
import 'profile_controller.dart';

class SettingsController extends GetxService {
  final AuthRepository authRepository;
  final SupabaseDataSource _supabase;

  SettingsController({
    required this.authRepository,
    required SupabaseDataSource supabase,
  }) : _supabase = supabase;

  final settings = Rxn<UserSettingsModel>();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final profileVisibility = VisibilityOption.public.obs;

  Timer? _settingsDebounce;
  UserSettingsModel? _lastSavedSettings;

  // ─── Tavan kontrolü ───────────────────────────────────────────────────────
  static const _order = [
    VisibilityOption.private,
    VisibilityOption.friends,
    VisibilityOption.public,
  ];

  VisibilityOption _clamp(VisibilityOption activity) {
    final ceiling = profileVisibility.value;
    if (_order.indexOf(activity) > _order.indexOf(ceiling)) return ceiling;
    return activity;
  }

  bool isAllowed(VisibilityOption option) {
    return _order.indexOf(option) <= _order.indexOf(profileVisibility.value);
  }

  // ─── Yükleme ──────────────────────────────────────────────────────────────

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      settings.value = await authRepository.getUserSettings();
      _syncProfileVisibilityFromController();
    } catch (e) {
      log('loadSettings error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _syncProfileVisibilityFromController() {
    if (Get.isRegistered<ProfileController>()) {
      final p = Get.find<ProfileController>().profile.value;
      if (p != null) {
        profileVisibility.value = p.profileVisibility;
        return;
      }
    }
  }

  // ─── Görünüm ───────────────────────────────────────────────────────────────

  Future<void> changeTheme(String theme) async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(theme: theme));
    await authRepository.saveThemeLocally(theme);
    final mode = theme == 'dark'
        ? ThemeMode.dark
        : theme == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    Get.changeThemeMode(mode);
  }

  // ─── Oynatma ──────────────────────────────────────────────────────────────

  Future<void> toggleAutoplay() async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(autoplay: !c.autoplay));
  }

  Future<void> toggleSubtitles() async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(showSubtitles: !c.showSubtitles));
  }

  Future<void> changeVideoQuality(String quality) async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(videoQuality: quality));
  }

  // ─── Bildirimler ──────────────────────────────────────────────────────────

  Future<void> toggleNotifications() async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(
        c.copyWith(notificationsEnabled: !c.notificationsEnabled));
  }

  Future<void> toggleNotifyNewVideos() async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(notifyNewVideos: !c.notifyNewVideos));
  }

  Future<void> toggleNotifyCommentReplies() async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(
        c.copyWith(notifyCommentReplies: !c.notifyCommentReplies));
  }

  Future<void> toggleNotifyFollowRequests() async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(
        c.copyWith(notifyFollowRequests: !c.notifyFollowRequests));
  }

  // ─── Gizlilik — Eski (geriye uyumluluk) ───────────────────────────────────

  Future<void> toggleWatchHistory() async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(showWatchHistory: !c.showWatchHistory));
  }

  Future<void> toggleFavoritesPublic() async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(
        c.copyWith(showFavoritesPublic: !c.showFavoritesPublic));
  }

  // ─── Gizlilik — Profil Görünürlüğü (master anahtar) ──────────────────────

  /// Profil görünürlüğünü değiştir ve DB'ye yaz.
  ///
  /// BUG FIX: Önceki kodda `_supabase.updateProfileVisibility(...)` çağrısı
  /// yorum satırındaydı. Bu yüzden:
  ///   - profileVisibility.value sadece RAM'de değişiyordu
  ///   - can_view_activity() / can_view_profile() DB'den okuduğu için
  ///     her zaman eski değeri (public) görüyordu
  ///   - Uygulama restart'ında ayar sıfırlanıyordu
  ///
  /// Artık hem profiles tablosu hem de ProfileController senkronize ediliyor.
  Future<void> changeProfileVisibility(VisibilityOption newVisibility) async {
    final userId = _supabase.currentUser?.id;
    final current = settings.value;
    if (userId == null || current == null) return;

    final oldVisibility = profileVisibility.value;
    profileVisibility.value = newVisibility; // Optimistic UI

    try {
      // BUG FIX: Bu satır artık YORUM SATIRI DEĞİL — DB'ye yazılıyor
      await _supabase.updateProfileVisibility(userId, newVisibility.value);
      log('⚙️✅ [Settings] profileVisibility → ${newVisibility.value} (DB\'ye yazıldı)');

      // Tavan düştüyse taşan aktiviteleri indir
      final clamped = _clampAllActivities(current);
      if (clamped != null) {
        await _updateSettings(clamped);
        log('⚙️✅ [Settings] Taşan aktiviteler tavana indirildi');
      }

      // ProfileController varsa senkronize et
      if (Get.isRegistered<ProfileController>()) {
        final profileCtrl = Get.find<ProfileController>();
        final existing = profileCtrl.profile.value;
        if (existing != null) {
          profileCtrl.profile.value = existing.copyWith(
            profileVisibility: newVisibility,
          );
        }
      }
    } catch (e) {
      profileVisibility.value = oldVisibility; // Rollback
      log('changeProfileVisibility error: $e');
      errorMessage.value = 'Profil görünürlüğü güncellenemedi.';
    }
  }

  UserSettingsModel? _clampAllActivities(UserSettingsModel current) {
    final w = _clamp(current.watchHistoryVisibility);
    final l = _clamp(current.likesVisibility);
    final f = _clamp(current.favoritesVisibility);
    final c = _clamp(current.commentsVisibility);

    if (w == current.watchHistoryVisibility &&
        l == current.likesVisibility &&
        f == current.favoritesVisibility &&
        c == current.commentsVisibility) {
      return null;
    }

    return current.copyWith(
      watchHistoryVisibility: w,
      likesVisibility: l,
      favoritesVisibility: f,
      commentsVisibility: c,
    );
  }

  // ─── Gizlilik — Aktivite Görünürlükleri ───────────────────────────────────

  Future<void> changeWatchHistoryVisibility(VisibilityOption v) async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(watchHistoryVisibility: _clamp(v)));
  }

  Future<void> changeLikesVisibility(VisibilityOption v) async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(likesVisibility: _clamp(v)));
  }

  Future<void> changeFavoritesVisibility(VisibilityOption v) async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(favoritesVisibility: _clamp(v)));
  }

  Future<void> changeCommentsVisibility(VisibilityOption v) async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(commentsVisibility: _clamp(v)));
  }

  // ─── Erişilebilirlik ──────────────────────────────────────────────────────

  Future<void> toggleReducedMotion() async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(reducedMotion: !c.reducedMotion));
  }

  Future<void> changeTextScale(double scale) async {
    final c = settings.value;
    if (c == null) return;
    await _updateSettings(c.copyWith(textScaleFactor: scale));
  }

  // ─── Cache ────────────────────────────────────────────────────────────────

  Future<void> clearCache() async {
    try {
      isLoading.value = true;
      await authRepository.clearLocalCache();
      Get.snackbar(
        'Başarılı',
        'Uygulama cache\'i temizlendi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      log('clearCache error: $e');
      errorMessage.value = 'Cache temizlenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Çıkış ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().signOut();
      } else {
        await authRepository.signOut();
        Get.offAllNamed('/home');
      }
    } catch (e) {
      log('signOut delegate error: $e');
      errorMessage.value = 'Çıkış yapılırken hata oluştu.';
    }
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<void> _updateSettings(UserSettingsModel updated) async {
    final old = _lastSavedSettings ?? settings.value;
    settings.value = updated;

    _settingsDebounce?.cancel();
    _settingsDebounce = Timer(const Duration(milliseconds: 800), () async {
      try {
        await authRepository.updateUserSettings(updated);
        _lastSavedSettings = updated;
        log('⚙️✅ [Settings] Supabase\'e yazıldı (debounce)');
      } catch (e) {
        settings.value = old;
        log('_updateSettings error: $e');
        errorMessage.value = 'Ayarlar güncellenemedi.';
      }
    });
  }

  @override
  void onClose() {
    _settingsDebounce?.cancel();
    super.onClose();
  }
}