// lib/app/bindings/signup_preferences_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/controllers/settings_controller.dart';
import '../../presentation/controllers/signup_preferences_controller.dart';

class SignupPreferencesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(SupabaseDataSource.new, fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(LocalDataSource.new, fenix: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(
        () => AuthRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }
    // SettingsController normalde main.dart içinde permanent olarak
    // kaydedilir (uygulama açılışında). Splash atlanmış vb. bir senaryoda
    // yine de kayıtlı değilse burada güvenlik amacıyla oluşturuyoruz.
    if (!Get.isRegistered<SettingsController>()) {
      Get.lazyPut(
        () => SettingsController(authRepository: Get.find()),
        fenix: true,
      );
    }

    Get.lazyPut(
      () => SignupPreferencesController(settingsController: Get.find()),
    );
  }
}
