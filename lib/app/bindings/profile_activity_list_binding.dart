// lib/app/bindings/profile_activity_list_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/profile_activity_repository.dart';
import '../../presentation/controllers/profile_activity_list_controller.dart';

class ProfileActivityListBinding extends Bindings {
  @override
  void dependencies() {
    // Bunlar zaten oluşturulmuş olmalı (HomeBinding kayıt eder)
    // ama kayıtlı değilse güvenli şekilde oluştur
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.put(SupabaseDataSource(), permanent: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.put(LocalDataSource(), permanent: true);
    }

    final supabase = Get.find<SupabaseDataSource>();
    final local = Get.find<LocalDataSource>();

    if (!Get.isRegistered<FavoritesRepository>()) {
      Get.put(
        FavoritesRepository(supabase: supabase, local: local),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ProfileActivityRepository>()) {
      Get.put(
        ProfileActivityRepository(supabase: supabase),
        permanent: true,
      );
    }

    Get.put(
      ProfileActivityListController(
        favoritesRepository: Get.find<FavoritesRepository>(),
        profileActivityRepository: Get.find<ProfileActivityRepository>(),
      ),
    );
  }
}