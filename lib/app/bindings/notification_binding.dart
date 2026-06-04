// lib/app/bindings/follow_binding.dart

import 'package:get/get.dart';

import '../../presentation/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
  
    if (!Get.isRegistered<NotificationsController>()) {
      Get.lazyPut(
        () => NotificationsController(followRepository: Get.find()),
        fenix: true,
      );
    }
  }
}