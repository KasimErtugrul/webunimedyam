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
  }) : _supabase = supabase,
       _local = local;

  bool get isLoggedIn => _supabase.currentUser != null;
  String? get currentUserId => _supabase.currentUser?.id;
  Stream get authStateChanges => _supabase.authStateChanges;

  // ─── YAZMA İŞLEMLERİ (Write) ─────────────────────────────────────────────
  // Bu işlemlerde try-catch YOK. Çünkü hata olursa Controller'ın bunu yakalayıp
  // ekrana "Şifre yanlış" veya "İnternet yok" yazması gerekir.

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

  Future<void> signIn({required String email, required String password}) async {
    log('🔑☁️ [Auth] Giriş isteği Supabase\'e gönderiliyor → $email');
    await _supabase.signIn(email: email, password: password);
  }

  Future<void> signOut() async {
    log('🚪🧹 [Auth] Çıkış yapılıyor, tüm local veriler temizleniyor...');
    await Future.wait([
      _local.clearUserSettings(),
      _local.clearFavoriteVideos(), // ← EKSİKTİ
      _local.clearCache(), // ← EKSİKTİ (video cache)
      _local.clearUserStats(), // ← EKSİKTİ
      _local.clearVideoSectionCache(), // ← EKSİKTİ
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
    log('⚙️✏️ [Auth] Ayarlar güncelleniyor → Supabase + local cache');
    await _supabase.updateUserSettings(settings);
    await _local.cacheUserSettings(settings.toSupabase());
    log('✅ [Auth] Ayarlar güncellendi');
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
  // Bu işlemlerde offline güvenlik var. İnternet yoksa uygulama çökmeyecek,
  // cache'den veya null dönecektir.

  Future<ProfileModel?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) {
      log('⚠️ [Auth] getProfile: kullanıcı giriş yapmamış');
      return null;
    }

    try {
      log('👤☁️ [Auth] Profil Supabase\'den çekiliyor → $userId');
      final profile = await _supabase.getProfile(userId);
      log(
        '${profile != null ? '✅' : '❌'} [Auth] Profil ${profile != null ? 'geldi: ${profile.username}' : 'bulunamadı'}',
      );
      return profile;
    } catch (e) {
      log('👤❌ [Auth] Profil çekilemedi (offline?): $e');
      return null; // UI çökmesin, profil yok sayılsın
    }
  }

  Future<UserSettingsModel?> getUserSettings() async {
    final userId = currentUserId;
    if (userId == null) return null;

    // 1. Önce Local Cache'e bak
    final cached = await _local.getCachedUserSettings();
    if (cached != null) {
      log('⚙️💾 [Auth] Kullanıcı ayarları LOCAL\'den geldi');
      return UserSettingsModel.fromSupabase(cached);
    }

    // 2. Cache yoksa Supabase'e bak (Ama hata alırsa uygulamayı çökertme)
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
      return null; // UI çökmesin, varsayılan ayarlar kullanılsın
    }
  }

  Future<bool> isOnboardingCompleted() async {
    // 1. Local flag önce kontrol et
    if (await _local.isOnboardingCompleted()) {
      log(
        '🎓💾 [Auth] Onboarding LOCAL\'de tamamlanmış, Supabase\'e gidilmiyor',
      );
      return true;
    }

    final userId = currentUserId;
    if (userId == null) return false;

    // 2. Local'de yoksa Supabase'e sor (Ama hata alırsa uygulamayı çökertme)
    try {
      log('🎓☁️ [Auth] Onboarding durumu Supabase\'den kontrol ediliyor...');
      return await _supabase.isOnboardingCompleted(userId);
    } catch (e) {
      log('🎓❌ [Auth] Onboarding durumu çekilemedi (offline?): $e');
      return false; // UI çökmesin, onboarding yok sayılsın (belki tekrar gösterilir ama çökmez)
    }
  }
}
