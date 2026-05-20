import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/controllers/profile_controller.dart';

// DÜZELTME #5: ProfileBinding artık kendi bağımlılıklarını tam olarak sağlar.
// ProfileController.changeTab() artık HomeController'a bağımlı değil,
// dolayısıyla Profile sayfası tek başına açılsa da crash olmaz.
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource(), fenix: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(() => AuthRepository(
            supabase: Get.find(),
            local: Get.find(),
          ), fenix: true);
    }
    Get.lazyPut(() => ProfileController(
          authRepository: Get.find(),
          supabaseDataSource: Get.find(),
        ), fenix: true);
  }
}
