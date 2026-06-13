// lib/presentation/controllers/university_detail_controller.dart

import 'dart:developer';
import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/university_model.dart';
import '../../data/models/video_model.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../data/repositories/video_repository.dart';

class UniversityDetailController extends GetxController {
  final VideoRepository videoRepository;
  final UniversityFavoritesRepository universityFavoritesRepository;

  UniversityDetailController({
    required this.videoRepository,
    required this.universityFavoritesRepository,
  });

  final university = Rxn<UniversityModel>();
  final videos = <VideoModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  // Favori durumu
  final isFavorite = false.obs;
  final isFavoriteLoading = false.obs;

  late final StreamSubscription<UniversityFavoriteChange> _favSub;

  // ─── Filtrelenmiş listeler ──────────────────────────────────────────────────

  /// Sadece normal videolar (isShorts == false)
  List<VideoModel> get videoOnly =>
      videos.where((v) => !v.isShorts).toList();

  /// Sadece shorts videolar (isShorts == true)
  List<VideoModel> get shortsOnly =>
      videos.where((v) => v.isShorts).toList();

  @override
  void onInit() {
    super.onInit();

    // Favori değişimlerini dinle (başka ekrandan tetiklenirse senkron kalır)
    _favSub = universityFavoritesRepository.onFavoriteChanged.listen((event) {
      if (event.universityId == university.value?.id) {
        isFavorite.value = event.isFavorite;
      }
    });

    final args = Get.arguments;
    if (args is UniversityModel) {
      university.value = args;
      _loadFavoriteStatus();
      loadVideos();
    } else if (args is int) {
      _loadUniversityById(args);
    } else {
      errorMessage.value = 'Üniversite bilgisi alınamadı.';
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _favSub.cancel();
    super.onClose();
  }

  // ─── Yükleme ──────────────────────────────────────────────────────────────

  Future<void> _loadUniversityById(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      university.value = await videoRepository.getUniversityById(id);
      await _loadFavoriteStatus();
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

  /// Mevcut kullanıcının bu üniversiteyi favori yapıp yapmadığını kontrol eder.
  Future<void> _loadFavoriteStatus() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final uniId = university.value?.id;
    if (userId == null || uniId == null) return;
    try {
      isFavorite.value = await universityFavoritesRepository
          .isUniversityFavorited(userId, uniId);
    } catch (e) {
      log('UniversityDetail _loadFavoriteStatus error: $e');
    }
  }

  // ─── Favori Toggle ─────────────────────────────────────────────────────────

  /// Favori durumunu tersine çevirir (ekle / kaldır).
  Future<void> toggleFavorite() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final uni = university.value;
    if (userId == null || uni?.id == null) {
      Get.snackbar(
        'Giriş Gerekli',
        'Favorilere eklemek için giriş yapmalısınız.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isFavoriteLoading.value) return; // çift tıklamayı engelle
    isFavoriteLoading.value = true;

    try {
      if (isFavorite.value) {
        await universityFavoritesRepository.removeFavorite(userId, uni!.id!);
        isFavorite.value = false;
        Get.snackbar(
          'Favorilerden Çıkarıldı',
          '${uni.name} favorilerden çıkarıldı.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        await universityFavoritesRepository.addFavorite(
          userId,
          uni!.id!,
          university: uni,
        );
        isFavorite.value = true;
        Get.snackbar(
          'Favorilere Eklendi',
          '${uni.name} favorilerinize eklendi.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      log('UniversityDetail toggleFavorite error: $e');
      Get.snackbar(
        'Hata',
        'İşlem gerçekleştirilemedi. Lütfen tekrar deneyin.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isFavoriteLoading.value = false;
    }
  }

  // ─── Yardımcı Formatlar ────────────────────────────────────────────────────

  String get formattedSubscriberCount {
    final count = university.value?.subscriberCount ?? 0;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
    return count.toString();
  }

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