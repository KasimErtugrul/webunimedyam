import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/engagement_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../presentation/controllers/player_controller.dart';

class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    // Core Datasources
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource(), fenix: true);
    }

    // Repositories
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(() => AuthRepository(
            supabase: Get.find(),
            local: Get.find(),
          ), fenix: true);
    }
    if (!Get.isRegistered<FavoritesRepository>()) {
      Get.lazyPut(() => FavoritesRepository(
            supabase: Get.find(),
            local: Get.find(),
          ), fenix: true);
    }
    // YENİ EKLENDİ
    if (!Get.isRegistered<EngagementRepository>()) {
      Get.lazyPut(() => EngagementRepository(
            supabase: Get.find(),
          ), fenix: true);
    }

    Get.lazyPut(() => CommentRepository(supabase: Get.find()));

    // Controller (Eski parametreler silindi, yeni repo ve auth eklendi)
    Get.lazyPut(() => PlayerController(
          favoritesRepository: Get.find(),
          commentRepository: Get.find(),
          engagementRepository: Get.find(), // YENİ
          authRepository: Get.find(),      // YENİ
        ));
  }
}