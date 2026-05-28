// lib/app/bindings/home_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/profile_activity_repository.dart';
import '../../data/repositories/university_stats_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../presentation/controllers/favorites_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/profile_controller.dart';
//import '../../presentation/controllers/settings_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // ── Core Datasources ──────────────────────────────────────────────────
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource(), fenix: true);
    }

    // ── Repositories ──────────────────────────────────────────────────────
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(
        () => AuthRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<VideoRepository>()) {
      Get.lazyPut(
        () => VideoRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<FavoritesRepository>()) {
      Get.lazyPut(
        () => FavoritesRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<UniversityStatsRepository>()) {
      Get.lazyPut(
        () => UniversityStatsRepository(supabase: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProfileActivityRepository>()) {
      Get.lazyPut(
        () => ProfileActivityRepository(supabase: Get.find()),
        fenix: true,
      );
    }

    // ── Controllers ────────────────────────────────────────────────────────

    // DİKKAT: supabaseDataSource parametresi kaldırıldı, authRepository eklendi!
    Get.lazyPut(
      () => HomeController(
        videoRepository: Get.find(),
        favoritesRepository: Get.find(),
        universityStatsRepository: Get.find(),
        authRepository: Get.find(), // YENİ EKLENDİ
      ),
      fenix: true,
    );

    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut(
        () => ProfileController(
          authRepository: Get.find(),
          favoritesRepository: Get.find(),
          profileActivityRepository: Get.find(),
        ),
        fenix: true,
      );
    }

    Get.lazyPut(
      () => FavoritesController(favoritesRepository: Get.find()),
      fenix: true,
    );

    
  }
}
