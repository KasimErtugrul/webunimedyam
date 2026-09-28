// lib/app/bindings/interest_selection_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../presentation/controllers/interest_selection_controller.dart';

class InterestSelectionBinding extends Bindings {
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
    if (!Get.isRegistered<UniversityFavoritesRepository>()) {
      Get.lazyPut(
        () => UniversityFavoritesRepository(
          supabase: Get.find(),
          local: Get.find(),
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<VideoRepository>()) {
      Get.lazyPut(
        () => VideoRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    Get.lazyPut(
      () => InterestSelectionController(
        videoRepository: Get.find(),
        authRepository: Get.find(),
        universityFavoritesRepository: Get.find(),
        local: Get.find(),
      ),
    );
  }
}