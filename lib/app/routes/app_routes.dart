// lib/app/routes/app_routes.dart

abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const player = '/player';
  static const profile = '/profile';
  static const settings = '/settings';
  static const login = '/login';
  static const register = '/register';
  static const search = '/search';
  static const stats = '/stats';
  static const videoSectionDetail = '/video-section-detail';
  static const universityDetail = '/university-detail';
  static const notifications = '/notifications';
  static const followers = '/followers';
  static const shortsPlayer = '/shorts-player';

  /// Basit Shorts oynatıcı (üniversite bilgisi olmadan)
  /// Argüman: {'shorts': List<VideoModel>, 'initialIndex': int}
  static const simpleShortsPlayer = '/simple-shorts-player';

  /// Videoyu kimlerin izlediği sayfası
  /// Argüman: {'videoId': String, 'totalViewCount': int}
  static const videoViewers = '/video-viewers';
}