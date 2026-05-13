import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/video_model.dart';
import '../../models/university_model.dart';
import '../../models/profile_model.dart';
import '../../models/user_settings_model.dart';
import '../../models/comment_model.dart';

class SupabaseDataSource {
  final _client = Supabase.instance.client;

  // Auth
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Profil
  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromSupabase(data);
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await _client
        .from('profiles')
        .update(profile.toSupabase())
        .eq('id', profile.id);
  }

  // Ayarlar
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    final data = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return UserSettingsModel.fromSupabase(data);
  }

  Future<void> updateUserSettings(UserSettingsModel settings) async {
    await _client
        .from('user_settings')
        .update(settings.toSupabase())
        .eq('user_id', settings.userId);
  }

  // ─── Üniversiteler ────────────────────────────────────────────────────────

  /// Tüm üniversiteleri döner.
  Future<List<UniversityModel>> getUniversities() async {
    final data = await _client
        .from('universities')
        .select()
        .order('name', ascending: true);
    return (data as List).map((e) => UniversityModel.fromSupabase(e)).toList();
  }

  // ─── Video Cache ──────────────────────────────────────────────────────────

  /// Tüm önbellek videolarını döner (tarihe göre sıralı).
  Future<List<VideoModel>> getCachedVideos() async {
    final data = await _client
        .from('videos_cache')
        .select('*, universities(name)')
        .order('published_at', ascending: false);

    return (data as List).map((e) {
      final row = Map<String, dynamic>.from(e);
      // Join'den gelen university adını düzleştir
      if (row['universities'] != null) {
        row['university_name'] = row['universities']['name'];
      }
      row.remove('universities');
      return VideoModel.fromSupabase(row);
    }).toList();
  }

  /// Belirli bir üniversitenin videolarını döner.
  Future<List<VideoModel>> getCachedVideosByUniversity(int universityId) async {
    final data = await _client
        .from('videos_cache')
        .select('*, universities(name)')
        .eq('university_id', universityId)
        .order('published_at', ascending: false);

    return (data as List).map((e) {
      final row = Map<String, dynamic>.from(e);
      if (row['universities'] != null) {
        row['university_name'] = row['universities']['name'];
      }
      row.remove('universities');
      return VideoModel.fromSupabase(row);
    }).toList();
  }

  /// Ana sayfa için: her üniversiteden en son videoyu döner.
  /// latest_videos_per_university view'ını kullanır → tek sorgu, çok hızlı.
  Future<List<VideoModel>> getLatestVideoPerUniversity() async {
    final data = await _client
        .from('latest_videos_per_university')
        .select()
        .order('published_at', ascending: false);

    return (data as List).map((e) => VideoModel.fromSupabase(e)).toList();
  }

  Future<void> upsertVideos(List<VideoModel> videos) async {
    final data = videos.map((v) => v.toSupabase()).toList();
    await _client.from('videos_cache').upsert(data, onConflict: 'video_id');
  }

  // ─── Favoriler ────────────────────────────────────────────────────────────

  Future<List<String>> getFavoriteVideoIds(String userId) async {
    final data = await _client
        .from('favorites')
        .select('video_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['video_id'] as String).toList();
  }

  Future<void> addFavorite(String userId, String videoId) async {
    await _client.from('favorites').insert({
      'user_id': userId,
      'video_id': videoId,
    });
  }

  Future<void> removeFavorite(String userId, String videoId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('video_id', videoId);
  }

  // ─── Yorumlar ─────────────────────────────────────────────────────────────

  Future<List<CommentModel>> getComments(String videoId) async {
    final data = await _client
        .from('comments')
        .select('*, profiles(username, avatar_url)')
        .eq('video_id', videoId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => CommentModel.fromSupabase(e)).toList();
  }

  Future<void> addComment(String userId, String videoId, String content) async {
    await _client.from('comments').insert({
      'user_id': userId,
      'video_id': videoId,
      'content': content,
    });
  }

  Future<void> deleteComment(String commentId) async {
    await _client.from('comments').delete().eq('id', commentId);
  }

  // ─── Onboarding ──────────────────────────────────────────────────────────

  Future<bool> isOnboardingCompleted(String userId) async {
    final data = await _client
        .from('onboarding')
        .select('completed')
        .eq('user_id', userId)
        .maybeSingle();
    return data?['completed'] ?? false;
  }

  Future<void> completeOnboarding(String userId) async {
    await _client.from('onboarding').update({
      'completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }
}