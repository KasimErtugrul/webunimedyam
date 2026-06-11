// lib/app/bindings/shorts_binding.dart

import 'package:get/get.dart';

import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/shorts_repository.dart';
import '../../presentation/controllers/shorts_controller.dart';

class ShortsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }

    if (!Get.isRegistered<ShortsRepository>()) {
      Get.lazyPut(
        () => ShortsRepository(supabase: Get.find()),
        fenix: true,
      );
    }

    Get.lazyPut(
      () => ShortsController(repository: Get.find()),
      fenix: true,
    );
  }
}