// lib/presentation/controllers/follow_controller.dart

import 'dart:developer';
import 'package:get/get.dart';
import '../../data/repositories/follow_repository.dart';
import '../../data/models/follow_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/user_settings_model.dart';

class FollowController extends GetxController {
  final FollowRepository followRepository;

  FollowController({required this.followRepository});

  // ─── Hedef kullanıcı için durum ───────────────────────────────────────────
  // Profil ekranında açık olan kullanıcıya ait takip durumu
  final currentProfileFollow = Rxn<FollowModel>();
  final followCounts          = Rxn<FollowCounts>();
  final isFollowLoading       = false.obs;

  // ─── Takipçi/takip edilen listeleri ──────────────────────────────────────
  final followers     = <FollowModel>[].obs;
  final following     = <FollowModel>[].obs;
  final pendingRequests = <FollowModel>[].obs;

  final isFollowersLoading  = false.obs;
  final isFollowingLoading  = false.obs;
  final isPendingLoading    = false.obs;

  final errorMessage   = RxnString();
  final successMessage = RxnString();

  // ─── Başlatma ─────────────────────────────────────────────────────────────

  /// Profil ekranı açıldığında çağrılır. [targetUserId]: profili açılan kullanıcı
  Future<void> initForProfile(String targetUserId) async {
    await Future.wait([
      loadFollowStatus(targetUserId),
      loadFollowCounts(targetUserId),
    ]);
  }

  // ─── Takip Durumu ─────────────────────────────────────────────────────────

  Future<void> loadFollowStatus(String targetUserId) async {
    try {
      isFollowLoading.value = true;
      currentProfileFollow.value =
          await followRepository.getMyFollowStatus(targetUserId);
    } catch (e) {
      log('loadFollowStatus error: $e');
    } finally {
      isFollowLoading.value = false;
    }
  }

  Future<void> loadFollowCounts(String userId) async {
    try {
      followCounts.value = await followRepository.getFollowCounts(userId);
    } catch (e) {
      log('loadFollowCounts error: $e');
    }
  }

  /// Takip et / takibi bırak toggle.
  /// [targetProfile]: hedef kullanıcının profil bilgisi (visibility kontrolü için)
  Future<void> toggleFollow(ProfileModel targetProfile) async {
    final current = currentProfileFollow.value;

    try {
      isFollowLoading.value = true;

      if (current == null) {
        // Henüz takip etmiyor → takip et
        final requireApproval =
            targetProfile.profileVisibility == VisibilityOption.private;

        await followRepository.followUser(
          followingId: targetProfile.id,
          requireApproval: requireApproval,
        );

        // Optimistic: yeni FollowModel oluştur
        currentProfileFollow.value = FollowModel(
          id: '',
          followerId: '',
          followingId: targetProfile.id,
          status: requireApproval ? FollowStatus.pending : FollowStatus.accepted,
          createdAt: DateTime.now(),
        );

        successMessage.value = requireApproval
            ? 'Takip isteği gönderildi.'
            : '${targetProfile.username ?? 'Kullanıcı'} takip edildi.';
      } else {
        // Zaten takip ediyor → takibi bırak
        await followRepository.unfollowUser(targetProfile.id);
        currentProfileFollow.value = null;
        successMessage.value = 'Takip bırakıldı.';
      }

      // Sayıları yenile
      await loadFollowCounts(targetProfile.id);
    } catch (e) {
      log('toggleFollow error: $e');
      errorMessage.value = 'İşlem başarısız oldu. Tekrar deneyin.';
      // Rollback
      currentProfileFollow.value = current;
    } finally {
      isFollowLoading.value = false;
    }
  }

  // ─── Listeler ─────────────────────────────────────────────────────────────

  Future<void> loadFollowers(String userId) async {
    try {
      isFollowersLoading.value = true;
      followers.value = await followRepository.getFollowers(userId);
    } catch (e) {
      log('loadFollowers error: $e');
      errorMessage.value = 'Takipçiler yüklenemedi.';
    } finally {
      isFollowersLoading.value = false;
    }
  }

  Future<void> loadFollowing(String userId) async {
    try {
      isFollowingLoading.value = true;
      following.value = await followRepository.getFollowing(userId);
    } catch (e) {
      log('loadFollowing error: $e');
      errorMessage.value = 'Takip edilenler yüklenemedi.';
    } finally {
      isFollowingLoading.value = false;
    }
  }

  Future<void> loadPendingRequests() async {
    try {
      isPendingLoading.value = true;
      pendingRequests.value = await followRepository.getMyPendingRequests();
    } catch (e) {
      log('loadPendingRequests error: $e');
    } finally {
      isPendingLoading.value = false;
    }
  }

  // ─── İstek Kabul / Red ────────────────────────────────────────────────────

  Future<void> acceptRequest(FollowModel request) async {
    try {
      await followRepository.acceptRequest(request.id);
      pendingRequests.removeWhere((r) => r.id == request.id);
      successMessage.value = '${request.followerUsername ?? 'İstek'} kabul edildi.';
    } catch (e) {
      log('acceptRequest error: $e');
      errorMessage.value = 'İstek kabul edilemedi.';
    }
  }

  Future<void> rejectRequest(FollowModel request) async {
    try {
      await followRepository.rejectRequest(request.id);
      pendingRequests.removeWhere((r) => r.id == request.id);
    } catch (e) {
      log('rejectRequest error: $e');
      errorMessage.value = 'İstek reddedilemedi.';
    }
  }

  // ─── Yardımcılar ──────────────────────────────────────────────────────────

  /// Mevcut kullanıcı [targetUserId]'yi takip ediyor mu?
  bool isFollowing(String targetUserId) {
    final f = currentProfileFollow.value;
    return f != null &&
        f.followingId == targetUserId &&
        f.status == FollowStatus.accepted;
  }

  /// Bekleyen takip isteği var mı?
  bool hasPendingRequest(String targetUserId) {
    final f = currentProfileFollow.value;
    return f != null &&
        f.followingId == targetUserId &&
        f.status == FollowStatus.pending;
  }
}