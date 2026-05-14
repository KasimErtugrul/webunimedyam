import 'package:get/get.dart';

import '../../data/datasources/local/local_datasource.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../presentation/controllers/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource());
    }
    if (!Get.isRegistered<FavoritesRepository>()) {
      Get.lazyPut(() => FavoritesRepository(
            supabase: Get.find(),
            local: Get.find(),
          ));
    }
    Get.lazyPut(() => FavoritesController(
          favoritesRepository: Get.find(),
        ));
  }
}
