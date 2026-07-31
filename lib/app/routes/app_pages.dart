// lib/app/routes/app_pages.dart

import 'package:get/get.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/player/player_screen.dart';
import '../../presentation/screens/player/video_viewers_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile_activity_list/profile_activity_list_screen.dart';
import '../../presentation/screens/followed_universities_list/followed_universities_list_screen.dart';
import '../../presentation/screens/radio/radio_page.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/interest_selection/interest_selection_screen.dart';
import '../../presentation/screens/signup_preferences/signup_preferences_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';
import '../../presentation/screens/auth/change_password_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/stats/stats_screen.dart';
import '../../presentation/screens/video_section_detail/video_section_detail_screen.dart';
import '../../presentation/screens/university_stats_section_detail/university_stats_section_detail_screen.dart';
import '../../presentation/screens/university_detail/university_detail_screen.dart';
import '../../presentation/screens/shorts/shorts_player_screen.dart';
import '../../presentation/screens/shorts/simple_shorts_player_screen.dart';
import '../bindings/onboarding_bindings.dart';
import '../bindings/home_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/interest_selection_binding.dart';
import '../bindings/signup_preferences_binding.dart';
import '../bindings/player_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/profile_activity_list_binding.dart';
import '../bindings/followed_universities_list_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/search_binding.dart';
import '../bindings/stats_binding.dart';
import '../bindings/video_section_detail_binding.dart';
import '../bindings/university_stats_section_detail_binding.dart';
import '../bindings/university_detail_binding.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = [
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
      parameters: {
        'videoId': Get.parameters['videoId'] ?? '',
      },
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      preventDuplicates: false,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.profileActivityList,
      page: () => const ProfileActivityListScreen(),
      binding: ProfileActivityListBinding(),
    ),
    GetPage(
      name: AppRoutes.followedUniversitiesList,
      page: () => const FollowedUniversitiesListScreen(),
      binding: FollowedUniversitiesListBinding(),
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
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signupPreferences,
      page: () => const SignupPreferencesScreen(),
      binding: SignupPreferencesBinding(),
    ),
    GetPage(
      name: AppRoutes.interestSelection,
      page: () => const InterestSelectionScreen(),
      binding: InterestSelectionBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
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
      name: AppRoutes.universityStatsSectionDetail,
      page: () => const UniversityStatsSectionDetailScreen(),
      binding: UniversityStatsSectionDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.universityDetail,
      page: () => const UniversityDetailScreen(),
      binding: UniversityDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.videoViewers,
      page: () => const VideoViewersScreen(),
    ),
    GetPage(
      name: AppRoutes.shortsPlayer,
      page: () => const ShortsPlayerScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.simpleShortsPlayer,
      page: () => const SimpleShortsPlayerScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(name: AppRoutes.radio, page: () => const RadioPage()),
   
   
  ];
}