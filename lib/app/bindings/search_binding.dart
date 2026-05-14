import 'package:get/get.dart';
import '../../data/datasources/local/search_history_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/search_repository.dart';
import '../../presentation/controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SupabaseDataSource());
    Get.lazyPut(() => SearchHistoryDataSource());
    Get.lazyPut(() => SearchRepository(supabase: Get.find()));
    Get.lazyPut(() => SearchController(
          searchRepository: Get.find(),
          historyDataSource: Get.find(),
        ));
  }
}
