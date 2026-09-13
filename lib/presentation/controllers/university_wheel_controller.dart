// lib/presentation/controllers/university_wheel_controller.dart
//
// "Üniversite Radarı" ekranının controller'ı.
// Solda wheel slider ile gezilen üniversite listesini, sağda ise o anda
// aktif (ortadaki) üniversitenin videolarını ("haberlerini") yönetir.

import 'dart:developer';

import 'package:get/get.dart';

import '../../data/models/university_model.dart';
import '../../data/models/video_model.dart';
import '../../data/repositories/video_repository.dart';
import 'home/home_controller.dart';

class UniversityWheelController extends GetxController {
  final VideoRepository videoRepository;

  UniversityWheelController({required this.videoRepository});

  // ─── State ─────────────────────────────────────────────────────────────
  final universities = <UniversityModel>[].obs;
  final isLoadingUniversities = true.obs;
  final universitiesError = ''.obs;

  final selectedIndex = 0.obs;

  final videos = <VideoModel>[].obs;
  final isLoadingVideos = false.obs;
  final videosError = ''.obs;

  UniversityModel? get selectedUniversity =>
      (universities.isEmpty || selectedIndex.value >= universities.length)
      ? null
      : universities[selectedIndex.value];

  @override
  void onInit() {
    super.onInit();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      isLoadingUniversities.value = true;
      universitiesError.value = '';

      // Ana sayfa zaten yüklediyse tekrar ağa gitmeye gerek yok.
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        if (home.universities.isNotEmpty) {
          universities.assignAll(home.universities);
        }
      }

      if (universities.isEmpty) {
        final rows = await videoRepository.getUniversitiesAndPlaylists();
        universities.assignAll(
          rows.map((r) => UniversityModel.fromSupabase(r)),
        );
      }

      if (universities.isNotEmpty) {
        selectedIndex.value = 0;
        await _loadVideosFor(0);
      }
    } catch (e, stacktrace) {
      log(
        'Üniversite radarı için üniversiteler yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      universitiesError.value = 'Üniversiteler yüklenemedi.';
    } finally {
      isLoadingUniversities.value = false;
    }
  }

  /// Wheel slider'da tekerlek döndükçe (yeni logo ortaya gelince) tetiklenir.
  void onWheelChanged(int index) {
    if (index < 0 || index >= universities.length) return;
    if (index == selectedIndex.value && videos.isNotEmpty) return;
    selectedIndex.value = index;
    _loadVideosFor(index);
  }

  Future<void> _loadVideosFor(int index) async {
    final uni = universities[index];
    final id = uni.id;
    if (id == null) return;

    try {
      isLoadingVideos.value = true;
      videosError.value = '';
      videos.value = await videoRepository.getVideosByUniversity(id);
    } catch (e, stacktrace) {
      log(
        'Üniversite radarı videoları yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      videosError.value = 'Haberler yüklenemedi.';
    } finally {
      isLoadingVideos.value = false;
    }
  }

  Future<void> retry() async {
    if (universities.isEmpty) {
      await _loadUniversities();
    } else {
      await _loadVideosFor(selectedIndex.value);
    }
  }
}
