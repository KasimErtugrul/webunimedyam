import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../presentation/controllers/player_controller.dart';

class PlayerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource());
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource());
    }
    if (!Get.isRegistered<FavoritesRepository>()) {
      Get.lazyPut(() => FavoritesRepository(
            supabase: Get.find(),
            local: Get.find(),
          ));
    }

    Get.lazyPut(() => CommentRepository(supabase: Get.find()));

    Get.lazyPut(() => PlayerController(
          favoritesRepository: Get.find(),
          commentRepository: Get.find(),
        ));
  }
}
