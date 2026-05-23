// lib/app/bindings/profile_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/favorites_repository.dart'; // YENİ EKLENDİ
import '../../presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource(), fenix: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(() => AuthRepository(
            supabase: Get.find(),
            local: Get.find(),
          ), fenix: true);
    }
    // FIX: FavoritesRepository kaydı eklendi!
    if (!Get.isRegistered<FavoritesRepository>()) {
      Get.lazyPut(() => FavoritesRepository(
            supabase: Get.find(),
            local: Get.find(),
          ), fenix: true);
    }
    
    // FIX: favoritesRepository parametresi eklendi!
    Get.lazyPut(() => ProfileController(
          authRepository: Get.find(),
          supabaseDataSource: Get.find(),
          favoritesRepository: Get.find(), // YENİ EKLENDİ
        ), fenix: true);
  }
}