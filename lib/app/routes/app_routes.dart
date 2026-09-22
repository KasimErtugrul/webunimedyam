// lib/app/routes/app_routes.dart

abstract class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const player = '/player';
  static const profile = '/profile';
  static const settings = '/settings';
  static const login = '/login';
  static const register = '/register';

  /// Yeni kayıt (signup) sonrası, OTP doğrulandıktan hemen sonra bir kez
  /// gösterilen "ilgilendiğin üniversiteleri seç" ekranı.
  static const interestSelection = '/interest-selection';

  /// Yeni kayıt sonrası (email OTP veya Google ile ilk giriş), İlgi Alanı
  /// Seçimi ekranından ÖNCE bir kez gösterilen temel tercih ekranı:
  /// tema, otomatik oynatma, bildirimler ve aktivite/profil görünürlüğü.
  static const signupPreferences = '/signup-preferences';

  /// Kayıt sonrası email onay kodu (OTP) giriş ekranı.
  /// Argüman: {'email': String}
  static const otpVerification = '/otp-verification';

  /// Şifremi unuttum — email girişi.
  static const forgotPassword = '/forgot-password';

  /// Şifre sıfırlama — kod + yeni şifre girişi.
  /// Argüman: {'email': String}
  static const resetPassword = '/reset-password';

  /// Oturum açıkken şifre değiştirme.
  static const changePassword = '/change-password';
  static const search = '/search';
  static const stats = '/stats';
  static const videoSectionDetail = '/video-section-detail';

  /// Kanal (üniversite) tab'ındaki 8 bölümün "Tümünü Gör" detay sayfası.
  /// Argüman: {'type': UniversityStatsSectionType, 'title': String}
  static const universityStatsSectionDetail =
      '/university-stats-section-detail';
  static const universityDetail = '/university-detail';
  static const notifications = '/notifications';
  static const shortsPlayer = '/shorts-player';
  static const radio = '/radio';

  /// Solda dev "wheel slider" ile üniversite logoları, sağda seçili
  /// üniversitenin haberlerinin (videolarının) gösterildiği ekran.
  static const universityWheel = '/university-wheel';

  /// Basit Shorts oynatıcı (üniversite bilgisi olmadan)
  // ignore: unintended_html_in_doc_comment
  /// Argüman: {'shorts': List<VideoModel>, 'initialIndex': int}
  static const simpleShortsPlayer = '/simple-shorts-player';

  /// Videoyu kimlerin izlediği sayfası
  /// Argüman: {'videoId': String, 'totalViewCount': int}
  static const videoViewers = '/video-viewers';

  /// Profil aktivite listesi (favoriler, izlenenler, yorumlar, paylaşılanlar)
  /// Argüman: {'type': ProfileActivityType, 'userId': String, 'isOwnProfile': bool}
  static const profileActivityList = '/profile-activity-list';

  /// Takip edilen üniversiteler listesi
  /// Argüman: {'userId': String, 'isOwnProfile': bool}
  static const followedUniversitiesList = '/followed-universities-list';

  /// Profili düzenleme ekranı (yalnızca kendi profilin için).
  /// Argüman gerekmez — ekran mevcut kullanıcının zaten kayıtlı olan
  /// ProfileController örneğini (aynı tag ile) bulur.
  static const editProfile = '/edit-profile';
}
