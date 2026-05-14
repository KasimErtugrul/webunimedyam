import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/models/video_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/datasources/local/local_datasource.dart';
import 'home_controller.dart';
import 'favorites_controller.dart';

class PlayerController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final CommentRepository commentRepository;

  PlayerController({
    required this.favoritesRepository,
    required this.commentRepository,
  });

  final _supabase = SupabaseDataSource();
  // ignore: unused_field
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

  void _showAuthDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Giriş Gerekiyor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu özelliği kullanmak için giriş yapmanız gerekiyor.',
          style: TextStyle(color: Color(0xFF9E9EB8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Vazgeç', style: TextStyle(color: Color(0xFF9E9EB8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              Get.toNamed('/login');
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  Future<void> toggleFavorite() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) {
      _showAuthDialog();
      return;
    }
    try {
      final wasAdding = !isFavorite.value;
      if (isFavorite.value) {
        // ─── Favori Kaldır ─────────────────────────────────────────────────
        // 1. Supabase'den kaldır
        await favoritesRepository.removeFavorite(userId, currentVideo!.videoId);
        // 2. Local'den kaldır
        await favoritesRepository.removeFavoriteVideoLocally(currentVideo!.videoId);
        isFavorite.value = false;
      } else {
        // ─── Favori Ekle ───────────────────────────────────────────────────
        // 1. Supabase'e ekle
        await favoritesRepository.addFavorite(userId, currentVideo!.videoId);
        // 2. Video bilgisiyle local'e kaydet
        await favoritesRepository.saveFavoriteVideoLocally(currentVideo!);
        isFavorite.value = true;
      }
      // HomeController varsa favoriteIds'i senkronize et
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        if (wasAdding) {
          homeController.favoriteIds.add(currentVideo!.videoId);
        } else {
          homeController.favoriteIds.remove(currentVideo!.videoId);
        }
      }
      // FavoritesController varsa UI'ı anında güncelle (local zaten yazıldı)
      if (Get.isRegistered<FavoritesController>()) {
        final favController = Get.find<FavoritesController>();
        if (wasAdding) {
          favController.favoriteVideos.insert(0, currentVideo!);
        } else {
          favController.favoriteVideos.removeWhere(
            (v) => v.videoId == currentVideo!.videoId,
          );
        }
      }
    } catch (e) {
      log('toggleFavorite error: $e');
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
      _showAuthDialog();
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