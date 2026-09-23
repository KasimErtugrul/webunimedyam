// lib/presentation/controllers/auth/change_password_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Şifre Değiştir ekranının tüm state'i ve iş mantığı.
/// Ekran katmanında setState yok; her şey Rx + Obx ile reaktiftir.
class ChangePassController extends GetxController {
  // ─── Form ──────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();

  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final currentFocus = FocusNode();
  final newFocus = FocusNode();
  final confirmFocus = FocusNode();

  // ─── Reaktif UI state ──────────────────────────────────────────────
  final obscureCurrent = true.obs;
  final obscureNew = true.obs;

  // Şifre gücü ölçütleri (tasarımdaki 2x2 liste)
  final hasMinLength = false.obs; // En az 8 karakter
  final hasUppercase = false.obs; // Büyük harf (A-Z)
  final hasDigit = false.obs; // Rakam (0-9)
  final hasSpecial = false.obs; // Özel sembol (!@#$)
  final strength = 0.obs; // 0-4 toplam puan

  // "Diğer oturumları sonlandır" — tasarımda varsayılan AÇIK
  final endOtherSessions = true.obs;

  // Ağ durumu
  final isChangingPassword = false.obs;
  final errorMessage = ''.obs;

  // ─── Regex ─────────────────────────────────────────────────────────
  static final RegExp _upperRe = RegExp(r'[A-Z]');
  static final RegExp _letterRe = RegExp(r'[A-Za-z]');
  static final RegExp _digitRe = RegExp(r'[0-9]');
  static final RegExp _specialRe = RegExp(r'[^A-Za-z0-9\s]');

  @override
  void onInit() {
    super.onInit();
    newCtrl.addListener(_syncStrength);
    _syncStrength();
  }

  @override
  void onClose() {
    newCtrl.removeListener(_syncStrength);
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    currentFocus.dispose();
    newFocus.dispose();
    confirmFocus.dispose();
    super.onClose();
  }

  /// Ekranı temiz başlangıç durumuna döndürür.
  void resetState() {
    currentCtrl.clear();
    newCtrl.clear();
    confirmCtrl.clear();
    obscureCurrent.value = true;
    obscureNew.value = true;
    endOtherSessions.value = true;
    isChangingPassword.value = false;
    errorMessage.value = '';
    _syncStrength();
  }

  // ─── Şifre gücü ────────────────────────────────────────────────────
  void _syncStrength() {
    final v = newCtrl.text;
    hasMinLength.value = v.length >= 8;
    hasUppercase.value = _upperRe.hasMatch(v);
    hasDigit.value = _digitRe.hasMatch(v);
    hasSpecial.value = _specialRe.hasMatch(v);
    strength.value =
        (hasMinLength.value ? 1 : 0) +
        (hasUppercase.value ? 1 : 0) +
        (hasDigit.value ? 1 : 0) +
        (hasSpecial.value ? 1 : 0);
  }

  String get strengthLabel {
    switch (strength.value) {
      case 4:
        return 'Çok Güçlü';
      case 3:
        return 'Güçlü';
      case 2:
        return 'Orta';
      case 1:
        return 'Zayıf';
      default:
        return 'Çok Zayıf';
    }
  }

  // ─── Etkileşimler ──────────────────────────────────────────────────
  void toggleObscureCurrent() => obscureCurrent.value = !obscureCurrent.value;
  void toggleObscureNew() => obscureNew.value = !obscureNew.value;
  void setEndOtherSessions(bool value) => endOtherSessions.value = value;

  /// "Şifremi Unuttum?" → şifre sıfırlama akışına yönlendirme.
  void forgotPassword() {
    // TODO: Get.toNamed(Routes.forgotPassword);
  }

  // ─── Validators ────────────────────────────────────────────────────
  String? validateCurrent(String? value) {
    if (value == null || value.isEmpty) return 'Mevcut şifrenizi girin.';
    return null;
  }

  String? validateNew(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Yeni şifrenizi girin.';
    if (v.length < 8) return 'Şifre en az 8 karakter olmalı.';
    if (!_letterRe.hasMatch(v) || !_digitRe.hasMatch(v)) {
      return 'Şifre harf ve rakam içermelidir.';
    }
    if (v == currentCtrl.text) return 'Yeni şifre eskisiyle aynı olamaz.';
    return null;
  }

  String? validateConfirm(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Yeni şifreyi doğrulayın.';
    if (v != newCtrl.text) return 'Yeni şifreler birbiriyle uyuşmuyor.';
    return null;
  }

  // ─── Submit ────────────────────────────────────────────────────────
  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await changePassword();
  }

  /// Eski çağrı noktaları bozulmasın diye parametreler opsiyonel bırakıldı:
  /// parametre verilmezse controller'daki alanların değerleri kullanılır.
  Future<void> changePassword({
    String? currentPassword,
    String? newPassword,
  }) async {
    if (isChangingPassword.value) return;
    errorMessage.value = '';
    isChangingPassword.value = true;
    try {
      // ═══════════════════════════════════════════════════════════════
      // MEVCUT BACKEND ÇAĞRINIZ — eski API gövdenizi buraya taşıyın.
      // Örnek:
      // await Get.find<AuthRepository>().changePassword(
      //   currentPassword: currentPassword ?? currentCtrl.text,
      //   newPassword: newPassword ?? newCtrl.text,
      //   endOtherSessions: endOtherSessions.value,
      // );
      await Future<void>.delayed(const Duration(milliseconds: 900));
      // ═══════════════════════════════════════════════════════════════

      _showSuccessSnackbar();
      Get.back<void>();
    } catch (_) {
      errorMessage.value =
          'Şifre güncellenemedi. Bilgileri kontrol edip tekrar deneyin.';
    } finally {
      isChangingPassword.value = false;
    }
  }

  void _showSuccessSnackbar() {
    final ctx = Get.context;
    if (ctx == null) return;
    final scheme = Theme.of(ctx).colorScheme;
    Get.snackbar(
      'Şifre güncellendi',
      'Şifreniz başarıyla değiştirildi.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: scheme.primary,
      colorText: scheme.onPrimary,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 12,
      icon: Icon(Icons.check_circle_rounded, color: scheme.onPrimary),
      shouldIconPulse: false,
      duration: const Duration(seconds: 3),
    );
  }
}
