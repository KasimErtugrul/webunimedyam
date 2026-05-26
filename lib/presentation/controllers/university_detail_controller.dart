// lib/presentation/controllers/university_detail_controller.dart

import 'dart:developer';

import 'package:get/get.dart';

import '../../data/models/university_model.dart';
import '../../data/models/video_model.dart';
import '../../data/repositories/video_repository.dart';

class UniversityDetailController extends GetxController {
  final VideoRepository videoRepository;

  UniversityDetailController({required this.videoRepository});

  // Rxn kullanarak ekran null-safe şekilde bekleyebilir
  final university = Rxn<UniversityModel>();

  final videos = <VideoModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is UniversityModel) {
      // Üniversiteler tab'ından geldi: tam model direkt set
      university.value = args;
      loadVideos();
    } else if (args is int) {
      // Keşfet Kanal tab'ından geldi: Supabase'den tam veriyi çek
      _loadUniversityById(args);
    } else {
      errorMessage.value = 'Üniversite bilgisi alınamadı.';
      isLoading.value = false;
    }
  }

  Future<void> _loadUniversityById(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      university.value = await videoRepository.getUniversityById(id);
      await loadVideos();
    } catch (e) {
      log('UniversityDetail _loadUniversityById error: $e');
      errorMessage.value = 'Üniversite bilgileri yüklenemedi.';
      isLoading.value = false;
    }
  }

  Future<void> loadVideos() async {
    final id = university.value?.id;
    if (id == null) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      videos.value = await videoRepository.getVideosByUniversity(id);
    } catch (e) {
      log('UniversityDetail loadVideos error: $e');
      errorMessage.value = 'Videolar yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Abone sayısını kısa formatta döner: 1.2M, 450K, 12B vb.
  String get formattedSubscriberCount {
    final count = university.value?.subscriberCount ?? 0;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
    return count.toString();
  }

  /// Toplam izlenme sayısını kısa formatta döner.
  String get formattedViewCount {
    final count = university.value?.viewCount ?? 0;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
    return count.toString();
  }
}
