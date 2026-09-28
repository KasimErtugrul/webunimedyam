import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../../presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(SupabaseDataSource.new, fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(LocalDataSource.new, fenix: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(
        () => AuthRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }
    // Profil başlığındaki özet istatistik şeridi (izlenen/beğenilen/favori/
    // yorum sayıları) için. Sadece kendi profilimizde kullanılıyor, ama
    // ucuz (cache'li, tek RPC) olduğu için burada her zaman kayıt ediyoruz.
    if (!Get.isRegistered<StatsRepository>()) {
      Get.lazyPut(
        () => StatsRepository(
          supabaseDataSource: Get.find(),
          localDataSource: Get.find(),
        ),
        fenix: true,
      );
    }

    // NOT: profile_screen.dart'taki _tag getter'ıyla aynı sebepten (bkz. o
    // dosyadaki açıklama) sert cast yerine güvenli tip kontrolü kullanıyoruz.
    final rawArgs = Get.arguments;
    final args = rawArgs is Map<String, dynamic> ? rawArgs : null;
    final targetUserId = args?['userId'] as String?;

    final supabase = Get.find<SupabaseDataSource>();
    final currentUserId = supabase.currentUser?.id ?? 'anonymous';
    final tag = targetUserId ?? currentUserId;

    Get.put(
      ProfileController(
        authRepository: Get.find(),
        statsRepository: Get.find(),
      ),
      tag: tag,
    );
  }
}