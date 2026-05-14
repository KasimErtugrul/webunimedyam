import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../presentation/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LocalDataSource());
    Get.lazyPut(() => SupabaseDataSource());

    Get.lazyPut(() => AuthRepository(
          supabase: Get.find(),
          local: Get.find(),
        ));

    Get.lazyPut(() => VideoRepository(
          local: Get.find(),
          supabase: Get.find(),
        ));

    Get.lazyPut(() => SplashController(
          authRepository: Get.find(),
        ));
  }
}
