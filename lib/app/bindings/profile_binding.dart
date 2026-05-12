import 'package:get/get.dart';
import '../../presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController(
          authRepository: Get.find(),
        ));
  }
}