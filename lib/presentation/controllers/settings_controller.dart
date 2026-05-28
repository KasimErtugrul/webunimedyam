import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_settings_model.dart';
import 'auth_controller.dart';

class SettingsController extends GetxService {
  final AuthRepository authRepository;

  SettingsController({required this.authRepository});

  final settings = Rxn<UserSettingsModel>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onReady() {
    super.onReady();
    loadSettings();
  }

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
    // SharedPreferences'a da yaz (main.dart startup için)
    await authRepository.saveThemeLocally(theme);
    // UI'ı anında güncelle
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

  // ─── Gizlilik ─────────────────────────────────────────────────────────────

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

  // ─── Erişilebilirlik ──────────────────────────────────────────────────────

  Future<void> toggleReducedMotion() async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(
      current.copyWith(reducedMotion: !current.reducedMotion),
    );
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
    final oldSettings = settings.value;
    try {
      settings.value = updated; // Optimistic UI
      await authRepository.updateUserSettings(updated);
    } catch (e) {
      settings.value = oldSettings; // Rollback
      log('_updateSettings error: $e');
      errorMessage.value = 'Ayarlar güncellenemedi.';
    }
  }
}