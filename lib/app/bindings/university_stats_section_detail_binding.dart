// lib/app/bindings/university_stats_section_detail_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/university_stats_repository.dart';
import '../../presentation/controllers/university_stats_section_detail_controller.dart';

class UniversityStatsSectionDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(SupabaseDataSource.new, fenix: true);
    }
    if (!Get.isRegistered<UniversityStatsRepository>()) {
      Get.lazyPut(
        () => UniversityStatsRepository(supabase: Get.find()),
        fenix: true,
      );
    }
    Get.lazyPut(
      () => UniversityStatsSectionDetailController(
        universityStatsRepository: Get.find(),
      ),
      fenix: true,
    );
  }
}
