// lib/presentation/controllers/shorts_controller.dart
//
// FIX: Shorts listesi artık her uygulama açılışında Supabase'den taze çekilir.
// get_shorts_per_university RPC'si VOLATILE olarak güncellendi (Supabase tarafı)
// bu yüzden her çağrıda yayınlanma tarihine göre sıralı güncel veri gelir.

import 'dart:developer';

import 'package:get/get.dart';

import '../../data/models/shorts_model.dart';
import '../../data/repositories/shorts_repository.dart';

class ShortsController extends GetxController {
  final ShortsRepository _repository;

  ShortsController({required ShortsRepository repository})
      : _repository = repository;

  // ─── State ────────────────────────────────────────────────────────────────
  final shorts = <ShortsModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Oynatıcıda hangi index'teyiz
  final currentIndex = 0.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // loadShorts() burada çağrılmıyor.
    // HomeTabWidget.initState() içindeki addPostFrameCallback tetikliyor.
  }

  // ─── Veri ────────────────────────────────────────────────────────────────

  /// Shorts listesini Supabase'den çeker.
  /// FIX: Artık her çağrıda taze veri — yayınlanma tarihine göre sıralı gelir.
  Future<void> loadShorts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repository.getShortsPerUniversity();
      shorts.value = result;
      log('[ShortsController] ${result.length} shorts yüklendi');
    } catch (e) {
      log('[ShortsController] loadShorts error: $e');
      errorMessage.value = 'Shorts yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh desteği.
  Future<void> refresh() => loadShorts();

  void setCurrentIndex(int index) => currentIndex.value = index;
}