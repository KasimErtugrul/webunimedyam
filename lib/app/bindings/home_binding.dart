import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/profile_controller.dart';
import '../../presentation/controllers/favorites_controller.dart';
import '../../presentation/controllers/settings_controller.dart';
import '../../data/repositories/auth_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupabaseDataSource());
    Get.lazyPut(() => LocalDataSource());

    Get.lazyPut(() => AuthRepository(
          supabase: Get.find(),
          local: Get.find(),
        ));

    Get.lazyPut(() => VideoRepository(
          supabase: Get.find(),
          local: Get.find(),
        ));

    Get.lazyPut(() => FavoritesRepository(
          supabase: Get.find(),
          local: Get.find(),
        ));

    Get.lazyPut(() => HomeController(
          videoRepository: Get.find(),
          favoritesRepository: Get.find(),
        ));

    Get.lazyPut(() => ProfileController(
          authRepository: Get.find(),
        ));

    Get.lazyPut(() => FavoritesController(
          favoritesRepository: Get.find(),
        ));

    Get.lazyPut(() => SettingsController(
          authRepository: Get.find(),
        ));
  }
}
