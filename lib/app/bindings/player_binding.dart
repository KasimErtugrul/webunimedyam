import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/engagement_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../presentation/controllers/player_controller.dart';
import '../../data/repositories/video_repository.dart';

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
      Get.lazyPut(
        () => AuthRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<FavoritesRepository>()) {
      Get.lazyPut(
        () => FavoritesRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }
    // YENİ EKLENDİ
    if (!Get.isRegistered<EngagementRepository>()) {
      Get.lazyPut(
        () => EngagementRepository(supabase: Get.find()),
        fenix: true,
      );
    }

    Get.lazyPut(() => CommentRepository(supabase: Get.find()), fenix: true);

    if (!Get.isRegistered<VideoRepository>()) {
      Get.lazyPut(
        () => VideoRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    Get.put<PlayerController>(
      PlayerController(
        favoritesRepository: Get.find(),
        commentRepository: Get.find(),
        engagementRepository: Get.find(),
        authRepository: Get.find(),
        videoRepository: Get.find(), // ← YENİ
      ),

      permanent: false,
      tag:Get.parameters['videoId'] ?? '123', // Her video için benzersiz bir tag kullan
      //fenix: true,
    );
  }
}
