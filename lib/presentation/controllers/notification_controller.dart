import 'package:get/get.dart';

class NotificationsController extends GetxController {

  NotificationsController();
/* 
  final pendingRequests = <FollowModel>[].obs;
  final isLoading       = false.obs;
  final errorMessage    = RxnString();
  final successMessage  = RxnString();

  @override
  void onReady() {
    super.onReady();
    loadPendingRequests();
  }

  Future<void> loadPendingRequests() async {
    try {
      isLoading.value = true;
      pendingRequests.value = await followRepository.getMyPendingRequests();
      log('[Notifications] ${pendingRequests.length} bekleyen istek yüklendi.');
    } catch (e) {
      log('loadPendingRequests error: $e');
      errorMessage.value = 'İstekler yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptRequest(FollowModel request) async {
    // Optimistic removal
    pendingRequests.removeWhere((r) => r.id == request.id);
    try {
      await followRepository.acceptRequest(request.id);
      successMessage.value =
          '${request.followerUsername ?? 'İstek'} kabul edildi.';
      log('[Notifications] Kabul: ${request.id}');
    } catch (e) {
      // Rollback
      pendingRequests.add(request);
      log('acceptRequest error: $e');
      errorMessage.value = 'İstek kabul edilemedi.';
    }
  }

  Future<void> rejectRequest(FollowModel request) async {
    // Optimistic removal
    pendingRequests.removeWhere((r) => r.id == request.id);
    try {
      await followRepository.rejectRequest(request.id);
      log('[Notifications] Reddedildi: ${request.id}');
    } catch (e) {
      // Rollback
      pendingRequests.add(request);
      log('rejectRequest error: $e');
      errorMessage.value = 'İstek reddedilemedi.';
    }
  } */
}