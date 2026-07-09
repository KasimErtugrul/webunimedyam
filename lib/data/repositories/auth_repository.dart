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

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await _supabase.signUp(
        email: email,
        password: password,
        username: username,
      );
      await NotificationService.instance.onUserLogin();
      // auth_status user property'si AnalyticsService'in authStateChanges
      // dinleyicisi tarafından otomatik güncellenir; burada sadece
      // dönüşüm (conversion) event'ini logluyoruz.
      await AnalyticsService.instance.logSignUp(method: 'email');
    } catch (e, stacktrace) {
      log('Kayıt olurken hata oluştu: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
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