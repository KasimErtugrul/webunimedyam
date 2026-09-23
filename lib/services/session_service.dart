import 'package:get/get.dart';

import '../presentation/controllers/favorites_controller.dart';
import '../presentation/controllers/home/home_controller.dart';
import '../presentation/controllers/settings_controller.dart';
import '../data/models/user_settings_model.dart';
import 'notification_service.dart';

/// Giriş/çıkış sonrası ortak yan etkiler.
class SessionService extends GetxService {
  Future<void> onLogin() async {
    await NotificationService.instance.onUserLogin();
    if (Get.isRegistered<SettingsController>()) {
      final settings = Get.find<SettingsController>();
      await settings.loadSettings();
      // Hesabın tema tercihi (ör. koyu) yeniden başlatma beklemeden devreye girer.
      await settings.applyAccountTheme();
    }
  }

  Future<void> onLogout() async {
    await NotificationService.instance.onUserLogout();

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().favoriteIds.clear();
    }
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().favoriteVideos.clear();
    }
    if (Get.isRegistered<SettingsController>()) {
      final s = Get.find<SettingsController>();
      s.settings.value = null;
      s.profileVisibility.value = VisibilityOption.public;
    }
  }
}