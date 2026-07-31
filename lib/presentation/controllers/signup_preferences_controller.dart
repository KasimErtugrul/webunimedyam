// lib/presentation/controllers/signup_preferences_controller.dart
//
// Yeni kayıt (signup) sonrası — email OTP doğrulaması veya Google ile ilk
// giriş sonrasında — kullanıcıya bir kez gösterilen temel tercih ekranının
// controller'ı.
//
// Sorulan tercihler:
//   1) Uygulama teması (dark / light / system)
//   2) Otomatik oynatma (açık / kapalı)
//   3) Bildirimler (açık / kapalı) — "açık" seçilirse sistem bildirim izni
//      burada istenir (NotificationService.onUserLogin).
//   4) Profil ve aktivite görünürlüğü (herkese açık / gizli)
//
// Her seçim yapıldığı an SettingsController üzerinden hem uygulama state'i
// (Rx alanlar, tema anında değişir) hem de Supabase (user_settings /
// profiles tabloları) güncellenir — SettingsController zaten bunu
// optimistic update + debounce ile yapıyor, burada tekrar yazılmıyor.
//
// Ekran ZORUNLU DEĞİLDİR: kullanıcı "Atla" diyebilir, bu durumda
// user_settings'teki varsayılan değerler (signup sırasında DB tarafında
// oluşturulan satır) geçerli olmaya devam eder.

import 'dart:developer';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/models/user_settings_model.dart';
import '../../services/analytics_service.dart';
import '../../services/notification_service.dart';
import 'settings_controller.dart';

class SignupPreferencesController extends GetxController {
  final SettingsController settingsController;

  SignupPreferencesController({required this.settingsController});

  final isRequestingNotificationPermission = false.obs;

  // Kullanıcının bu ekranda yaptığı seçimler (henüz seçim yapmadıysa null —
  // ekran "seçilmedi" durumunu vurgulu gösterebilsin diye).
  final selectedTheme = RxnString();
  final selectedAutoplay = Rxn<bool>();
  final selectedNotifications = Rxn<bool>();
  final selectedVisibility = Rxn<VisibilityOption>();

  @override
  void onInit() {
    super.onInit();
    // Ekran açıldığında mevcut (varsayılan) değerleri önceden işaretli
    // göster ki kullanıcı sıfırdan başlamış hissetmesin.
    final current = settingsController.settings.value;
    if (current != null) {
      selectedTheme.value = current.theme;
      selectedAutoplay.value = current.autoplay;
      // NOT: selectedNotifications kasıtlı olarak önceden doldurulmuyor.
      // Bu adımda tik, YALNIZCA kullanıcı "Bildirimleri Aç"a basıp OS
      // izin dialogunda "Allow" derse görünmeli (bkz. requestNotifications).
    }
    selectedVisibility.value = settingsController.profileVisibility.value;
  }

  // ─── 1) Tema ────────────────────────────────────────────────────────────
  Future<void> chooseTheme(String theme) async {
    selectedTheme.value = theme;
    await settingsController.changeTheme(theme);
  }

  // ─── 2) Otomatik oynatma ────────────────────────────────────────────────
  Future<void> chooseAutoplay(bool autoplay) async {
    final current = settingsController.settings.value;
    if (current == null || current.autoplay == autoplay) {
      selectedAutoplay.value = autoplay;
      return;
    }
    selectedAutoplay.value = autoplay;
    await settingsController.toggleAutoplay();
  }

  // ─── 3) Bildirimler ─────────────────────────────────────────────────────
  /// Tek buton: "Bildirimleri Aç". Basılınca sistem izin dialogu açılır.
  /// - Kullanıcı "Allow" derse: DB'de notifications_enabled=true yazılır,
  ///   seçili (tik) gösterilir, dönüş değeri true olur (ekran bir sonraki
  ///   adıma geçer).
  /// - Kullanıcı "Don't allow" derse: hiçbir ayar değiştirilmez, tik
  ///   gösterilmez, dönüş değeri false olur (ekran aynı adımda kalır —
  ///   kullanıcı isterse "Atla" ile devam eder ya da tekrar dener; OS,
  ///   izin bir kez reddedildikten sonra dialogu tekrar göstermeyebilir,
  ///   bu durumda kullanıcı sistem ayarlarından açmalıdır).
  Future<bool> requestNotifications() async {
    try {
      isRequestingNotificationPermission.value = true;
      final granted = await NotificationService.instance.onUserLogin();

      AnalyticsService.instance.logEvent(
        'signup_preferences_notifications',
        parameters: {'granted': granted ? 1 : 0},
      );

      if (!granted) {
        selectedNotifications.value = false;
        return false;
      }

      selectedNotifications.value = true;
      final current = settingsController.settings.value;
      if (current != null && !current.notificationsEnabled) {
        await settingsController.toggleNotifications();
      }
      return true;
    } catch (e, stacktrace) {
      log(
        'Kayıt sonrası bildirim izni istenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return false;
    } finally {
      isRequestingNotificationPermission.value = false;
    }
  }

  // ─── 4) Profil / Aktivite Görünürlüğü ───────────────────────────────────
  /// SettingsController.changeProfileVisibility hem profiles.profile_visibility
  /// hem de (tavan aşılmışsa) izleme geçmişi/beğeni/favori/yorum
  /// görünürlüklerini aynı anda Supabase'e yazar.
  Future<void> chooseVisibility(VisibilityOption visibility) async {
    selectedVisibility.value = visibility;
    await settingsController.changeProfileVisibility(visibility);
  }

  // ─── Bitiş ──────────────────────────────────────────────────────────────
  /// Kullanıcı son adımı tamamladığında ya da "Atla" dediğinde çağrılır.
  /// Akış, mevcut kayıt sonrası zincirle tutarlı kalsın diye İlgi Alanı
  /// Seçimi ekranına devam eder (o ekran Home'a yönlendirir).
  void finish() {
    AnalyticsService.instance.logEvent('signup_preferences_complete');
    Get.offAllNamed(AppRoutes.interestSelection);
  }

  void skip() {
    AnalyticsService.instance.logEvent('signup_preferences_skipped');
    Get.offAllNamed(AppRoutes.interestSelection);
  }
}
