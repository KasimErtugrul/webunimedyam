// lib/presentation/controllers/profile_activity_list_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/profile_activity_repository.dart';
import '../../data/models/video_model.dart';

enum ProfileActivityType { favorites, viewed, commented, shared }

class ProfileActivityListController extends GetxController {
  final FavoritesRepository favoritesRepository;
  final ProfileActivityRepository profileActivityRepository;

  ProfileActivityListController({
    required this.favoritesRepository,
    required this.profileActivityRepository,
  });

  static const int _pageSize = 10;

  final videos = <VideoModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  late final ProfileActivityType activityType;
  late final String userId;
  late final bool isOwnProfile;

  int _offset = 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    activityType = args['type'] as ProfileActivityType;
    userId = args['userId'] as String;
    isOwnProfile = args['isOwnProfile'] as bool? ?? true;
    loadInitial();
  }

  Future<void> loadInitial() async {
    _offset = 0;
    hasMore.value = true;
    videos.clear();
    await _fetchPage();
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    await _fetchPage(isMore: true);
  }

  Future<void> _fetchPage({bool isMore = false}) async {
    try {
      if (isMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }

      final result = await _fetchByType(
        userId: userId,
        limit: _pageSize,
        offset: _offset,
      );

      if (result.length < _pageSize) {
        hasMore.value = false;
      }

      videos.addAll(result);
      _offset += result.length;
    } catch (e, stacktrace) {
      log('Aktivite listesi yüklenirken hata: $e', error: e, stackTrace: stacktrace);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<List<VideoModel>> _fetchByType({
    required String userId,
    required int limit,
    required int offset,
  }) {
    switch (activityType) {
      case ProfileActivityType.favorites:
        return favoritesRepository.getUserFavoriteVideos(userId, limit: limit, offset: offset);
      case ProfileActivityType.viewed:
        return profileActivityRepository.getUserViewedVideos(userId, limit: limit, offset: offset);
      case ProfileActivityType.commented:
        return profileActivityRepository.getUserCommentedVideos(userId, limit: limit, offset: offset);
      case ProfileActivityType.shared:
        return profileActivityRepository.getUserSharedVideos(userId, limit: limit, offset: offset);
    }
  }

  String get pageTitle {
    switch (activityType) {
      case ProfileActivityType.favorites:
        return 'Favoriler';
      case ProfileActivityType.viewed:
        return 'İzlenenler';
      case ProfileActivityType.commented:
        return 'Yorum Yapılanlar';
      case ProfileActivityType.shared:
        return 'Paylaşılanlar';
    }
  }

  IconData get emptyIcon {
    switch (activityType) {
      case ProfileActivityType.favorites:
        return 468985; // Icons.favorite_outline_rounded codepoint — kullanılmıyor
      case ProfileActivityType.viewed:
        return 0;
      case ProfileActivityType.commented:
        return 0;
      case ProfileActivityType.shared:
        return 0;
    }
  }

  String get emptyText {
    if (isOwnProfile) {
      switch (activityType) {
        case ProfileActivityType.favorites:
          return 'Henüz favori eklemedin';
        case ProfileActivityType.viewed:
          return 'Henüz video izlemedin';
        case ProfileActivityType.commented:
          return 'Henüz yorum yapmadın';
        case ProfileActivityType.shared:
          return 'Henüz paylaşım yapmadın';
      }
    }
    return 'İçerik bulunamadı';
  }

  String get emptySubtext {
    if (isOwnProfile) {
      switch (activityType) {
        case ProfileActivityType.favorites:
          return 'Beğendiğin videoları favorilere ekle';
        case ProfileActivityType.viewed:
          return 'İzlediğin videolar burada görünür';
        case ProfileActivityType.commented:
          return 'Yorum yaptığın videolar burada görünür';
        case ProfileActivityType.shared:
          return 'Paylaştığın videolar burada görünür';
      }
    }
    return 'Bu kullanıcının içerikleri gizli olabilir';
  }
}
