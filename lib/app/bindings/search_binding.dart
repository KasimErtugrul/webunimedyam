import 'package:get/get.dart';
import '../../data/datasources/local/search_history_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/search_repository.dart';
import '../../presentation/controllers/video_search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    Get.lazyPut(() => SearchHistoryDataSource(), fenix: true);
    Get.lazyPut(() => SearchRepository(supabase: Get.find()), fenix: true);
    Get.lazyPut(
      () => VideoSearchController(
        searchRepository: Get.find(),
        historyDataSource: Get.find(),
      ),
      fenix: true,
    );
  }
}
