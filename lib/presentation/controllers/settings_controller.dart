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
    } catch (e, stacktrace) {
      log(
        'Ayarlar yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ayarlar yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  void _syncProfileVisibilityFromController() {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final p = Get.find<ProfileController>().profile.value;
        if (p != null) {
          profileVisibility.value = p.profileVisibility;
          return;
        }
      }
    } catch (e, stacktrace) {
      log(
        'Profil görünürlüğü senkronize edilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Görünüm ───────────────────────────────────────────────────────────────

  Future<void> changeTheme(String theme) async {
    try {
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
    } catch (e, stacktrace) {
      log(
        'Tema değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Tema değiştirilemedi.';
    }
  }

  // ─── Oynatma ──────────────────────────────────────────────────────────────

  Future<void> toggleAutoplay() async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(autoplay: !c.autoplay));
    } catch (e, stacktrace) {
      log(
        'Otomatik oynatma değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> toggleSubtitles() async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(showSubtitles: !c.showSubtitles));
    } catch (e, stacktrace) {
      log(
        'Altyazı değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> changeVideoQuality(String quality) async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(videoQuality: quality));
    } catch (e, stacktrace) {
      log(
        'Video kalitesi değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Bildirimler ──────────────────────────────────────────────────────────

  Future<void> toggleNotifications() async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(
        c.copyWith(notificationsEnabled: !c.notificationsEnabled),
      );
    } catch (e, stacktrace) {
      log(
        'Bildirimler değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> toggleNotifyNewVideos() async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(notifyNewVideos: !c.notifyNewVideos));
    } catch (e, stacktrace) {
      log(
        'Yeni video bildirimi değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> toggleNotifyCommentReplies() async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(
        c.copyWith(notifyCommentReplies: !c.notifyCommentReplies),
      );
    } catch (e, stacktrace) {
      log(
        'Yorum yanıtı bildirimi değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> toggleNotifyFollowRequests() async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(
        c.copyWith(notifyFollowRequests: !c.notifyFollowRequests),
      );
    } catch (e, stacktrace) {
      log(
        'Takip isteği bildirimi değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Gizlilik — Eski (geriye uyumluluk) ───────────────────────────────────

  Future<void> toggleWatchHistory() async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(showWatchHistory: !c.showWatchHistory));
    } catch (e, stacktrace) {
      log(
        'İzleme geçmişi değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> toggleFavoritesPublic() async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(
        c.copyWith(showFavoritesPublic: !c.showFavoritesPublic),
      );
    } catch (e, stacktrace) {
      log(
        'Favorilerin herkese açık olması değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
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

      // Tavan düştüyse taşan aktiviteleri indir
      final clamped = _clampAllActivities(current);
      if (clamped != null) {
        await _updateSettings(clamped);
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
    } catch (e, stacktrace) {
      profileVisibility.value = oldVisibility; // Rollback
      log(
        'Profil görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Profil görünürlüğü güncellenemedi.';
    }
  }

  UserSettingsModel? _clampAllActivities(UserSettingsModel current) {
    try {
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
    } catch (e, stacktrace) {
      log(
        'Aktivite görünürlükleri kısıtlanırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  // ─── Gizlilik — Aktivite Görünürlükleri ───────────────────────────────────

  Future<void> changeWatchHistoryVisibility(VisibilityOption v) async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(watchHistoryVisibility: _clamp(v)));
    } catch (e, stacktrace) {
      log(
        'İzleme geçmişi görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> changeLikesVisibility(VisibilityOption v) async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(likesVisibility: _clamp(v)));
    } catch (e, stacktrace) {
      log(
        'Beğeniler görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> changeFavoritesVisibility(VisibilityOption v) async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(favoritesVisibility: _clamp(v)));
    } catch (e, stacktrace) {
      log(
        'Favoriler görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> changeCommentsVisibility(VisibilityOption v) async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(commentsVisibility: _clamp(v)));
    } catch (e, stacktrace) {
      log(
        'Yorumlar görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Erişilebilirlik ──────────────────────────────────────────────────────

  Future<void> toggleReducedMotion() async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(reducedMotion: !c.reducedMotion));
    } catch (e, stacktrace) {
      log(
        'Azaltılmış hareket değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> changeTextScale(double scale) async {
    try {
      final c = settings.value;
      if (c == null) return;
      await _updateSettings(c.copyWith(textScaleFactor: scale));
    } catch (e, stacktrace) {
      log(
        'Metin ölçeği değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
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
    } catch (e, stacktrace) {
      log(
        'Cache temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log('Çıkış yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
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
      } catch (e, stacktrace) {
        settings.value = old;
        log(
          'Ayarlar güncellenirken hata oluştu: $e',
          error: e,
          stackTrace: stacktrace,
        );
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
