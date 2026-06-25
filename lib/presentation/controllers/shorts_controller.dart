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

  // ─── Sayfalama Ayarları ───────────────────────────────────────────────────
  static const int pageSize = 10;

  // ─── State ────────────────────────────────────────────────────────────────
  final shorts = <ShortsModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;

  int _offset = 0;

  // Oynatıcıda hangi index'teyiz
  final currentIndex = 0.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() async {
    super.onInit();
    // loadShorts() burada çağrılmıyor.
    // HomeTabWidget.initState() içindeki addPostFrameCallback tetikliyor.
    await loadShorts();
  }

  // ─── Veri ────────────────────────────────────────────────────────────────

  /// Shorts listesinin ilk sayfasını ([pageSize] adet) Supabase'den çeker.
  /// Mevcut listeyi sıfırlar.
  Future<void> loadShorts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _offset = 0;
      hasMore.value = true;

      final result = await _repository.getShortsPerUniversity(
        limit: pageSize,
        offset: _offset,
      );
      shorts.value = result;
      _offset = result.length;
      hasMore.value = result.length == pageSize;
    } catch (e, stacktrace) {
      log(
        'Shorts yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Shorts yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Yatay listede sona yaklaşıldığında bir sonraki [pageSize] adet shorts'u
  /// mevcut listenin sonuna ekler.
  Future<void> loadMoreShorts() async {
    if (isLoadingMore.value || isLoading.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      final result = await _repository.getShortsPerUniversity(
        limit: pageSize,
        offset: _offset,
      );

      if (result.isEmpty) {
        hasMore.value = false;
        return;
      }

      shorts.addAll(result);
      _offset += result.length;
      hasMore.value = result.length == pageSize;
    } catch (e, stacktrace) {
      log(
        'Daha fazla shorts yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Pull-to-refresh desteği.
  Future<void> refresh() => loadShorts();

  void setCurrentIndex(int index) => currentIndex.value = index;
}
