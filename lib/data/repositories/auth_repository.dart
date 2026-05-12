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
    await _supabase.signIn(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.signOut();
  }

  Future<ProfileModel?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return await _supabase.getProfile(userId);
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await _supabase.updateProfile(profile);
  }

  Future<UserSettingsModel?> getUserSettings() async {
    final userId = currentUserId;
    if (userId == null) return null;
    return await _supabase.getUserSettings(userId);
  }

  Future<void> updateUserSettings(UserSettingsModel settings) async {
    await _supabase.updateUserSettings(settings);
  }

  Future<bool> isOnboardingCompleted() async {
    final userId = currentUserId;
    if (userId == null) return await _local.isOnboardingCompleted();
    return await _supabase.isOnboardingCompleted(userId);
  }

  Future<void> completeOnboarding() async {
    await _local.setOnboardingCompleted();
    final userId = currentUserId;
    if (userId != null) {
      await _supabase.completeOnboarding(userId);
    }
  }
}