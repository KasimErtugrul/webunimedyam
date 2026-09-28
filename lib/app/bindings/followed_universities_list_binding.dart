// lib/app/bindings/followed_universities_list_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../presentation/controllers/followed_universities_list_controller.dart';

class FollowedUniversitiesListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(SupabaseDataSource.new, fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(LocalDataSource.new, fenix: true);
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

    Get.put(
      FollowedUniversitiesListController(
        universityFavoritesRepository: Get.find(),
      ),
    );
  }
}
