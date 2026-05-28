import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_settings_model.dart';
import 'auth_controller.dart';

class SettingsController extends GetxService {
  final AuthRepository authRepository;

  SettingsController({required this.authRepository});

  final settings = Rxn<UserSettingsModel>();
  final isLoading = false.obs;

  // YENİ EKLENDİ: UI'ın dinleyeceği bayrak
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

  Future<void> toggleNotifications() async {
    final current = settings.value;
    if (current == null) return;
    final updated = current.copyWith(
      notificationsEnabled: !current.notificationsEnabled,
    );
    await _updateSettings(updated);
  }

  Future<void> toggleAutoplay() async {
    final current = settings.value;
    if (current == null) return;
    final updated = current.copyWith(autoplay: !current.autoplay);
    await _updateSettings(updated);
  }

  // settings_controller.dart'ta changeTheme sadece ayarı kaydetsin:
  Future<void> changeTheme(String theme) async {
    final current = settings.value;
    if (current == null) return;
    await _updateSettings(current.copyWith(theme: theme));
    // Get.changeThemeMode buradan kalktı ↑
  }

  Future<void> changeLanguage(String language) async {
    final current = settings.value;
    if (current == null) return;
    final updated = current.copyWith(language: language);
    await _updateSettings(updated);
  }

  Future<void> _updateSettings(UserSettingsModel updated) async {
    final oldSettings = settings.value;
    try {
      settings.value = updated; // Optimistic UI
      await authRepository.updateUserSettings(updated);
    } catch (e) {
      settings.value = oldSettings; // Rollback
      log('_updateSettings error: $e');
      // YENİ: Get.snackbar yerine bayrak kaldırılıyor
      errorMessage.value = 'Ayarlar güncellenemedi.';
    }
  }

  Future<void> clearCache() async {
  try {
    isLoading.value = true;
    // AuthRepository üzerinden local datasource'a eriş
    // ya da doğrudan LocalDataSource'u inject et
    await authRepository.clearLocalCache();
    errorMessage.value = null;
    Get.snackbar(
      'Başarılı',
      'Cache temizlendi.',
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

  // lib/presentation/controllers/settings_controller.dart
  Future<void> signOut() async {
    try {
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().signOut();
      } else {
        // AuthController yoksa direkt AuthRepository'ye git
        await authRepository.signOut();
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      log('signOut delegate error: $e');
      errorMessage.value = 'Çıkış yapılırken hata oluştu.';
    }
  }
}
