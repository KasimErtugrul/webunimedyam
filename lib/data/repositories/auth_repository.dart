// lib/data/repositories/auth_repository.dart

import 'dart:developer';
import 'dart:typed_data';
import '../../services/analytics_service.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../datasources/local/local_datasource.dart';
import '../models/profile_model.dart';
import '../models/user_settings_model.dart';
import '../../services/notification_service.dart';

class AuthRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;

  AuthRepository({
    required SupabaseDataSource supabase,
    required LocalDataSource local,
  }) : _supabase = supabase,
       _local = local;

  bool get isLoggedIn => _supabase.currentUser != null;
  String? get currentUserId => _supabase.currentUser?.id;
  Stream get authStateChanges => _supabase.authStateChanges;

  // ─── YAZMA İŞLEMLERİ (Write) ─────────────────────────────────────────────

  // ─── Uygulama Açılışı / Ön plana Geçiş ──────────────────────────────────
  // FIX: Bildirim token'ı yalnızca login/signup'ta kaydediliyordu.
  // Bu yüzden uygulama yüklü olup token henüz DB'de yokken (ilk kurulum,
  // uygulama güncelleme, OS token yenilemesi) bildirim hiç ulaşamıyordu.
  // Artık uygulama her ön plana geldiğinde token güncellenir — böylece
  // Sercan gibi "favori ekle ama henüz aç" senaryoları da kapsanır.
  Future<void> onAppResume() async {
    if (!isLoggedIn) return;
    try {
      await NotificationService.instance.onUserLogin();
    } catch (e, stacktrace) {
      log(
        'Uygulama açılışında token yenilenirken hata: $e',
        error: e,
        stackTrace: stacktrace,
      );
      // Token yenileme kritik değil; uygulama akışını bozmadan devam et.
    }
  }

  /// Kayıt işlemini başlatır.
  ///
  /// Dönüş değeri `true` ise: email onayı bekleniyor demektir (Supabase'de
  /// "Confirm email" açık ve henüz session kurulmadı) — çağıran taraf
  /// kullanıcıyı OTP giriş ekranına yönlendirmeli.
  /// `false` ise: session doğrudan kuruldu (email onayı kapalıysa) — bu
  /// durumda giriş/kayıt sonrası işlemler burada tamamlanır.
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _supabase.signUp(
        email: email,
        password: password,
        username: username,
      );

      final needsVerification = response.session == null;
      if (!needsVerification) {
        await _onAuthSuccess();
      }
      return needsVerification;
    } catch (e, stacktrace) {
      log('Kayıt olurken hata oluştu: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  /// Kayıt sırasında email'e gönderilen 6 haneli kodu doğrular.
  /// Başarılı olursa session kurulur; bildirim token'ı kaydedilir ve
  /// signup dönüşüm event'i loglanır (signUp() sırasında session henüz
  /// olmadığı için bu adımlar buraya ertelenmişti).
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _supabase.verifyEmailOTP(email: email, token: token);
      await _onAuthSuccess();
      await AnalyticsService.instance.logSignUp(method: 'email');
    } catch (e, stacktrace) {
      log(
        'Email OTP doğrulanırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  /// Onay kodunu (OTP) tekrar gönderir.
  Future<void> resendVerificationOtp({required String email}) async {
    try {
      await _supabase.resendSignUpOTP(email: email);
    } catch (e, stacktrace) {
      log(
        'OTP tekrar gönderilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  /// Session başarıyla kurulduğunda (signIn veya OTP doğrulama sonrası)
  /// ortak yapılması gereken işlemler.
  Future<void> _onAuthSuccess() async {
    await NotificationService.instance.onUserLogin();
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _supabase.signIn(email: email, password: password);
      await NotificationService.instance.onUserLogin();
      await AnalyticsService.instance.logLogin(method: 'email');
    } catch (e, stacktrace) {
      log('Giriş yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  String? get currentUserEmail => _supabase.currentUser?.email;

  // ─── Google ile Giriş ───────────────────────────────────────────────────
  /// Google ile giriş/kayıt yapar. Yeni kullanıcıysa Supabase tarafında
  /// otomatik hesap açılır (email confirm adımı gerekmez, Google zaten
  /// email'i doğrulamış sayılır).
  ///
  /// Dönüş: true → yeni kayıt (ilk kez bu Google hesabıyla giriş yaptı),
  /// false → var olan hesapla giriş.
  Future<bool> signInWithGoogle() async {
    try {
      final isNewUser = await _supabase.signInWithGoogle();
      await NotificationService.instance.onUserLogin();
      AnalyticsService.instance.logEvent(
        isNewUser ? 'sign_up' : 'login',
        parameters: {'method': 'google'},
      );
      return isNewUser;
    } catch (e, stacktrace) {
      log('Google ile giriş yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  // ─── Şifre Değiştirme (oturum açıkken) ─────────────────────────────────
  /// Mevcut şifreyi doğrulayıp yenisiyle değiştirir. Kullanıcının halihazırda
  /// oturumu açık olmalı (currentUserEmail dolu olmalı).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = currentUserEmail;
    if (email == null) {
      throw Exception('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    try {
      // Mevcut şifreyi teyit et — yanlışsa exception fırlatır ve
      // updatePassword'e hiç gidilmez.
      await _supabase.reauthenticateWithPassword(
        email: email,
        currentPassword: currentPassword,
      );
      await _supabase.updatePassword(newPassword: newPassword);
    } catch (e, stacktrace) {
      log('Şifre değiştirilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  // ─── Şifremi Unuttum (oturum yokken) ────────────────────────────────────
  /// Şifre sıfırlama kodunu email'e gönderir.
  Future<void> sendPasswordResetOtp({required String email}) async {
    try {
      await _supabase.sendPasswordResetOtp(email: email);
    } catch (e, stacktrace) {
      log('Şifre sıfırlama kodu gönderilirken hata oluştu: $e',
          error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  /// Kodu doğrular (geçici recovery session kurar) ve ardından yeni
  /// şifreyi ayarlar. Tek adımda birleştirilmiş, çünkü recovery session'ın
  /// tek başına bir anlamı yok — hemen yeni şifre belirlenmeli.
  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _supabase.verifyPasswordResetOtp(email: email, token: otp);
      await _supabase.updatePassword(newPassword: newPassword);
    } catch (e, stacktrace) {
      log('Şifre sıfırlanırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  /// Şifre sıfırlama kodunu tekrar gönderir.
  Future<void> resendPasswordResetOtp({required String email}) async {
    try {
      await _supabase.resendPasswordResetOtp(email: email);
    } catch (e, stacktrace) {
      log('Şifre sıfırlama kodu tekrar gönderilirken hata oluştu: $e',
          error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await NotificationService.instance.onUserLogout();
      await Future.wait([
        _local.clearUserSettings(),
        _local.clearFavoriteVideos(),
        _local.clearCache(),
        _local.clearUserStats(),
        _local.clearVideoSectionCache(),
        _local.clearProfile(),
        _local.clearUniversities(),
        // FIX: yeni eklenen hafif id-set cache'leri de temizlenmeli,
        // yoksa aynı cihazda çıkış yapıp başka hesapla giren kullanıcı
        // bir önceki kullanıcının beğeni/favori id'lerini görebilir.
        _local.clearLikedVideoIds(),
        _local.clearFavoriteVideoIds(),
      ]);
      await _supabase.signOut();
      await AnalyticsService.instance.logLogout();
    } catch (e, stacktrace) {
      log('Çıkış yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _supabase.updateProfile(profile);
      await _local.cacheProfile(profile.toSupabase());
    } catch (e, stacktrace) {
      log(
        'Profil güncellenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  /// Profil fotoğrafını yükler, avatar_url'i profiles tablosunda günceller
  /// ve yerel önbelleği tazeler. Yüklenen public URL döner.
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('Oturum bulunamadı. Lütfen tekrar giriş yapın.');
    }
    try {
      final avatarUrl = await _supabase.uploadAvatar(
        userId: userId,
        bytes: bytes,
        fileExtension: fileExtension,
      );

      // Mevcut profili çekip sadece avatarUrl'i değiştiriyoruz; aksi halde
      // toSupabase() diğer alanları (username, full_name) null'a düşürür.
      final currentProfile = await _supabase.getProfile(userId);
      if (currentProfile == null) {
        throw Exception('Profil bulunamadı.');
      }
      final updatedProfile = currentProfile.copyWith(avatarUrl: avatarUrl);
      await _supabase.updateProfile(updatedProfile);

      final cached = await _local.getCachedProfile();
      if (cached != null) {
        cached['avatar_url'] = avatarUrl;
        await _local.cacheProfile(cached);
      }

      return avatarUrl;
    } catch (e, stacktrace) {
      log(
        'Profil fotoğrafı yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

 

  Future<void> updateUserSettings(UserSettingsModel settings) async {
    try {
      await _supabase.updateUserSettings(settings);
      await _local.cacheUserSettings(settings.toSupabase());
      await _local.setTheme(settings.theme);
      await _local.setHomeLayout(settings.homeLayout);
    } catch (e, stacktrace) {
      log(
        'Kullanıcı ayarları güncellenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> clearLocalCache() async {
    try {
      await Future.wait([
        _local.clearCache(),
        _local.clearUserStats(),
        _local.clearVideoSectionCache(),
        // FIX: manuel "önbelleği temizle" ayarı yeni id-set cache'lerini
        // atlıyordu; kullanıcı "temizle" dediğinde gerçekten hepsi silinsin.
        _local.clearLikedVideoIds(),
        _local.clearFavoriteVideoIds(),
      ]);
    } catch (e, stacktrace) {
      log(
        'Yerel önbellek temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      await _local.setOnboardingCompleted();
      final userId = currentUserId;
      if (userId != null) {
        await _supabase.completeOnboarding(userId);
      }
    } catch (e, stacktrace) {
      log(
        'Onboarding tamamlanırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  // ─── OKUMA İŞLEMLERİ (Read) ──────────────────────────────────────────────

  Future<ProfileModel?> getProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return null;
      }

      final cachedMap = await _local.getCachedProfile();
      if (cachedMap != null) {
        return ProfileModel.fromSupabase(cachedMap);
      }

      final profile = await _supabase.getProfile(userId);
      if (profile != null) {
        await _local.cacheProfile(profile.toSupabase());
      }
      return profile;
    } catch (e, stacktrace) {
      log(
        'Profil bilgileri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  Future<ProfileModel?> getProfileById(String userId) async {
    try {
      final data = await _supabase.getPublicProfile(userId);
      if (data == null) return null;
      return ProfileModel.fromSupabase(data);
    } catch (e, stacktrace) {
      log(
        'Kullanıcı profili getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  Future<UserSettingsModel?> getUserSettings() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final cached = await _local.getCachedUserSettings();
      if (cached != null) {
        return UserSettingsModel.fromSupabase(cached);
      }

      final settings = await _supabase.getUserSettings(userId);
      if (settings != null) {
        await _local.cacheUserSettings(settings.toSupabase());
      }
      return settings;
    } catch (e, stacktrace) {
      log(
        'Kullanıcı ayarları getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  Future<void> saveThemeLocally(String theme) async {
    try {
      await _local.setTheme(theme);
    } catch (e, stacktrace) {
      log(
        'Tema kaydedilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  /// Ana sayfa görünüm tercihini (liste/wheel) SADECE yerelde saklar.
  /// Tema kaydıyla aynı mantık: giriş yapılmasa bile anında çalışır.
  Future<void> saveHomeLayoutLocally(String layout) async {
    try {
      await _local.setHomeLayout(layout);
    } catch (e, stacktrace) {
      log(
        'Ana sayfa görünümü kaydedilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  /// Ana sayfa görünüm tercihini getirir.
  ///
  /// SIRALAMA (mutlaka bu sırayla):
  /// 1) Bağımsız yerel anahtar (`home_layout`) — en hızlı, girişsiz de çalışır.
  /// 2) Yerelde yoksa: tam kullanıcı ayarları (kendisi de önce cache'e,
  ///    sonra Supabase'e bakar — bkz. getUserSettings()).
  /// 3) O da yoksa: varsayılan 'list'.
  ///
  /// Supabase'den/ayarlardan bulunan değer, bir sonraki açılışta adım 1'in
  /// hemen cevap verebilmesi için yerel anahtara da yazılır.
  Future<String> getHomeLayout() async {
    try {
      final local = await _local.getHomeLayoutRaw();
      if (local != null) return local;

      final settings = await getUserSettings();
      final layout = settings?.homeLayout ?? 'list';
      await _local.setHomeLayout(layout);
      return layout;
    } catch (e, stacktrace) {
      log(
        'Ana sayfa görünümü getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return 'list';
    }
  }

  Future<bool> isOnboardingCompleted() async {
    try {
      if (await _local.isOnboardingCompleted()) {
        return true;
      }

      final userId = currentUserId;
      if (userId == null) return false;

      return await _supabase.isOnboardingCompleted(userId);
    } catch (e, stacktrace) {
      log(
        'Onboarding durumu kontrol edilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return false;
    }
  }
}