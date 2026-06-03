// lib/services/notification_service.dart
//
// Bildirim akışı:
//   1. FCM izni istenir
//   2. Token → Supabase fcm_tokens tablosuna kaydedilir
//   3. Token yenilenince otomatik güncellenir
//   4. Foreground → snackbar (tıklanınca player'a gider)
//   5. Background tap → player'a gider
//   6. Terminated tap → uygulama yüklendikten sonra player'a gider
//
// Navigasyon stratejisi:
//   • Home stack'e base olarak konur
//   • Player onun üstüne açılır
//   • Geri tuşu → Home (kullanıcı normal girmiş gibi hisseder)

import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/routes/app_routes.dart';
import '../data/datasources/remote/supabase_datasource.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _supabase   = Supabase.instance.client;

  // ─── initialize ──────────────────────────────────────────────────────────
  /// main() içinde `await NotificationService.instance.initialize()` ile çağır.
  Future<void> initialize() async {
    // 1. İzin iste
    final settings = await _messaging.requestPermission(
      alert:       true,
      badge:       true,
      sound:       true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('[FCM] Bildirim izni reddedildi.');
      return;
    }
    log('[FCM] Bildirim izni: ${settings.authorizationStatus}');

    // 2. iOS → APNs token hazır olsun
    if (Platform.isIOS) {
      await _messaging.getAPNSToken();
    }

    // 3. Foreground bildirim gösterimi (iOS için şart)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Giriş yapmışsa token'ı kaydet
    await _saveTokenIfLoggedIn();

    // 5. Token yenilenince güncelle
    _messaging.onTokenRefresh.listen((newToken) async {
      log('[FCM] Token yenilendi → Supabase güncelleniyor…');
      await _upsertToken(newToken);
    });

    // 6. Foreground mesaj dinleyicisi
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 7. Arka planda bildirime tıklanınca
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 8. Uygulama KAPALI iken bildirime tıklanmış → başlatma mesajı
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Widget ağacı hazır olunca yönlendir
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
      });
    }
  }

  // ─── Auth Hooks ──────────────────────────────────────────────────────────

  /// Login sonrası çağır → token'ı o anki kullanıcıya bağlar.
  Future<void> onUserLogin() async => _saveTokenIfLoggedIn();

  /// Logout ÖNCE çağır → token'ı DB'den sil.
  Future<void> onUserLogout() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await _supabase
          .from('fcm_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('token', token);

      log('[FCM] Token silindi (logout).');
    } catch (e) {
      log('[FCM] Token silinirken hata: $e');
    }
  }

  // ─── Token Yönetimi ───────────────────────────────────────────────────────

  Future<void> _saveTokenIfLoggedIn() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      log('[FCM] Kullanıcı giriş yapmamış → token kaydedilmedi.');
      return;
    }

    try {
      final token = await _messaging.getToken();
      if (token == null) {
        log('[FCM] FCM token alınamadı.');
        return;
      }
      await _upsertToken(token);
    } catch (e) {
      log('[FCM] Token kaydedilirken hata: $e');
    }
  }

  Future<void> _upsertToken(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final platform = Platform.isIOS ? 'ios' : 'android';

    try {
      await _supabase.from('fcm_tokens').upsert(
        {
          'user_id':    userId,
          'token':      token,
          'platform':   platform,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
      log('[FCM] Token kaydedildi (platform: $platform).');
    } catch (e) {
      log('[FCM] Token upsert hatası: $e');
    }
  }

  // ─── Mesaj İşleyiciler ────────────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    log('[FCM] Foreground mesaj: ${message.notification?.title}');

    final title = message.notification?.title ?? '';
    final body  = message.notification?.body  ?? '';

    if (title.isEmpty && body.isEmpty) return;

    // Snackbar'a tıklayınca da videoya git
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      duration:      const Duration(seconds: 5),
      margin:        const EdgeInsets.all(12),
      backgroundColor: Get.theme.colorScheme.surfaceContainerHighest.withOpacity(0.95),
      colorText:     Get.theme.colorScheme.onSurface,
      onTap:         (_) => _handleNotificationTap(message),
    );
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    log('[FCM] Bildirime tıklandı: ${message.data}');

    final type    = message.data['type']     ?? '';
    final videoId = message.data['video_id'] as String?;

    if (type != 'new_university_video' || videoId == null || videoId.isEmpty) {
      log('[FCM] Geçersiz bildirim verisi → navigasyon iptal.');
      return;
    }

    try {
      // Supabase'den video detayını çek
      final ds    = Get.find<SupabaseDataSource>();
      final video = await ds.getVideoById(videoId);

      if (video == null) {
        log('[FCM] Video bulunamadı: $videoId');
        return;
      }

      // Önce stack'i temizle, Home'u base yap; ardından Player'ı aç.
      // Böylece geri tuşu Home'a döner (kullanıcı normal girmiş gibi hisseder).
      Get.offAllNamed(AppRoutes.home);

      // Kısa gecikme: Home binding'in tamamlanmasını bekle
      await Future.delayed(const Duration(milliseconds: 300));
      Get.toNamed(AppRoutes.player, arguments: video);

      log('[FCM] Navigasyon tamamlandı → video: ${video.title}');
    } catch (e) {
      log('[FCM] Bildirim navigasyonu hatası: $e');
    }
  }
}