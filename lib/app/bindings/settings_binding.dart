import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupabaseDataSource());
    Get.lazyPut(() => LocalDataSource());

    Get.lazyPut(() => AuthRepository(
          supabase: Get.find(),
          local: Get.find(),
        ));

    Get.lazyPut(() => SettingsController(
          authRepository: Get.find(),
        ));
  }
}
