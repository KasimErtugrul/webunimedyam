// lib/presentation/controllers/followed_universities_list_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../data/models/university_model.dart';

class FollowedUniversitiesListController extends GetxController {
  final UniversityFavoritesRepository universityFavoritesRepository;

  FollowedUniversitiesListController({
    required this.universityFavoritesRepository,
  });

  final universities = <UniversityModel>[].obs;
  final isLoading = false.obs;

  late final String userId;
  late final bool isOwnProfile;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    userId = args['userId'] as String;
    isOwnProfile = args['isOwnProfile'] as bool? ?? true;
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      universities.value = await universityFavoritesRepository.getFavoriteUniversities(userId);
    } catch (e, stacktrace) {
      log('Takip edilen üniversiteler yüklenirken hata: $e', error: e, stackTrace: stacktrace);
    } finally {
      isLoading.value = false;
    }
  }
}
