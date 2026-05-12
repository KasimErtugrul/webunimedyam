import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/datasources/local/local_datasource.dart';
import 'home_controller.dart';

class PlayerController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final CommentRepository commentRepository;

  PlayerController({
    required this.favoritesRepository,
    required this.commentRepository,
  });

  final _supabase = SupabaseDataSource();
  final _local = LocalDataSource();

  late YoutubePlayerController youtubeController;
  final comments = <CommentModel>[].obs;
  final isFavorite = false.obs;
  final isLoading = false.obs;
  final isCommentsLoading = false.obs;

  VideoModel? currentVideo;

  final isPlayerReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentVideo = Get.arguments as VideoModel?;
    if (currentVideo != null) {
      _initPlayer().then((_) {
        isPlayerReady.value = true;
        loadComments();
        checkFavorite();
      });
    }
  }

  Future<void> _initPlayer() async {
    // Önce Supabase'den, yoksa local'den autoplay ayarını oku
    bool autoplay = true;
    try {
      final userId = _supabase.currentUser?.id;
      if (userId != null) {
        final userSettings = await _supabase.getUserSettings(userId);
        autoplay = userSettings?.autoplay ?? true;
      }
    } catch (_) {}

    youtubeController = YoutubePlayerController(
      initialVideoId: currentVideo!.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: autoplay,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  Future<void> checkFavorite() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return;
    try {
      final ids = await favoritesRepository.getFavoriteVideoIds(userId);
      isFavorite.value = ids.contains(currentVideo!.videoId);
    } catch (_) {}
  }

  Future<void> toggleFavorite() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) {
      Get.toNamed('/login');
      return;
    }
    try {
      if (isFavorite.value) {
        await favoritesRepository.removeFavorite(userId, currentVideo!.videoId);
        isFavorite.value = false;
      } else {
        await favoritesRepository.addFavorite(userId, currentVideo!.videoId);
        isFavorite.value = true;
      }
      // HomeController varsa favoriteIds'i senkronize et
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        if (isFavorite.value) {
          homeController.favoriteIds.add(currentVideo!.videoId);
        } else {
          homeController.favoriteIds.remove(currentVideo!.videoId);
        }
      }
    } catch (e) {
      print('toggleFavorite error: $e');
    }
  }

  Future<void> loadComments() async {
    try {
      isCommentsLoading.value = true;
      comments.value = await commentRepository.getComments(currentVideo!.videoId);
    } catch (_) {} finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> addComment(String content) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) {
      Get.toNamed('/login');
      return;
    }
    if (content.trim().isEmpty) return;
    try {
      await commentRepository.addComment(
        userId: userId,
        videoId: currentVideo!.videoId,
        content: content.trim(),
      );
      await loadComments();
    } catch (_) {}
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await commentRepository.deleteComment(commentId);
      comments.removeWhere((c) => c.id == commentId);
    } catch (_) {}
  }

  @override
  void onClose() {
    youtubeController.dispose();
    super.onClose();
  }
}