/* import 'package:get/get.dart';

import '../../data/repositories/video_repository.dart';
import '../../presentation/controllers/playlist_detail_controller.dart';

class PlaylistDetailBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VideoRepository>()) {
      Get.lazyPut(
        () => VideoRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }
    Get.lazyPut(
      () => PlaylistDetailController(videoRepository: Get.find()),
      fenix: true,
    );
  }
}
 */