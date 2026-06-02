// lib/presentation/controllers/settings_controller.dart
// MEVCUT DOSYANIN ÜSTÜNE YAZAR

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_settings_model.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import 'auth_controller.dart';

class SettingsController extends GetxService {
  final AuthRepository authRepository;
  final SupabaseDataSource _supabase;

  SettingsController({
    required this.authRepository,
    required SupabaseDataSource supabase,
  }) : _supabase = supabase;

  final settings      = Rxn<UserSettingsModel>();
  final isLoading     = false.obs;
  final errorMessage  = RxnString();

  Timer? _settingsDebounce;
  UserSettingsModel? _lastSavedSettings;

  // ─── Yükleme ──────────────────────────────────────────────────────────────

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      settings.value = await authRepository.getUserSettings();
    } catch (e) {
      log('loadSettings error: $e');
    } finally {
      isLoading.value = false;
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
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(autoplay: !current.autoplay));
  }

  Future<void> toggleSubtitles() async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(showSubtitles: !current.showSubtitles));
  }

  Future<void> changeVideoQuality(String quality) async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(videoQuality: quality));
  }

  // ─── Bildirimler ──────────────────────────────────────────────────────────

  Future<void> toggleNotifications() async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(
      current.copyWith(notificationsEnabled: !current.notificationsEnabled),
    );
  }

  Future<void> toggleNotifyNewVideos() async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(
      current.copyWith(notifyNewVideos: !current.notifyNewVideos),
    );
  }

  Future<void> toggleNotifyCommentReplies() async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(
      current.copyWith(notifyCommentReplies: !current.notifyCommentReplies),
    );
  }

  Future<void> toggleNotifyFollowRequests() async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(
      current.copyWith(notifyFollowRequests: !current.notifyFollowRequests),
    );
  }

  // ─── Gizlilik — Eski ──────────────────────────────────────────────────────

  Future<void> toggleWatchHistory() async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(
      current.copyWith(showWatchHistory: !current.showWatchHistory),
    );
  }

  Future<void> toggleFavoritesPublic() async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(
      current.copyWith(showFavoritesPublic: !current.showFavoritesPublic),
    );
  }

  // ─── Gizlilik — YENİ Visibility ───────────────────────────────────────────

  /// Profil görünürlüğünü günceller (profiles tablosu + ayarlar)
  Future<void> changeProfileVisibility(VisibilityOption visibility) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;

    try {
      // profiles tablosunu güncelle
      await _supabase.updateProfileVisibility(userId, visibility.value);
      log('⚙️✅ [Settings] profileVisibility → ${visibility.value}');
    } catch (e) {
      log('changeProfileVisibility error: $e');
      errorMessage.value = 'Profil görünürlüğü güncellenemedi.';
    }
  }

  Future<void> changeWatchHistoryVisibility(VisibilityOption v) async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(watchHistoryVisibility: v));
  }

  Future<void> changeLikesVisibility(VisibilityOption v) async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(likesVisibility: v));
  }

  Future<void> changeFavoritesVisibility(VisibilityOption v) async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(favoritesVisibility: v));
  }

  Future<void> changeCommentsVisibility(VisibilityOption v) async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(commentsVisibility: v));
  }

  // ─── Erişilebilirlik ──────────────────────────────────────────────────────

  Future<void> toggleReducedMotion() async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(reducedMotion: !current.reducedMotion));
  }

  Future<void> changeTextScale(double scale) async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(textScaleFactor: scale));
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
    final oldSettings = _lastSavedSettings ?? settings.value;
    settings.value = updated; // Optimistic UI

    _settingsDebounce?.cancel();
    _settingsDebounce = Timer(const Duration(milliseconds: 800), () async {
      try {
        await authRepository.updateUserSettings(updated);
        _lastSavedSettings = updated;
        log('⚙️✅ [Settings] Supabase\'e yazıldı (debounce)');
      } catch (e) {
        settings.value = oldSettings; // Rollback
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