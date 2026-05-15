import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/themes/app_theme.dart';
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
    } catch (_) {} finally {
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
    await _updateSettings(updated);
    Get.changeTheme(theme == 'dark' ? AppTheme.darkTheme : AppTheme.lightTheme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
  }

  Future<void> changeLanguage(String language) async {
    final current = settings.value;
    if (current == null) return;
    final updated = current.copyWith(language: language);
    await _updateSettings(updated);
  }

  Future<void> _updateSettings(UserSettingsModel updated) async {
    try {
      await authRepository.updateUserSettings(updated);
      settings.value = updated;
    } catch (_) {
      Get.snackbar('Hata', 'Ayarlar güncellenemedi.');
    }
  }

  Future<void> signOut() async {
    try {
      await authRepository.signOut();
      Get.offAllNamed('/home');
    } catch (_) {
      Get.snackbar('Hata', 'Çıkış yapılırken hata oluştu.');
    }
  }
}