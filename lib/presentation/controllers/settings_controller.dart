// lib/presentation/controllers/settings_controller.dart

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_settings_model.dart';
import '../../services/analytics_service.dart';
import 'auth/session_controller.dart';
import 'profile_controller.dart';

class SettingsController extends GetxService {
  final AuthRepository authRepository;

  SettingsController({required this.authRepository});

  final settings = Rxn<UserSettingsModel>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  /// "Gizli Profil Modu" master switch'i (profiles.profile_visibility).
  /// TASARIM SEMANTİĞİ (TAVAN MODELİ): Profil GİZLİYSE tüm aktiviteler
  /// (izleme geçmişi, beğeniler, favoriler, yorumlar) otomatik gizlidir ve
  /// "Herkese Açık" seçilemez. Profil AÇIKSA her aktivite tek tek
  /// ayarlanabilir. Veritabanı (can_view_activity) aynı tavanı ayrıca
  /// uygular, yani yazım başarısız olsa bile gizli profilden veri sızmaz.
  final profileVisibility = VisibilityOption.public.obs;

  // Ana sayfa görünümü (liste/wheel). `settings.value` girişsiz kullanıcılar
  // için null kalabildiğinden, ekranın her zaman doğru değeri gösterebilmesi
  // için ayrı bir Rx olarak tutulur — kaynağı AuthRepository.getHomeLayout().
  final homeLayout = 'list'.obs;

  /// Son loadSettings() ayarları hesaptan (cache/Supabase) mı aldı, yoksa
  /// varsayılan model mi üretti? Varsayılan modelin teması hesabın tercihi
  /// olmadığı için uygulanmamalıdır.
  bool _loadedFromAccount = false;

  Timer? _settingsDebounce;
  UserSettingsModel? _lastSavedSettings;

  // ─── Null-safe ayar erişimi ──────────────────────────────────────────────

  /// FIX: Eskiden settings.value null ise her setter sessizce return
  /// ediyordu → hiçbir ayar değişemiyordu. Artık null ise varsayılan model
  /// üretilip hemen UI'a verilir; ilk yazmada upsert satırı oluşturur.
  UserSettingsModel _ensureSettings() {
    final s = settings.value;
    if (s != null) return s;
    final fresh = UserSettingsModel(
      userId: authRepository.currentUserId ?? '',
    );
    settings.value = fresh;
    return fresh;
  }

  /// Ana şalter tavanı: profil gizliyken yalnızca "Gizli" seçilebilir.
  bool isAllowed(VisibilityOption option) {
    if (profileVisibility.value == VisibilityOption.private) {
      return option == VisibilityOption.private;
    }
    return true;
  }


 // ═════ Oynatma/bildirim ek tercihleri — MODEL'e bağlı (kalıcı) ═════

  /// [value] model değeridir: 'auto' | '360p' | '480p' | '720p' | '1080p'
  Future<void> changeVideoQuality(String value) async {
    try {
      final c = _ensureSettings();
      await _updateSettings(c.copyWith(videoQuality: value));
    } catch (e, stacktrace) {
      log('Video kalitesi değiştirilirken hata: $e',
          error: e, stackTrace: stacktrace);
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  Future<void> toggleSubtitles([bool? value]) async {
    try {
      final c = _ensureSettings();
      await _updateSettings(c.copyWith(showSubtitles: value ?? !c.showSubtitles));
    } catch (e, stacktrace) {
      log('Altyazı tercihi değiştirilirken hata: $e',
          error: e, stackTrace: stacktrace);
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  Future<void> toggleReduceMotion([bool? value]) async {
    try {
      final c = _ensureSettings();
      await _updateSettings(c.copyWith(reducedMotion: value ?? !c.reducedMotion));
    } catch (e, stacktrace) {
      log('Hareketi azalt değiştirilirken hata: $e',
          error: e, stackTrace: stacktrace);
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  Future<void> toggleNotifyInteractions([bool? value]) async {
    try {
      final c = _ensureSettings();
      await _updateSettings(
        c.copyWith(notifyCommentReplies: value ?? !c.notifyCommentReplies),
      );
    } catch (e, stacktrace) {
      log('Etkileşim bildirimi değiştirilirken hata: $e',
          error: e, stackTrace: stacktrace);
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  // ─── Yükleme ──────────────────────────────────────────────────────────────

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      final loaded = await authRepository.getUserSettings();
      _loadedFromAccount = loaded != null;
      settings.value = loaded;

      // FIX: user_settings satırı hiç oluşmamış kullanıcılar için varsayılan
      // model ile UI'ı besle; ilk toggle'da upsert satırı DB'ye yazar.
      settings.value ??= UserSettingsModel(
        userId: authRepository.currentUserId ?? '',
      );

      await _syncProfileVisibility();

      // FIX: Girişsiz (misafir) ilk açılışta getHomeLayout() 'list' değerini
      // yerel anahtara yazıyordu; sonradan giriş yapılınca yerel değer hesabın
      // gerçek tercihini ezerdi. Hesaptan ayar geldiyse HESAP esas alınır ve
      // yerel anahtar onunla senkronlanır.
      if (loaded != null) {
        homeLayout.value = loaded.homeLayout;
        await authRepository.saveHomeLayoutLocally(loaded.homeLayout);
      } else {
        homeLayout.value = await authRepository.getHomeLayout();
      }

      final loadedTheme = settings.value?.theme;
      if (loadedTheme != null) {
        AnalyticsService.instance.setUserProperty(
          name: 'app_theme',
          value: loadedTheme,
        );
      }
    } catch (e, stacktrace) {
      log(
        'Ayarlar yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ayarlar yüklenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Master switch'in başlangıç değerini doğru oku.
  /// FIX: Eskiden SADECE ProfileController hazırsa okuyordu; profil daha
  /// yüklenmemişse varsayılan (public) kalıyor ve DB'deki gerçek değer
  /// ekrana yansımıyordu. ProfileController hazır değilse repodan okur.
  Future<void> _syncProfileVisibility() async {
    try {
      if (Get.isRegistered<ProfileController>()) {
        final p = Get.find<ProfileController>().profile.value;
        if (p != null) {
          profileVisibility.value = p.profileVisibility;
          return;
        }
      }
      final p = await authRepository.getProfile();
      if (p != null) {
        profileVisibility.value = p.profileVisibility;
      }
    } catch (e, stacktrace) {
      log(
        'Profil görünürlüğü senkronize edilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Görünüm ───────────────────────────────────────────────────────────────

  /// Giriş sonrası hesabın tema tercihini ANINDA uygular. Eskiden tema sadece
  /// main() açılışında okunuyordu; bu yüzden yeni kurulumda (açık tema) giriş
  /// yapan bir kullanıcı, uygulamayı yeniden başlatana kadar hesabındaki
  /// koyu temayı göremiyordu. SessionService.onLogin() çağırır.
  Future<void> applyAccountTheme() async {
    if (!_loadedFromAccount) return;
    final theme = settings.value?.theme;
    if (theme == null) return;
    try {
      await authRepository.saveThemeLocally(theme);
      Get.changeThemeMode(
        theme == 'dark'
            ? ThemeMode.dark
            : theme == 'light'
                ? ThemeMode.light
                : ThemeMode.system,
      );
      AnalyticsService.instance.setUserProperty(name: 'app_theme', value: theme);
    } catch (e, stacktrace) {
      log('Hesap teması uygulanırken hata oluştu: $e',
          error: e, stackTrace: stacktrace);
    }
  }

  Future<void> changeTheme(String theme) async {
    try {
      final current = _ensureSettings();
      await _updateSettings(current.copyWith(theme: theme));
      await authRepository.saveThemeLocally(theme);

      AnalyticsService.instance.logEvent('theme_change', parameters: {
        'theme': theme,
      });
      AnalyticsService.instance.setUserProperty(
        name: 'app_theme',
        value: theme,
      );

      final mode = theme == 'dark'
          ? ThemeMode.dark
          : theme == 'light'
              ? ThemeMode.light
              : ThemeMode.system;
      Get.changeThemeMode(mode);
    } catch (e, stacktrace) {
      log(
        'Tema değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Tema değiştirilemedi.';
    }
  }

  /// Ana sayfa besleme görünümünü değiştirir: 'list' veya 'wheel'.
  /// Önce yerele yazılır (girişsiz kullanıcıda da anında çalışsın), sonra
  /// giriş yapılmışsa Supabase'e senkronize edilir.
  Future<void> changeHomeLayout(String layout) async {
    final old = homeLayout.value;
    homeLayout.value = layout; // Optimistic UI
    try {
      await authRepository.saveHomeLayoutLocally(layout);

      final current = settings.value;
      if (current != null) {
        await _updateSettings(current.copyWith(homeLayout: layout));
      }

      AnalyticsService.instance.logEvent('home_layout_change', parameters: {
        'layout': layout,
      });
    } catch (e, stacktrace) {
      homeLayout.value = old; // Rollback
      log(
        'Ana sayfa görünümü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ana sayfa görünümü değiştirilemedi.';
    }
  }

  // ─── Oynatma ──────────────────────────────────────────────────────────────

  Future<void> toggleAutoplay() async {
    try {
      final c = _ensureSettings();
      await _updateSettings(c.copyWith(autoplay: !c.autoplay));
    } catch (e, stacktrace) {
      log(
        'Otomatik oynatma değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  // ─── Bildirimler ──────────────────────────────────────────────────────────

  Future<void> toggleNotifications() async {
    try {
      final c = _ensureSettings();
      await _updateSettings(
        c.copyWith(notificationsEnabled: !c.notificationsEnabled),
      );
    } catch (e, stacktrace) {
      log(
        'Bildirimler değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  Future<void> toggleNotifyNewVideos() async {
    try {
      final c = _ensureSettings();
      await _updateSettings(c.copyWith(notifyNewVideos: !c.notifyNewVideos));
    } catch (e, stacktrace) {
      log(
        'Yeni video bildirimi değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  // ─── Gizlilik — "Gizli Profil Modu" (master switch) ──────────────────────

  /// profiles.profile_visibility'yi günceller. Gizliye geçişte 4 aktiviteyi
  /// de Gizli'ye yazar (tavan modeli); açığa geçişte dokunmaz, kullanıcı
  /// tek tek açar.
  ///
  /// FIX: `settings.value == null` guard'ı KALDIRILDI — bu ayar user_settings
  /// ile değil profiles tablosuyla ilgilidir; ayar satırı olmasa bile
  /// çalışabilmeli.
    Future<void> changeProfileVisibility(VisibilityOption newVisibility) async {
    final userId = authRepository.currentUserId;
    if (userId == null) {
      errorMessage.value = 'Bu ayar için giriş yapmalısınız.';
      return;
    }

    final oldVisibility = profileVisibility.value;
    profileVisibility.value = newVisibility; // Optimistic UI

    try {
      await authRepository.updateProfileVisibility(userId, newVisibility.value);

      // TAVAN: public→private geçişinde 4 aktiviteyi de Gizli'ye yaz. Ekranda
      // "Herkese Açık" artık seçilemez (ceiling). Yazım başarısız olsa bile
      // veritabanındaki can_view_activity profil kapısı sızıntıyı engeller.
      //
      // `locked != current` (Equatable) sayesinde zaten hepsi private ise
      // hiçbir yazma işlemi yapılmaz — her açılışta yeniden yazmaz.
      if (newVisibility == VisibilityOption.private) {
        final current = _ensureSettings();
        final locked = current.copyWith(
          watchHistoryVisibility: VisibilityOption.private,
          likesVisibility: VisibilityOption.private,
          favoritesVisibility: VisibilityOption.private,
          commentsVisibility: VisibilityOption.private,
        );
        if (locked != current) {
          settings.value = locked; // anında UI
          try {
            // DEBOUNCE'SUZ doğrudan yazım: bu işlem master switch ile aynı
            // işlem parçası sayılır; 800ms'lik timer'a bırakılmamalı.
            await authRepository.updateUserSettings(locked);
            _lastSavedSettings = locked;
          } catch (e2, st2) {
            settings.value = current; // sadece alt ayarları geri al
            log(
              'Aktivite görünürlükleri kilitlenirken hata: $e2',
              error: e2,
              stackTrace: st2,
            );
            // Master switch BAŞARILI olduğundan GERİ ALINMAZ; kullanıcıya
            // gerçek durum bildirilir: profil gizli, aktiviteler hâlâ açık.
            errorMessage.value =
                'Profil gizlendi ancak aktivite ayarları kilitlenemedi. '
                'Aşağıdaki izinleri kontrol edin.';
          }
        }
      }

      // ProfileController varsa senkronize et (repo zaten yerel profil
      // cache'ini tazeliyor).
      if (Get.isRegistered<ProfileController>()) {
        final profileCtrl = Get.find<ProfileController>();
        final existing = profileCtrl.profile.value;
        if (existing != null) {
          profileCtrl.profile.value = existing.copyWith(
            profileVisibility: newVisibility,
          );
        }
      }
    } catch (e, stacktrace) {
      profileVisibility.value = oldVisibility; // Rollback (master)
      log(
        'Profil görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Profil görünürlüğü güncellenemedi.';
    }
  }

  // ─── Gizlilik — Aktivite Görünürlükleri (bağımsız) ────────────────────────

  Future<void> changeWatchHistoryVisibility(VisibilityOption v) async {
    try {
      final c = _ensureSettings();
      await _updateSettings(c.copyWith(watchHistoryVisibility: v));
    } catch (e, stacktrace) {
      log(
        'İzleme geçmişi görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  Future<void> changeLikesVisibility(VisibilityOption v) async {
    try {
      final c = _ensureSettings();
      await _updateSettings(c.copyWith(likesVisibility: v));
    } catch (e, stacktrace) {
      log(
        'Beğeniler görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  Future<void> changeFavoritesVisibility(VisibilityOption v) async {
    try {
      final c = _ensureSettings();
      await _updateSettings(c.copyWith(favoritesVisibility: v));
    } catch (e, stacktrace) {
      log(
        'Favoriler görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

  Future<void> changeCommentsVisibility(VisibilityOption v) async {
    try {
      final c = _ensureSettings();
      await _updateSettings(c.copyWith(commentsVisibility: v));
    } catch (e, stacktrace) {
      log(
        'Yorumlar görünürlüğü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Ayar güncellenemedi.';
    }
  }

// ═════ Önbellek rozeti (tasarım: "124 MB temizle" → "Temizlendi (0 KB)") ═════

  /// Rozet flash durumu: temizleme başarılı olduğunda 2 saniye boyunca
  /// "Temizlendi (0 KB)" gösterir, sonra eski haline döner.
  /// (Tasarım JS'i: tag.textContent = 'Temizlendi (0 KB)'; setTimeout 2000ms)
  final cacheBadgeCleared = false.obs;

  /// clearCache + tasarımdaki rozet davranışı bir arada.
  /// Ekranın "Önbelleği Temizle" satırı bunu çağırır; saf temizleme
  /// gerekiyorsa (başka ekran) `clearCache()` hâlâ mevcut.
  Future<void> clearCacheWithBadge() async {
    await clearCache();
    cacheBadgeCleared.value = true;
    Timer(const Duration(seconds: 2), () => cacheBadgeCleared.value = false);
  }
  
  // ─── Cache ────────────────────────────────────────────────────────────────

  Future<void> clearCache() async {
    try {
      isLoading.value = true;
      await authRepository.clearLocalCache();
      Get.snackbar(
        'Başarılı',
        'Uygulama cache\'i temizlendi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e, stacktrace) {
      log(
        'Cache temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      errorMessage.value = 'Cache temizlenemedi.';
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Çıkış ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      if (Get.isRegistered<SessionController>()) {
        await Get.find<SessionController>().signOut();
      } else {
        await authRepository.signOut();
        Get.offAllNamed('/home');
      }
    } catch (e, stacktrace) {
      log('Çıkış yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      errorMessage.value = 'Çıkış yapılırken hata oluştu.';
    }
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  Future<void> _updateSettings(UserSettingsModel updated) async {
    final old = _lastSavedSettings ?? settings.value;
    settings.value = updated;

    _settingsDebounce?.cancel();
    _settingsDebounce = Timer(const Duration(milliseconds: 800), () async {
      try {
        await authRepository.updateUserSettings(updated);
        _lastSavedSettings = updated;
      } catch (e, stacktrace) {
        settings.value = old;
        log(
          'Ayarlar güncellenirken hata oluştu: $e',
          error: e,
          stackTrace: stacktrace,
        );
        errorMessage.value = 'Ayarlar güncellenemedi.';
      }
    });
  }

  @override
  void onClose() {
    _settingsDebounce?.cancel();
    super.onClose();
  }
}