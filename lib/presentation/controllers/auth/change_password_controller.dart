import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../services/analytics_service.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController({required AuthRepository authRepository})
      : _repo = authRepository;

  final AuthRepository _repo;

  final isChangingPassword = false.obs;
  final errorMessage = ''.obs;
  final success = false.obs;

  @override
  void onInit() {
    super.onInit();
    _reset();
  }

  void _reset() {
    errorMessage.value = '';
    success.value = false;
  }

  /// Ekran açıldığında çağrılabilir; state temizliği.
  void resetState() => _reset();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (isChangingPassword.value) return;
    isChangingPassword.value = true;
    _reset();

    try {
      await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      success.value = true;
      AnalyticsService.instance.logEvent('password_changed');

      await Get.dialog(
        AlertDialog(
          title: const Text('Şifre Değiştirildi'),
          content: const Text('Şifreniz başarıyla güncellendi.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Tamam'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      Get.back();
    } catch (e, st) {
      log('changePassword failed: $e', error: e, stackTrace: st);
      errorMessage.value =
          'Şifre değiştirilemedi. Mevcut şifrenizi kontrol edin.';
    } finally {
      isChangingPassword.value = false;
    }
  }
}