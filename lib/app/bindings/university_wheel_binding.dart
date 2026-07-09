/* // lib/app/bindings/university_wheel_binding.dart

import 'package:get/get.dart';

import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/video_repository.dart';
import '../../presentation/controllers/university_wheel_controller.dart';

class UniversityWheelBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource(), fenix: true);
    }
    if (!Get.isRegistered<VideoRepository>()) {
      Get.lazyPut(
        () => VideoRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    Get.lazyPut(
      () => UniversityWheelController(videoRepository: Get.find()),
      fenix: true,
    );
  }
}
 */