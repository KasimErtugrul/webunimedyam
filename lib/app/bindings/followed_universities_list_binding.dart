// lib/app/bindings/followed_universities_list_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../presentation/controllers/followed_universities_list_controller.dart';

class FollowedUniversitiesListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<UniversityFavoritesRepository>()) {
      Get.lazyPut(
        () => UniversityFavoritesRepository(supabase: Get.find()),
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
