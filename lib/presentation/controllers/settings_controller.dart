import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_settings_model.dart';

class SettingsController extends GetxController {
  final AuthRepository authRepository;

  SettingsController({required this.authRepository});

  final settings = Rxn<UserSettingsModel>();
  final isLoading = false.obs;

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
    final updated = current.copyWith(
      autoplay: !current.autoplay,
    );
    await _updateSettings(updated);
  }

  Future<void> changeTheme(String theme) async {
    final current = settings.value;
    if (current == null) return;
    final updated = current.copyWith(theme: theme);
    
    // Temayı anında değiştir (Optimistic UI)
    Get.changeThemeMode(
      theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
    );
    
    // FIX: SharedPreferences bypass KALDIRILDI! 
    // authRepository.updateUserSettings zaten local cache'e (SP) yazıyor.
    await _updateSettings(updated);
  }

  Future<void> changeLanguage(String language) async {
    final current = settings.value;
    if (current == null) return;
    final updated = current.copyWith(language: language);
    await _updateSettings(updated);
  }

  // FIX: Optimistic UI ve Rollback mekanizması eklendi.
  Future<void> _updateSettings(UserSettingsModel updated) async {
    final oldSettings = settings.value; // Eski ayarı yedekle
    try {
      settings.value = updated; // Kullanıcıya anında güncellenmiş gibi göster
      await authRepository.updateUserSettings(updated);
    } catch (e) {
      settings.value = oldSettings; // Hata olursa UI'ı eski haline döndür!
      log('_updateSettings error: $e');
      
      // TODO: MİMARİ BORÇ (Tech Debt) - Get.snackbar UI kodudur, Controller'da olmamalıdır.
      Get.snackbar('Hata', 'Ayarlar güncellenemedi.');
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      Get.offAllNamed('/home');
    } catch (e) {
      log('signOut error: $e');
      
      // TODO: MİMARİ BORÇ (Tech Debt) - Get.snackbar UI kodudur, Controller'da olmamalıdır.
      Get.snackbar('Hata', 'Çıkış yapılırken hata oluştu.');
    }
  }
}