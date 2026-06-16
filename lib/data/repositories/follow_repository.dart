/* // lib/data/repositories/follow_repository.dart
//
// DÜZELTMELER & EKLENTİLER:
//  1. followUserById(): hedef profilin visibility'sine bakarak requireApproval
//     otomatik belirlenir — 'friends' veya 'private' → pending, 'public' → accepted.
//  2. getMyFollowStatus(): null döner = takip yok, FollowModel döner = takip var.
//  3. isAlreadyFollowing() / isPendingRequest() kolaylık metodları eklendi.
//  4. getProfileWithFollowStatus(): profil + follow durumunu tek seferde çeker.

import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/follow_model.dart';

class FollowRepository {
  final SupabaseDataSource _supabase;

  FollowRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── Takip İşlemleri ──────────────────────────────────────────────────────

  /// Kullanıcıyı takip et.
  ///
  /// Hedef profilin `profile_visibility` ayarı otomatik okunur:
  ///  - 'public'  → status = 'accepted' (direkt takip)
  ///  - 'friends' → status = 'pending'  (onay bekliyor)
  ///  - 'private' → status = 'pending'  (onay bekliyor)
  Future<FollowResult> followUserById(String followingId) async {
    final followerId = _supabase.currentUser?.id;
    if (followerId == null) {
      throw Exception('Kullanıcı girişi gerekli');
    }

    // Kendini takip etmeye çalışıyor mu?
    if (followerId == followingId) {
      throw Exception('Kendinizi takip edemezsiniz');
    }

    // Zaten takip ediyor mu?
    final existing = await _supabase.getFollowStatus(
      followerId: followerId,
      followingId: followingId,
    );
    if (existing != null) {
      final status = existing['status'] as String?;
      if (status == 'accepted') {
        log('👣⚠️ [Follow] Zaten takip ediliyor: $followingId');
        return FollowResult.alreadyFollowing;
      }
      if (status == 'pending') {
        log('👣⚠️ [Follow] İstek zaten beklemede: $followingId');
        return FollowResult.alreadyPending;
      }
    }

    // Hedef profilin görünürlüğünü kontrol et
    final targetProfile = await _supabase.getPublicProfile(followingId);
    final visibility =
        targetProfile?['profile_visibility'] as String? ?? 'public';
    final requireApproval = visibility == 'friends' || visibility == 'private';

    log(
      '👣➕ [Follow] $followerId → $followingId '
      '(visibility: $visibility, approval: $requireApproval)',
    );

    await _supabase.followUser(
      followerId: followerId,
      followingId: followingId,
      requireApproval: requireApproval,
    );

    return requireApproval ? FollowResult.pendingApproval : FollowResult.success;
  }

  /// Takibi bırak.
  Future<void> unfollowUser(String followingId) async {
    final followerId = _supabase.currentUser?.id;
    if (followerId == null) throw Exception('Kullanıcı girişi gerekli');
    log('👣➖ [Follow] $followerId ↛ $followingId');
    await _supabase.unfollowUser(
      followerId: followerId,
      followingId: followingId,
    );
  }

  /// Mevcut kullanıcı, [followingId]'yi takip ediyor mu?
  /// null döner → takip yok.
  /// FollowModel döner → takip var (status: pending veya accepted)
  Future<FollowModel?> getMyFollowStatus(String followingId) async {
    final followerId = _supabase.currentUser?.id;
    if (followerId == null) return null;

    final data = await _supabase.getFollowStatus(
      followerId: followerId,
      followingId: followingId,
    );
    if (data == null) return null;
    return FollowModel.fromSupabase(data);
  }

  /// [followingId]'yi takip ediyor mu? (accepted)
  Future<bool> isFollowing(String followingId) async {
    final model = await getMyFollowStatus(followingId);
    return model?.status == FollowStatus.accepted;
  }

  /// [followingId] için bekleyen istek var mı?
  Future<bool> hasPendingRequest(String followingId) async {
    final model = await getMyFollowStatus(followingId);
    return model?.status == FollowStatus.pending;
  }

  /// Profil + mevcut kullanıcının follow durumunu birlikte döner.
  Future<ProfileWithFollowStatus?> getProfileWithFollowStatus(
    String targetUserId,
  ) async {
    final profileData = await _supabase.getPublicProfile(targetUserId);
    if (profileData == null) return null;

    final followModel = await getMyFollowStatus(targetUserId);
    final followCounts = await getFollowCounts(targetUserId);

    return ProfileWithFollowStatus(
      userId: targetUserId,
      username: profileData['username'] as String? ?? '',
      fullName: profileData['full_name'] as String? ?? '',
      avatarUrl: profileData['avatar_url'] as String?,
      profileVisibility:
          profileData['profile_visibility'] as String? ?? 'public',
      followStatus: followModel?.status,
      followersCount: followCounts.followersCount,
      followingCount: followCounts.followingCount,
    );
  }

  // ─── Listeler ─────────────────────────────────────────────────────────────

  /// [userId]'nin takipçilerini döner.
  Future<List<FollowModel>> getFollowers(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    log('📋 [Follow] getFollowers → $userId');
    final data = await _supabase.getFollowers(
      userId,
      limit: limit,
      offset: offset,
    );
    return data.map(FollowModel.fromSupabase).toList();
  }

  /// [userId]'nin takip ettiklerini döner.
  Future<List<FollowModel>> getFollowing(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    log('📋 [Follow] getFollowing → $userId');
    final data = await _supabase.getFollowing(
      userId,
      limit: limit,
      offset: offset,
    );
    return data.map(FollowModel.fromSupabase).toList();
  }

  /// Takipçi + takip edilen sayılarını döner.
  Future<FollowCounts> getFollowCounts(String userId) async {
    final data = await _supabase.getFollowCounts(userId);
    if (data == null) return FollowCounts.empty;
    return FollowCounts.fromSupabase(data);
  }

  // ─── Bekleyen İstekler ────────────────────────────────────────────────────

  /// Mevcut kullanıcıya gelen bekleyen takip isteklerini döner.
  Future<List<FollowModel>> getMyPendingRequests() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return [];
    final data = await _supabase.getPendingFollowRequests(userId);
    return data.map(FollowModel.fromSupabase).toList();
  }

  Future<void> acceptRequest(String followId) async {
    log('✅ [Follow] acceptRequest → $followId');
    await _supabase.acceptFollowRequest(followId);
  }

  Future<void> rejectRequest(String followId) async {
    log('❌ [Follow] rejectRequest → $followId');
    await _supabase.rejectFollowRequest(followId);
  }
}

// ─── Yardımcı Tipler ──────────────────────────────────────────────────────────

/// followUserById() sonuç kodu
enum FollowResult {
  /// Başarıyla takip edildi (public profil, direkt accepted)
  success,

  /// İstek gönderildi, onay bekleniyor (friends/private profil)
  pendingApproval,

  /// Zaten takip ediliyor (accepted)
  alreadyFollowing,

  /// Zaten istek gönderilmiş (pending)
  alreadyPending,
}

/// Profil ekranında kullanılmak üzere profil + takip durumunu bir arada tutar.
class ProfileWithFollowStatus {
  final String userId;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String profileVisibility; // 'public' | 'friends' | 'private'
  final FollowStatus? followStatus; // null → takip yok
  final int followersCount;
  final int followingCount;

  const ProfileWithFollowStatus({
    required this.userId,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    required this.profileVisibility,
    this.followStatus,
    required this.followersCount,
    required this.followingCount,
  });

  bool get isPublic => profileVisibility == 'public';
  bool get isFriends => profileVisibility == 'friends';
  bool get isPrivate => profileVisibility == 'private';

  bool get isFollowing => followStatus == FollowStatus.accepted;
  bool get isPending => followStatus == FollowStatus.pending;
  bool get isNotFollowing => followStatus == null;

  /// Profil aktivite verilerine erişilebilir mi?
  /// Public profiller her zaman, friends profiller sadece takipçilere açık.
  bool get canViewActivity => isPublic || isFollowing;
} */