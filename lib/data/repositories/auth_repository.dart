// lib/data/repositories/auth_repository.dart

import 'dart:developer';
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

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    log('🔐☁️ [Auth] Kayıt isteği Supabase\'e gönderiliyor → $email');
    await _supabase.signUp(
      email: email,
      password: password,
      username: username,
    );
    // Kayıt sonrası FCM token'ını kaydet
    await NotificationService.instance.onUserLogin();
  }

  Future<void> signIn({required String email, required String password}) async {
    log('🔑☁️ [Auth] Giriş isteği Supabase\'e gönderiliyor → $email');
    await _supabase.signIn(email: email, password: password);
    // Giriş sonrası FCM token'ını kaydet
    await NotificationService.instance.onUserLogin();
  }

  Future<void> signOut() async {
    log('🚪🧹 [Auth] Çıkış yapılıyor, tüm local veriler temizleniyor...');

    // Çıkış öncesi FCM token'ını sil (DB'den)
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
    log('✅ [Auth] Çıkış tamamlandı, tüm cache temizlendi');
  }

  Future<void> updateProfile(ProfileModel profile) async {
    log('✏️☁️ [Auth] Profil güncelleniyor → ${profile.username}');
    await _supabase.updateProfile(profile);
    log('✅ [Auth] Profil güncellendi');
  }

  Future<void> updateUserSettings(UserSettingsModel settings) async {
    await _supabase.updateUserSettings(settings);
    await _local.cacheUserSettings(settings.toSupabase());
    await _local.setTheme(settings.theme);
  }

  Future<void> clearLocalCache() async {
    log('🧹 [Auth] Sadece local cache temizleniyor (çıkış yok)...');
    await Future.wait([
      _local.clearCache(),
      _local.clearUserStats(),
      _local.clearVideoSectionCache(),
    ]);
    log('✅ [Auth] Local cache temizlendi');
  }

  Future<void> completeOnboarding() async {
    log('🎓✅ [Auth] Onboarding tamamlandı → local + Supabase yazılıyor');
    await _local.setOnboardingCompleted();
    final userId = currentUserId;
    if (userId != null) {
      await _supabase.completeOnboarding(userId);
    }
  }

  // ─── OKUMA İŞLEMLERİ (Read) ──────────────────────────────────────────────

  Future<ProfileModel?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) {
      log('⚠️ [Auth] getProfile: kullanıcı giriş yapmamış');
      return null;
    }

    // Önce local cache'e bak
    final cachedMap = await _local.getCachedProfile();
    if (cachedMap != null) {
      log('👤💾 [Auth] Profil LOCAL\'den geldi');
      return ProfileModel.fromSupabase(cachedMap);
    }

    try {
      log('👤☁️ [Auth] Profil Supabase\'den çekiliyor → $userId');
      final profile = await _supabase.getProfile(userId);
      if (profile != null) {
        await _local.cacheProfile(profile.toSupabase());
        log('👤💾 [Auth] Profil local cache\'e yazıldı');
      }
      return profile;
    } catch (e) {
      log('👤❌ [Auth] Profil çekilemedi (offline?): $e');
      return null;
    }
  }

  /// Başkasının profilini ID ile çek (public profil bilgisi).
  Future<ProfileModel?> getProfileById(String userId) async {
    try {
      log('👤☁️ [Auth] Profil çekiliyor (by ID) → $userId');
      final data = await _supabase.getPublicProfile(userId);
      if (data == null) return null;
      return ProfileModel.fromSupabase(data);
    } catch (e) {
      log('👤❌ [Auth] getProfileById error: $e');
      return null;
    }
  }

  Future<UserSettingsModel?> getUserSettings() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final cached = await _local.getCachedUserSettings();
    if (cached != null) {
      log('⚙️💾 [Auth] Kullanıcı ayarları LOCAL\'den geldi');
      return UserSettingsModel.fromSupabase(cached);
    }

    try {
      log('⚙️☁️ [Auth] Kullanıcı ayarları Supabase\'den çekiliyor...');
      final settings = await _supabase.getUserSettings(userId);
      if (settings != null) {
        await _local.cacheUserSettings(settings.toSupabase());
        log('💾 [Auth] Ayarlar local cache\'e yazıldı');
      }
      return settings;
    } catch (e) {
      log('⚙️❌ [Auth] Ayarlar çekilemedi (offline?): $e');
      return null;
    }
  }

  Future<void> saveThemeLocally(String theme) async {
    await _local.setTheme(theme);
  }

  Future<bool> isOnboardingCompleted() async {
    if (await _local.isOnboardingCompleted()) {
      log(
        '🎓💾 [Auth] Onboarding LOCAL\'de tamamlanmış, Supabase\'e gidilmiyor',
      );
      return true;
    }

    final userId = currentUserId;
    if (userId == null) return false;

    try {
      log('🎓☁️ [Auth] Onboarding durumu Supabase\'den kontrol ediliyor...');
      return await _supabase.isOnboardingCompleted(userId);
    } catch (e) {
      log('🎓❌ [Auth] Onboarding durumu çekilemedi (offline?): $e');
      return false;
    }
  }
}
