// lib/presentation/controllers/playlist_detail_controller.dart
import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/video_repository.dart';
import '../../data/models/playlist_model.dart';
import '../../data/models/video_model.dart';

class PlaylistDetailController extends GetxController {
  final VideoRepository videoRepository;

  PlaylistDetailController({required this.videoRepository});

  late PlaylistModel playlist;

  final videos = <VideoModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    playlist = Get.arguments as PlaylistModel;
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      videos.value = await videoRepository.getPlaylistVideos(playlist.playlistId);
    } catch (e) {
      log('PlaylistDetail loadVideos error: $e');
      errorMessage.value = 'Videolar yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }
}