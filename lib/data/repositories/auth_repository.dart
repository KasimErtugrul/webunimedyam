import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../datasources/local/local_datasource.dart';
import '../models/profile_model.dart';
import '../models/user_settings_model.dart';

class AuthRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;

  AuthRepository({
    required SupabaseDataSource supabase,
    required LocalDataSource local,
  })  : _supabase = supabase,
        _local = local;

  bool get isLoggedIn => _supabase.currentUser != null;
  String? get currentUserId => _supabase.currentUser?.id;
  Stream get authStateChanges => _supabase.authStateChanges;

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
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    log('🔑☁️ [Auth] Giriş isteği Supabase\'e gönderiliyor → $email');
    await _supabase.signIn(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    log('🚪🧹 [Auth] Çıkış yapılıyor, local cache temizleniyor...');
    await _local.clearUserSettings();
    await _supabase.signOut();
    log('✅ [Auth] Çıkış tamamlandı');
  }

  Future<ProfileModel?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) { log('⚠️ [Auth] getProfile: kullanıcı giriş yapmamış'); return null; }
    log('👤☁️ [Auth] Profil Supabase\'den çekiliyor → $userId');
    final profile = await _supabase.getProfile(userId);
    log('${profile != null ? '✅' : '❌'} [Auth] Profil ${profile != null ? 'geldi: \${profile.username}' : 'bulunamadı'}');
    return profile;
  }

  Future<void> updateProfile(ProfileModel profile) async {
    log('✏️☁️ [Auth] Profil güncelleniyor → \${profile.username}');
    await _supabase.updateProfile(profile);
    log('✅ [Auth] Profil güncellendi');
  }

  // FIX: getUserSettings artık önce local cache'e bakıyor.
  // Cache yoksa Supabase'den çekip cache'e kaydediyor.
  Future<UserSettingsModel?> getUserSettings() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final cached = await _local.getCachedUserSettings();
    if (cached != null) {
      log('⚙️💾 [Auth] Kullanıcı ayarları LOCAL\'den geldi');
      return UserSettingsModel.fromSupabase(cached);
    }
    log('⚙️☁️ [Auth] Kullanıcı ayarları Supabase\'den çekiliyor...');
    final settings = await _supabase.getUserSettings(userId);
    if (settings != null) {
      await _local.cacheUserSettings(settings.toSupabase());
      log('💾 [Auth] Ayarlar local cache\'e yazıldı');
    }
    return settings;
  }

  // FIX: Ayar güncellenince cache de güncelleniyor.
  Future<void> updateUserSettings(UserSettingsModel settings) async {
    log('⚙️✏️ [Auth] Ayarlar güncelleniyor → Supabase + local cache');
    await _supabase.updateUserSettings(settings);
    await _local.cacheUserSettings(settings.toSupabase());
    log('✅ [Auth] Ayarlar güncellendi');
  }

  // FIX: Local flag önce kontrol edilir; true dönerse Supabase'e hiç gidilmez.
  // completeOnboarding() zaten hem local'e hem Supabase'e yazıyor, bu yüzden
  // onboarding tamamlandıktan sonra her açılışta ağ isteği yapılmasına gerek yok.
  Future<bool> isOnboardingCompleted() async {
    if (await _local.isOnboardingCompleted()) {
      log('🎓💾 [Auth] Onboarding LOCAL\'de tamamlanmış, Supabase\'e gidilmiyor');
      return true;
    }
    final userId = currentUserId;
    if (userId == null) return false;
    log('🎓☁️ [Auth] Onboarding durumu Supabase\'den kontrol ediliyor...');
    return await _supabase.isOnboardingCompleted(userId);
  }

  Future<void> completeOnboarding() async {
    log('🎓✅ [Auth] Onboarding tamamlandı → local + Supabase yazılıyor');
    await _local.setOnboardingCompleted();
    final userId = currentUserId;
    if (userId != null) {
      await _supabase.completeOnboarding(userId);
    }
  }
}
