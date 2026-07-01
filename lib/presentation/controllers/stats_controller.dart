import 'dart:developer';
import 'package:get/get.dart';
import '../../data/models/user_stats_model.dart';
import '../../data/repositories/stats_repository.dart';
import '../../services/analytics_service.dart';

class StatsController extends GetxController {
  final StatsRepository statsRepository;

  StatsController({required this.statsRepository});

  // ─── Reaktif state ────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final stats = Rxn<UserStatsModel>();
  final errorMessage = Rxn<String>();

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onReady() {
    super.onReady();
    // Bu ekranın (kişisel istatistikler) ne sıklıkla ziyaret edildiğini
    // ölçmek için — sadece ilk girişte, refresh()'te tekrar sayılmıyor.
    AnalyticsService.instance.logEvent('stats_view');
    _load();
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Pull-to-refresh veya AppBar'daki yenile butonundan çağrılır.
  Future<void> refresh() => _load(forceRefresh: true);

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<void> _load({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await statsRepository.getUserStats(
        forceRefresh: forceRefresh,
      );
      stats.value = result;
      if (result == null) {
        errorMessage.value = 'İstatistik verisi bulunamadı.';
      }
    } catch (e, stacktrace) {
      log(
        'İstatistikler yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'İstatistikler yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }
}