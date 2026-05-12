import 'package:get/get.dart';

import '../../presentation/controllers/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FavoritesController(
          favoritesRepository: Get.find(),
          videoRepository: Get.find(),
        ));
  }
}