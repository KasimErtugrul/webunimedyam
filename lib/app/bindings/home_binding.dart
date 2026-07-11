import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/local/search_history_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/search_repository.dart';
import '../../data/repositories/shorts_repository.dart';
import '../../presentation/controllers/shorts_controller.dart';
import '../../presentation/controllers/video_search_controller.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/engagement_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/profile_activity_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/repositories/university_stats_repository.dart';
import '../../data/repositories/video_repository.dart';
import '../../presentation/controllers/favorites_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/profile_controller.dart';
import '../../presentation/controllers/university_sort_controller.dart'; // YENİ
import '../../data/repositories/university_favorites_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/watch_progress_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // ── Core Datasources ──────────────────────────────────────────────────
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource(), fenix: true);
    }

    // ── Repositories ──────────────────────────────────────────────────────
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(
        () => AuthRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<UniversityFavoritesRepository>()) {
      Get.lazyPut(
        () => UniversityFavoritesRepository(supabase: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<VideoRepository>()) {
      Get.lazyPut(
        () => VideoRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<FavoritesRepository>()) {
      Get.lazyPut(
        () => FavoritesRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<UniversityStatsRepository>()) {
      Get.lazyPut(
        () => UniversityStatsRepository(supabase: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProfileActivityRepository>()) {
      Get.lazyPut(
        () => ProfileActivityRepository(supabase: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<EngagementRepository>()) {
      Get.lazyPut(
        () => EngagementRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<CommentRepository>()) {
      Get.lazyPut(
        () => CommentRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    // YENİ: İzlemeye Devam Et — tamamen local çalışan repository
    if (!Get.isRegistered<WatchProgressRepository>()) {
      Get.lazyPut(
        () => WatchProgressRepository(local: Get.find()),
        fenix: true,
      );
    }

    // Profil başlığındaki özet istatistik şeridi için (bkz. profile_binding.dart'taki
    // aynı kayıt — burada da gerekli çünkü HomeBinding kendi ProfileController
    // örneklerini oluşturuyor).
    if (!Get.isRegistered<StatsRepository>()) {
      Get.lazyPut(
        () => StatsRepository(
          supabaseDataSource: Get.find(),
          localDataSource: Get.find(),
        ),
        fenix: true,
      );
    }

    // ── Controllers ────────────────────────────────────────────────────────

    Get.lazyPut(
      () => HomeController(
        videoRepository: Get.find(),
        favoritesRepository: Get.find(),
        universityStatsRepository: Get.find(),
        authRepository: Get.find(),
        engagementRepository: Get.find(),
        universityFavoritesRepository: Get.find(), // ← ekle
        commentRepository: Get.find(),
        watchProgressRepository: Get.find(), // ← YENİ
      ),
      fenix: true,
    );

    // ← YENİ: Üniversite Sıralama ve Filtreleme Controller'ı
    if (!Get.isRegistered<UniversitySortController>()) {
      Get.lazyPut(() => UniversitySortController(), fenix: true);
    }

    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut(
        () => ProfileController(
          authRepository: Get.find(),
          statsRepository: Get.find(),
        ),
        fenix: true,
      );
    }

    final supabase = Get.find<SupabaseDataSource>();
    final currentUserId = supabase.currentUser?.id ?? 'anonymous';

    if (!Get.isRegistered<ProfileController>(tag: currentUserId)) {
      Get.lazyPut(
        () => ProfileController(
          authRepository: Get.find(),
          statsRepository: Get.find(),
        ),
        tag: currentUserId,
        fenix: true,
      );
    }

    Get.lazyPut(
      () => FavoritesController(favoritesRepository: Get.find()),
      fenix: true,
    );

    // ── Search ─────────────────────────────────────────────────────────────
    if (!Get.isRegistered<SearchHistoryDataSource>()) {
      Get.lazyPut(() => SearchHistoryDataSource(), fenix: true);
    }
    if (!Get.isRegistered<SearchRepository>()) {
      Get.lazyPut(() => SearchRepository(supabase: Get.find()), fenix: true);
    }
    if (!Get.isRegistered<VideoSearchController>()) {
      Get.lazyPut(
        () => VideoSearchController(
          searchRepository: Get.find(),
          historyDataSource: Get.find(),
        ),
        fenix: true,
      );
    }

     if (!Get.isRegistered<ShortsRepository>()) {
      Get.lazyPut(
        () => ShortsRepository(supabase: Get.find<SupabaseDataSource>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<ShortsController>()) {
      Get.lazyPut(
        () => ShortsController(repository: Get.find<ShortsRepository>()),
        fenix: true,
      );
    }
  }
}