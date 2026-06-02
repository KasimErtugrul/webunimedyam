// lib/data/repositories/follow_repository.dart

import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/follow_model.dart';

class FollowRepository {
  final SupabaseDataSource _supabase;

  FollowRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── Takip İşlemleri ──────────────────────────────────────────────────────

  /// Kullanıcıyı takip et.
  /// [requireApproval]: hedef profil 'private' ise true geçin → status=pending
  Future<void> followUser({
    required String followingId,
    bool requireApproval = false,
  }) async {
    final followerId = _supabase.currentUser?.id;
    if (followerId == null) throw Exception('Kullanıcı girişi gerekli');
    log('👣➕ [Follow] $followerId → $followingId (approval: $requireApproval)');
    await _supabase.followUser(
      followerId: followerId,
      followingId: followingId,
      requireApproval: requireApproval,
    );
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

  // ─── Listeler ─────────────────────────────────────────────────────────────

  /// [userId]'nin takipçilerini döner.
  Future<List<FollowModel>> getFollowers(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    log('📋 [Follow] getFollowers → $userId');
    final data = await _supabase.getFollowers(userId, limit: limit, offset: offset);
    return data.map(FollowModel.fromSupabase).toList();
  }

  /// [userId]'nin takip ettiklerini döner.
  Future<List<FollowModel>> getFollowing(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    log('📋 [Follow] getFollowing → $userId');
    final data = await _supabase.getFollowing(userId, limit: limit, offset: offset);
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