import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/datasources/remote/youtube_datasource.dart';
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
    Get.lazyPut(() => LocalDataSource());
    Get.lazyPut(() => SupabaseDataSource());
    Get.lazyPut(() => YouTubeDataSource());

    Get.lazyPut(() => AuthRepository(
          supabase: Get.find(),
          local: Get.find(),
        ));

    Get.lazyPut(() => VideoRepository(
          local: Get.find(),
          youtube: Get.find(),
          supabase: Get.find(),
        ));

    Get.lazyPut(() => FavoritesRepository(supabase: Get.find()));

    Get.lazyPut(() => HomeController(
          videoRepository: Get.find(),
          favoritesRepository: Get.find(),
        ));

    Get.lazyPut(() => ProfileController(
          authRepository: Get.find(),
        ));

    Get.lazyPut(() => FavoritesController(
          favoritesRepository: Get.find(),
          videoRepository: Get.find(),
        ));

    Get.lazyPut(() => SettingsController(
          authRepository: Get.find(),
        ));
  }
}