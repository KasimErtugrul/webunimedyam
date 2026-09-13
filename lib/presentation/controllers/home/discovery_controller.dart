import 'dart:developer';

import 'package:get/get.dart';

import '../../../data/models/university_stats_model.dart';
import '../../../data/models/video_engagement_model.dart';
import '../../../data/repositories/university_stats_repository.dart';
import '../../../data/repositories/video_repository.dart';

/// Keşfet sekmesinin verisi. Sekmeye ilk girildiğinde bir kez yüklenir.
class DiscoveryController extends GetxController {
  DiscoveryController({
    required this.universityStatsRepository,
    required this.videoRepository,
  });

  final UniversityStatsRepository universityStatsRepository;
  final VideoRepository videoRepository;

  final statsMostWatched = <UniversityStatsModel>[].obs;
  final statsMostLiked = <UniversityStatsModel>[].obs;
  final statsPopularInApp = <UniversityStatsModel>[].obs;
  final statsMostFavorited = <UniversityStatsModel>[].obs;
  final statsActiveLast30 = <UniversityStatsModel>[].obs;
  final statsBiggestChannels = <UniversityStatsModel>[].obs;
  final statsRichestArchive = <UniversityStatsModel>[].obs;
  final statsNewlyDiscovered = <UniversityStatsModel>[].obs;
  final isStatsLoading = false.obs;

  final videosTrending = <VideoEngagementModel>[].obs;
  final videosMostWatched = <VideoEngagementModel>[].obs;
  final videosMostLiked = <VideoEngagementModel>[].obs;
  final videosMostFavorited = <VideoEngagementModel>[].obs;
  final videosMostCommented = <VideoEngagementModel>[].obs;
  final videosNewUndiscovered = <VideoEngagementModel>[].obs;
  final isVideoSectionsLoading = false.obs;

  bool _initialized = false;

  /// Sekmeye ilk kez girildiğinde çağrılır; bir daha çalışmaz.
  Future<void> ensureLoaded() async {
    if (_initialized) return;
    _initialized = true;
    await Future.wait([loadUniversityStats(), loadVideoSections()]);
  }

  Future<void> loadUniversityStats() async {
    try {
      isStatsLoading.value = true;
      final bundle = await universityStatsRepository.getAllStats();
      statsMostWatched.value = bundle['most_watched'] ?? [];
      statsMostLiked.value = bundle['most_liked'] ?? [];
      statsPopularInApp.value = bundle['popular_in_app'] ?? [];
      statsMostFavorited.value = bundle['most_favorited'] ?? [];
      statsActiveLast30.value = bundle['most_active_last_30'] ?? [];
      statsBiggestChannels.value = bundle['biggest_channels'] ?? [];
      statsRichestArchive.value = bundle['richest_archive'] ?? [];
      statsNewlyDiscovered.value = bundle['newly_discovered'] ?? [];
    } catch (e, st) {
      log('Üniversite istatistikleri yüklenirken hata oluştu: $e',
          error: e, stackTrace: st);
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> loadVideoSections() async {
    try {
      isVideoSectionsLoading.value = true;
      final bundle = await videoRepository.getAllVideoSections();
      videosTrending.value = bundle['trending'] ?? [];
      videosMostWatched.value = bundle['most_watched'] ?? [];
      videosMostLiked.value = bundle['most_liked'] ?? [];
      videosMostFavorited.value = bundle['most_favorited'] ?? [];
      videosMostCommented.value = bundle['most_commented'] ?? [];
      videosNewUndiscovered.value = bundle['new_undiscovered'] ?? [];
    } catch (e, st) {
      log('Video bölümleri yüklenirken hata oluştu: $e', error: e, stackTrace: st);
    } finally {
      isVideoSectionsLoading.value = false;
    }
  }
}