// lib/app/routes/app_routes.dart
// MEVCUT DOSYANIN ÜSTÜNE YAZAR

abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const player = '/player';
  static const playlistDetail = '/playlist-detail';
  static const profile = '/profile';
  static const settings = '/settings';
  static const login = '/login';
  static const register = '/register';
  static const search = '/search';
  static const stats = '/stats';
  static const videoSectionDetail = '/video-section-detail';
  static const universityDetail = '/university-detail';
  static const notifications = '/notifications';

  // ── YENİ ──────────────────────────────────────────────────
  /// Takipçiler / takip edilenler sayfası
  /// Argüman: {'userId': String, 'initialTab': 0|1}
  static const followers = '/followers';
}
