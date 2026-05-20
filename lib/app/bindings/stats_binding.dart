import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/stats_repository.dart';
import '../../presentation/controllers/stats_controller.dart';

class StatsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource(), fenix: true);
    }
    Get.lazyPut(
      () => StatsRepository(
        supabaseDataSource: Get.find(),
        localDataSource: Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => StatsController(statsRepository: Get.find()),
      fenix: true,
    );
  }
}