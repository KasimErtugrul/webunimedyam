// lib/app/bindings/shorts_player_binding.dart

import 'package:get/get.dart';

import '../../presentation/controllers/shorts_player_controller.dart';

class ShortsPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ShortsPlayerController>(ShortsPlayerController());
  }
}
