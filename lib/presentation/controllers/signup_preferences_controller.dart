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
//   5) Takip edilecek üniversiteler (0..N seçim, zorunlu değil)
//
// 1-4 numaralı seçimler yapıldığı an SettingsController üzerinden hem
// uygulama state'i (Rx alanlar, tema anında değişir) hem de Supabase
// (user_settings / profiles tabloları) güncellenir — SettingsController
// zaten bunu optimistic update + debounce ile yapıyor, burada tekrar
// yazılmıyor.
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
import '../../presentation/screens/signup_preferences/utils/signup_universities.dart';
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

  // ─── 5) Üniversite seçimi (ADIM 5) ─────────────────────────────────────
  /// Kullanıcının seçtiği üniversite id'leri. Seçim ZORUNLU DEĞİLDİR;
  /// "Bitir" boş listeyle de çalışır (tasarımdaki davranışla aynı).
  final selectedUniversityIds = RxSet<String>();

  /// Adım 5'teki canlı arama filtresi ("Üniversite adı veya şehir ara...").
  final universitySearchQuery = RxString('');

  /// ADIM 5'in liste kaynağı — TÜM üniversiteler.
  ///
  /// Varsayılan: kSignupUniversities (demo/fallback liste). Gerçek veri
  /// kaynağınızı (repository/API/Supabase view) bağlamak için DI noktasında
  /// ya da ekran açılmadan önce setUniversities() çağırın:
  ///
  ///   controller.setUniversities(
  ///     universityRepository.getAll().map((u) => SignupUniversity(
  ///       id: u.id,
  ///       shortName: u.abbreviation,
  ///       fullName: u.name,
  ///       city: u.city,
  ///       isPrivate: u.type == 'private',
  ///       emblemUrl: u.logoUrl, // null → baş harf avatarı çizilir
  ///     )).toList(),
  ///   );
  ///
  /// Liste alfabetik OLMAYABİLİR; UniversityStep görüntülerken Türkçe
  /// duyarlı sıralar (compareTr) — burada sıralama yükü yoktur.
  final RxList<SignupUniversity> universities =
      kSignupUniversities.toList().obs;

  /// Gerçek veri kaynağını bağlamak için tek giriş noktası.
  void setUniversities(List<SignupUniversity> list) =>
      universities.assignAll(list);

  /// Sayaç satırındaki "N Üniversite Seçildi" değeri için kolay erişim.
  int get selectedUniversityCount => selectedUniversityIds.length;

  bool isUniversitySelected(String id) => selectedUniversityIds.contains(id);

  void toggleUniversity(String id) {
    if (selectedUniversityIds.contains(id)) {
      selectedUniversityIds.remove(id);
    } else {
      selectedUniversityIds.add(id);
    }
  }

  /// "Seçimi Temizle" butonu.
  void clearUniversitySelection() => selectedUniversityIds.clear();

  /// "Tümünü Seç" butonu — ARTIK aktif liste kaynağından (universities)
  /// seçer; statik 8'lik demo listesiyle sınırlı DEĞİLDİR.
  /// (200+ üniversitede de doğrudur: select-all, görünen/araştırılmayan
  /// her kayıt dahil tümünü işaretler — JS davranışıyla aynı.)
  void selectAllUniversities() =>
      selectedUniversityIds.assignAll(universities.map((u) => u.id));

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

    // Üniversite listesi: DI'ı aşan bir veri servisiniz varsa burada da
    // yüklenebilir (repository injection'ı constructor'a eklemek isterseniz):
    //
    //   _loadUniversities(); // async → await gerekmez, UI reaktif dolar
    //
    // Üniversite seçimi: mevcut takipler varsa önceden işaretle.
    // TODO: SettingsController / profile servisinde takip listesine erişim
    // açıldığında burada doldurun, örn.:
    //   selectedUniversityIds.assignAll(settingsController.followedUniversities);
    // (Şimdilik liste boş başlar — "Hiç seçmeden de devam edebilirsin"
    // davranışıyla uyumlu.)
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
    // Üniversite tercihlerini analytics'e yaz (persist hook için bkz. aşağı).
    AnalyticsService.instance.logEvent(
      'signup_preferences_universities',
      parameters: {'count': selectedUniversityIds.length},
    );

    // TODO: Takip listesi servisi hazır olduğunda buradan kaydedin:
    //   await settingsController.saveFollowedUniversities(
    //     selectedUniversityIds.toList(),
    //   );

    AnalyticsService.instance.logEvent('signup_preferences_complete');
    Get.offAllNamed(AppRoutes.interestSelection);
  }

  void skip() {
    AnalyticsService.instance.logEvent('signup_preferences_skipped');
    Get.offAllNamed(AppRoutes.interestSelection);
  }
}