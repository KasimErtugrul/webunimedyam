// lib/presentation/controllers/shorts_controller.dart

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

  // Oynatıcıda hangi index'teyiz
  final currentIndex = 0.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onReady() {
    super.onReady();
    loadShorts();
  }

  // ─── Veri ────────────────────────────────────────────────────────────────

  Future<void> loadShorts() async {
    try {
      isLoading.value = true;
      shorts.value = await _repository.getShortsPerUniversity();
    } catch (e) {
      log('[ShortsController] loadShorts error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadShorts();

  void setCurrentIndex(int index) => currentIndex.value = index;
}