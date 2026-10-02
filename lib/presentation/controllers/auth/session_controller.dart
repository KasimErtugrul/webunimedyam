import 'dart:developer';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/session_service.dart';

class SessionController extends GetxController {
  SessionController({
    required AuthRepository authRepository,
    required SessionService sessionService,
  }) : _repo = authRepository,
       _session = sessionService;

  final AuthRepository _repo;
  final SessionService _session;

  final isLoading = false.obs;

  Future<void> signOut() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      await _session.onLogout();
      await _repo.signOut();

      Get.offAllNamed(AppRoutes.home);
    } catch (e, st) {
      log('signOut failed: $e', error: e, stackTrace: st);
      Get.snackbar('Hata', 'Çıkış yapılırken hata oluştu.');
    } finally {
      isLoading.value = false;
    }
  }
}
