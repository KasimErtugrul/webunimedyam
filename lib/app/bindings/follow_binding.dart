/* // lib/app/bindings/follow_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/follow_repository.dart';
import '../../presentation/controllers/follow_controller.dart';

class FollowBinding extends Bindings {
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
    if (!Get.isRegistered<FollowRepository>()) {
      Get.lazyPut(
        () => FollowRepository(supabase: Get.find()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<FollowController>()) {
      Get.lazyPut(
        () => FollowController(followRepository: Get.find()),
        fenix: true,
      );
    }
  }
} */