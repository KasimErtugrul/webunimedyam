// lib/app/bindings/interest_selection_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../presentation/controllers/interest_selection_controller.dart';

class InterestSelectionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource(), fenix: true);
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

    Get.lazyPut(
      () => InterestSelectionController(
        supabase: Get.find(),
        authRepository: Get.find(),
        universityFavoritesRepository: Get.find(),
        local: Get.find(),
      ),
    );
  }
}