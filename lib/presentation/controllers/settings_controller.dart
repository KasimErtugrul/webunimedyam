// lib/presentation/controllers/settings_controller.dart

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/user_settings_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/analytics_service.dart';
import 'auth/session_controller.dart';
import 'profile_controller.dart';

class SettingsController extends GetxService {
  final AuthRepository authRepository;

  SettingsController({required this.authRepository});
  // ═════════ Tasarımdan gelen ek tercihler (UI state) ═════════
  // Kalıcılık (DB/local) istenirse _updateSettings desenine taşınabilir.
  final videoQuality = '1080p (FHD)'.obs;
  final subtitlesEnabled = false.obs; // Ders Altyazıları (tasarımda kapalı)
  final reduceMotion = false.obs; // Hareketi Azalt (tasarımda kapalı)
  final notifyInteractions = true.obs; // Yorum Yanıtı ve Beğeniler (açık)
  final cacheBadgeCleared = false.obs; // "124 MB temizle" rozet flash'ı

  final settings = Rxn<UserSettingsModel>();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final profileVisibility = VisibilityOption.public.obs;

  // Ana sayfa görünümü (liste/wheel). `settings.value` girişsiz kullanıcılar
  // için null kalabildiğinden, ekranın her zaman doğru değeri gösterebilmesi
  // için ayrı bir Rx olarak tutulur — kaynağı AuthRepository.getHomeLayout()
  // (önce yerel, yoksa Supabase) ve senkronize kalır.
  final homeLayout = 'list'.obs;

  Timer? _settingsDebounce;
  UserSettingsModel? _lastSavedSettings;

  // ─── Tavan kontrolü ───────────────────────────────────────────────────────
  static const _order = [VisibilityOption.private, VisibilityOption.public];

  VisibilityOption _clamp(VisibilityOption activity) {
    final ceiling = profileVisibility.value;
    if (_order.indexOf(activity) > _order.indexOf(ceiling)) return ceiling;
    return activity;
  }

  bool isAllowed(VisibilityOption option) {
    return _order.indexOf(option) <= _order.indexOf(profileVisibility.value);
  }

  void changeVideoQuality(String quality) => videoQuality.value = quality;

  void toggleSubtitles([bool? value]) =>
      subtitlesEnabled.value = value ?? !subtitlesEnabled.value;

  void toggleReduceMotion([bool? value]) =>
      reduceMotion.value = value ?? !reduceMotion.value;

  void toggleNotifyInteractions([bool? value]) =>
      notifyInteractions.value = value ?? !notifyInteractions.value;

  /// clearCache + tasarımdaki rozet davranışı ("Temizlendi (0 KB)").
  Future<void> clearCacheWithBadge() async {
    await clearCache();
    cacheBadgeCleared.value = true;
    Timer(const Duration(seconds: 2), () => cacheBadgeCleared.value = false);
  }

  // ─── Yükleme ──────────────────────────────────────────────────────────────

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      settings.value = await authRepository.getUserSettings();
      _syncProfileVisibilityFromController();

      // Ana sayfa görünümü, giriş yapılmasa bile önce yerelden okunur;
      // yerelde yoksa (ilk kurulum vb.) tam ayarlar üzerinden Supabase'e
      // düşer (bkz. AuthRepository.getHomeLayout).
      homeLayout.value = await authRepository.getHomeLayout();

      // Mevcut tema tercihini user property olarak set ediyoruz ki
      // kullanıcı hiç tema değiştirmese bile Firebase'de doğru segmentte
      // görünsün (light/dark/system dağılımını Audience/User properties'te
      // görebilmek için).
      final loadedTheme = settings.value?.theme;
      if (loadedTheme != null) {
        AnalyticsService.instance.setUserProperty(
          name: 'app_theme',
          value: loadedTheme,
        );
      }
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

      AnalyticsService.instance.logEvent(
        'theme_change',
        parameters: {'theme': theme},
      );
      AnalyticsService.instance.setUserProperty(
        name: 'app_theme',
        value: theme,
      );

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

  /// Ana sayfa besleme görünümünü değiştirir: 'list' veya 'wheel'.
  ///
  /// Sıralama: önce yerele YAZILIR (girişsiz kullanıcılarda da anında
  /// çalışsın diye), sonra kullanıcı giriş yapmışsa tam ayarlar üzerinden
  /// Supabase'e senkronize edilir (debounce'lu _updateSettings ile). Ayrıca
  /// halihazırda açık olan Ana Sayfa varsa (HomeController) anında
  /// güncellensin diye o da senkronize edilir.
  Future<void> changeHomeLayout(String layout) async {
    final old = homeLayout.value;
    homeLayout.value = layout; // Optimistic UI
    try {
      await authRepository.saveHomeLayoutLocally(layout);

      final current = settings.value;
      if (current != null) {
        await _updateSettings(current.copyWith(homeLayout: layout));
      }

      AnalyticsService.instance.logEvent(
        'home_layout_change',
        parameters: {'layout': layout},
      );
    } catch (e, stacktrace) {
      homeLayout.value = old; // Rollback
      log(
        'Ana sayfa görünümü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ana sayfa görünümü değiştirilemedi.';
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
    final userId = authRepository.currentUserId;
    final current = settings.value;
    log(
      'changeProfileVisibility: userId=$userId, newVisibility=$newVisibility, current=$current',
    );
    if (userId == null || current == null) return;

    final oldVisibility = profileVisibility.value;
    profileVisibility.value = newVisibility; // Optimistic UI

    try {
      // BUG FIX: Bu satır artık YORUM SATIRI DEĞİL — DB'ye yazılıyor
      await authRepository.updateProfileVisibility(userId, newVisibility.value);
      log(
        'changeProfileVisibility: DB güncellemesi başarılı: userId=$userId, newVisibility=$newVisibility',
      );
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
      if (Get.isRegistered<SessionController>()) {
        await Get.find<SessionController>().signOut();
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
