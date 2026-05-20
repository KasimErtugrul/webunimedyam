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
    // DÜZELTME #1: fenix:true ile singleton'lar korunur; her binding yeniden oluşturmaz.
    Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    Get.lazyPut(() => LocalDataSource(), fenix: true);

    Get.lazyPut(() => AuthRepository(
          supabase: Get.find(),
          local: Get.find(),
        ), fenix: true);

    Get.lazyPut(() => VideoRepository(
          supabase: Get.find(),
          local: Get.find(),
        ), fenix: true);

    Get.lazyPut(() => FavoritesRepository(
          supabase: Get.find(),
          local: Get.find(),
        ), fenix: true);

    Get.lazyPut(() => HomeController(
          videoRepository: Get.find(),
          favoritesRepository: Get.find(),
          supabaseDataSource: Get.find(), // DÜZELTME #1
        ), fenix: true);

    Get.lazyPut(() => ProfileController(
          authRepository: Get.find(),
          supabaseDataSource: Get.find(), // DÜZELTME #1
        ), fenix: true);

    Get.lazyPut(() => FavoritesController(
          favoritesRepository: Get.find(),
        ), fenix: true);

    Get.lazyPut(() => SettingsController(
          authRepository: Get.find(),
        ), fenix: true);
  }
}
