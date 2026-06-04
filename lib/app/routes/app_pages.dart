import 'package:get/get.dart';
import '../../presentation/screens/follow/followers_screen.dart';
import '../../presentation/screens/notification/notification_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/player/player_screen.dart';
import '../../presentation/screens/player/playlist_detail_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/stats/stats_screen.dart';
import '../../presentation/screens/video_section_detail/video_section_detail_screen.dart';
import '../../presentation/screens/university_detail/university_detail_screen.dart'; // ← YENİ
import '../bindings/follow_binding.dart';
import '../bindings/onboarding_bindings.dart';
import '../bindings/playlist_detail_binding.dart';
import '../bindings/splash_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/player_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/search_binding.dart';
import '../bindings/stats_binding.dart';
import '../bindings/video_section_detail_binding.dart';
import '../bindings/university_detail_binding.dart'; // ← YENİ
import 'app_routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.player,
      page: () => const PlayerScreen(),
      binding: PlayerBinding(),
    ),
    GetPage(
      name: AppRoutes.playlistDetail,
      page: () => const PlaylistDetailScreen(),
      binding: PlaylistDetailBinding(), // ← DOĞRU
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      preventDuplicates: false, // Farklı kullanıcı profillerinin stack'te açılmasına izin ver
    ),
   
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: AppRoutes.stats,
      page: () => const StatsScreen(),
      binding: StatsBinding(),
    ),
    GetPage(
      name: AppRoutes.videoSectionDetail,
      page: () => const VideoSectionDetailScreen(),
      binding: VideoSectionDetailBinding(),
    ),
    GetPage(
      // ← YENİ
      name: AppRoutes.universityDetail,
      page: () => const UniversityDetailScreen(),
      binding: UniversityDetailBinding(),
    ),

     GetPage(
      name: AppRoutes.followers,
      page: () => const FollowersScreen(),
      binding: FollowBinding(),
    ),
     GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      //binding: NotificationsBinding(),
    ),
  ];
}
