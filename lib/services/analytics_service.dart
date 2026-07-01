// lib/services/analytics_service.dart

import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Firebase Analytics + Crashlytics için tek noktadan servis.
///
/// Sorumlulukları:
///   1) Auth/misafir ayrımını otomatik takip etmek (Supabase auth state'ini
///      dinleyerek `user_id` ve `auth_status` user property'lerini günceller
///      — başka hiçbir controller'ın bunu manuel set etmesi gerekmez).
///   2) Önemli aksiyonlar için (buton tıklama, video oynatma, paylaşım vb.)
///      tek satırlık event loglama metodları sağlamak.
///   3) Crashlytics'e fatal/non-fatal hata kaydı için tek giriş noktası
///      olmak.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// GetMaterialApp'in `navigatorObservers`'ına eklenecek observer.
  /// Ekran geçişlerini (screen_view) otomatik loglar — manuel
  /// instrumentasyon gerekmez.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─── initialize ────────────────────────────────────────────────────────
  // FIX: auth_status / user_id ayrı ayrı her login/logout noktasında elle
  // set edilmek yerine, burada Supabase'in authStateChanges stream'i
  // dinlenerek tek merkezden, garanti tutarlı şekilde güncelleniyor.
  // Böylece "bir login noktasını güncellemeyi unuttum" riski ortadan kalkar.
  Future<void> initialize() async {
    try {
      // Uygulama açılışında mevcut oturum durumunu hemen yansıt.
      await _applyAuthStatus(Supabase.instance.client.auth.currentUser);

      Supabase.instance.client.auth.onAuthStateChange.listen((state) async {
        await _applyAuthStatus(state.session?.user);
      });
    } catch (e, stacktrace) {
      log(
        'Analytics servisi başlatılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> _applyAuthStatus(User? user) async {
    try {
      await _analytics.setUserId(id: user?.id);
      await _analytics.setUserProperty(
        name: 'auth_status',
        value: user != null ? 'authenticated' : 'guest',
      );
    } catch (e, stacktrace) {
      log(
        'auth_status user property güncellenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Genel amaçlı event loglama ───────────────────────────────────────

  /// Herhangi bir custom event göndermek için genel metod.
  /// Parametre değerleri yalnızca String/num/bool olabilir (GA4 kısıtı).
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e, stacktrace) {
      log(
        'Event loglanırken hata oluştu ($name): $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  // ─── Auth event'leri (GA4 önerilen event isimleriyle) ──────────────────

  Future<void> logSignUp({required String method}) =>
      logEvent('sign_up', parameters: {'method': method});

  Future<void> logLogin({required String method}) =>
      logEvent('login', parameters: {'method': method});

  Future<void> logLogout() => logEvent('logout');

  // ─── İçerik / buton event'leri ──────────────────────────────────────────

  /// Genel buton tıklama event'i. `buttonName` ekran+aksiyon ayırt edecek
  /// şekilde verilmeli, örn: 'home_play_button', 'video_favorite_button'.
  Future<void> logButtonTap(String buttonName, {Map<String, Object>? extra}) =>
      logEvent('button_tap', parameters: {'button_name': buttonName, ...?extra});

  Future<void> logVideoPlay({required String videoId, required String title}) =>
      logEvent('video_play', parameters: {'video_id': videoId, 'video_title': title});

  Future<void> logFavorite({required String videoId, required bool added}) =>
      logEvent(added ? 'add_to_favorites' : 'remove_from_favorites',
          parameters: {'video_id': videoId});

  Future<void> logShare({required String videoId, required String method}) =>
      logEvent('share', parameters: {'content_type': 'video', 'item_id': videoId, 'method': method});

  Future<void> logSearch(String searchTerm) =>
      logEvent('search', parameters: {'search_term': searchTerm});

  // ─── Hata takibi (Crashlytics) ──────────────────────────────────────────

  /// Fatal olmayan (uygulamayı kapatmayan) hataları Crashlytics'e kaydeder.
  /// Aynı zamanda Analytics tarafında da bir "app_error" event'i loglar ki
  /// hata oranını Analytics segmentleriyle (auth/misafir, ülke, cihaz vb.)
  /// birlikte de görebilelim.
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(error, stackTrace, reason: reason, fatal: fatal);
      await logEvent('app_error', parameters: {
        'error': error.toString(),
        if (reason != null) 'reason': reason,
      });
    } catch (e, st) {
      log('Hata Crashlytics\'e kaydedilirken sorun oluştu: $e', error: e, stackTrace: st);
    }
  }
}