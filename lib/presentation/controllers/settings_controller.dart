import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_settings_model.dart';

class SettingsController extends GetxController {
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
    final updated = current.copyWith(
      autoplay: !current.autoplay,
    );
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

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      Get.offAllNamed('/home');
    } catch (e) {
      log('signOut error: $e');
      // YENİ: Get.snackbar yerine bayrak kaldırılıyor
      errorMessage.value = 'Çıkış yapılırken hata oluştu.';
    }
  }
}