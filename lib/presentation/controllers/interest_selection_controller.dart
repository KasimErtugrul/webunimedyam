// lib/presentation/controllers/interest_selection_controller.dart
//
// Yeni kayıt (signup + OTP doğrulama) sonrası kullanıcıya ilgilendiği
// üniversiteleri seçme fırsatı sunan ekranın controller'ı.
//
// Notlar:
//  - Seçim ZORUNLU DEĞİL. Kullanıcı hiç seçim yapmadan da "Atla" diyerek
//    devam edebilir.
//  - Seçim sınırsızdır (istediği kadar üniversite seçebilir).
//  - Seçilen üniversiteler, uygulamada zaten var olan "favori üniversite"
//    mekanizması (UniversityFavoritesRepository) üzerinden kaydedilir.
//    Böylece bu ekranda seçilen üniversiteler otomatik olarak kullanıcının
//    favorileri/takip ettiği üniversiteler listesinde de görünür ve
//    ana sayfadaki kişiselleştirme (favoriler, bildirimler vb.) ile
//    ekstra bir entegrasyon gerekmeden uyumlu çalışır.
//  - Ekran yalnızca YENİ KAYIT akışında bir kez gösterilir. Kullanıcı
//    "Atla" ya da seçim yapıp "Devam Et" dediğinde bir daha bu ekranı
//    görmesin diye LocalDataSource'a kalıcı bir flag yazılır.

import 'dart:developer';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/models/university_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/university_favorites_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../services/analytics_service.dart';

class InterestSelectionController extends GetxController {
  final VideoRepository videoRepository;
  final AuthRepository authRepository;
  final UniversityFavoritesRepository universityFavoritesRepository;
  final LocalDataSource local;

  InterestSelectionController({
    required this.videoRepository,
    required this.authRepository,
    required this.universityFavoritesRepository,
    required this.local,
  });

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  final universities = <UniversityModel>[].obs;
  final selectedIds = <int>{}.obs;

  List<UniversityModel> get filteredUniversities {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return universities;
    return universities
        .where((u) => (u.name ?? '').toLowerCase().contains(query))
        .toList();
  }

  int get selectedCount => selectedIds.length;

  @override
  void onInit() {
    super.onInit();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final list = await videoRepository.getUniversities();
      list.sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
              (b.name ?? '').toLowerCase(),
            ),
      );
      universities.value = list;
    } catch (e, stacktrace) {
      log(
        'İlgi alanı üniversiteleri yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value =
          'Üniversiteler yüklenemedi. Lütfen tekrar deneyin.';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleUniversity(int universityId) {
    if (selectedIds.contains(universityId)) {
      selectedIds.remove(universityId);
    } else {
      selectedIds.add(universityId);
    }
  }

  bool isSelected(int universityId) => selectedIds.contains(universityId);

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// Seçilen üniversiteleri kaydeder ve Home'a yönlendirir.
  /// Seçim yoksa direkt "atla" davranışıyla aynıdır.
  Future<void> confirmAndContinue() async {
    try {
      isSaving.value = true;

      final userId = authRepository.currentUserId;
      if (userId != null && selectedIds.isNotEmpty) {
        for (final id in selectedIds) {
          final uni = universities.firstWhereOrNull((u) => u.id == id);
          await universityFavoritesRepository.addFavorite(
            userId,
            id,
            university: uni,
          );
        }

        AnalyticsService.instance.logEvent(
          'interest_universities_selected',
          parameters: {'count': selectedIds.length},
        );
      }

      await local.setInterestSelectionShown();
      Get.offAllNamed(AppRoutes.home);
    } catch (e, stacktrace) {
      log(
        'İlgi alanı üniversiteleri kaydedilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      // Kayıt sırasında hata olsa bile kullanıcıyı akışta bekletmiyoruz;
      // favoriler HomeController üzerinden istediği zaman tekrar eklenebilir.
      await local.setInterestSelectionShown();
      Get.offAllNamed(AppRoutes.home);
    } finally {
      isSaving.value = false;
    }
  }

  /// Kullanıcı hiç seçim yapmadan geçmek isterse.
  Future<void> skip() async {
    AnalyticsService.instance.logEvent('interest_selection_skipped');
    await local.setInterestSelectionShown();
    Get.offAllNamed(AppRoutes.home);
  }
}