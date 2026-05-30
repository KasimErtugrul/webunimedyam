// lib/app/bindings/university_detail_binding.dart

import 'package:get/get.dart';

import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../presentation/controllers/university_detail_controller.dart';

class UniversityDetailBinding extends Bindings {
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
    if (!Get.isRegistered<UniversityFavoritesRepository>()) {
      Get.lazyPut(
        () => UniversityFavoritesRepository(supabase: Get.find()),
        fenix: true,
      );
    }

    Get.lazyPut(
      () => UniversityDetailController(
        videoRepository: Get.find(),
        universityFavoritesRepository: Get.find(),
      ),
      fenix: true,
    );
  }
}