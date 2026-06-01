// lib/services/notification_service.dart
//
// Bu servis:
//  1. Firebase Messaging izni ister
//  2. FCM token'ını alır ve Supabase'e kaydeder
//  3. Token yenilendiğinde otomatik günceller
//  4. Foreground / background / terminated bildirimleri dinler
//  5. Bildirime tıklandığında ilgili üniversite sayfasına yönlendirir

// Eğer kullanıcı giriş yapmamışsa token kaydedilmez, giriş yapınca kaydedilir, çıkış yapınca silinir.

import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;

  // ─── Başlat ─────────────────────────────────────────────────────────────

  /// main() içinde await ile çağrılmalı.
  Future<void> initialize() async {
    // 1. İzin iste
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('[FCM] Kullanıcı bildirim iznini reddetti.');
      return;
    }

    log('[FCM] Bildirim izni: ${settings.authorizationStatus}');

    // 2. iOS için APNs token'ının hazır olmasını bekle
    if (Platform.isIOS) {
      await _messaging.getAPNSToken();
    }

    // 3. Foreground bildirim gösterimini etkinleştir
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Token'ı kaydet (kullanıcı giriş yapmışsa)
    await _saveTokenIfLoggedIn();

    // 5. Token yenilenince güncelle
    _messaging.onTokenRefresh.listen((newToken) async {
      log('[FCM] Token yenilendi, Supabase güncelleniyor…');
      await _upsertToken(newToken);
    });

    // 6. Foreground mesaj dinleyicisi
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 7. Arka planda bildirime tıklanınca
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 8. Uygulama kapalıyken tıklanmış bildirimi işle
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Uygulama tam yüklenince yönlendir
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
      });
    }
  }

  // ─── Auth Durumu Değişince Çağır ────────────────────────────────────────

  /// Login sonrası çağır: token'ı o anki kullanıcıya bağlar.
  Future<void> onUserLogin() async {
    await _saveTokenIfLoggedIn();
  }

  /// Logout öncesi çağır: token'ı DB'den sil.
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

  // ─── Token Kayıt ────────────────────────────────────────────────────────

  Future<void> _saveTokenIfLoggedIn() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      log('[FCM] Kullanıcı giriş yapmamış, token kaydedilmedi.');
      return;
    }

    try {
      final token = await _messaging.getToken();
      if (token == null) {
        log('[FCM] Token alınamadı.');
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
      log('[FCM] Token Supabase\'e kaydedildi (platform: $platform).');
    } catch (e) {
      log('[FCM] Token upsert hatası: $e');
    }
  }

  // ─── Mesaj İşleyiciler ──────────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    log('[FCM] Foreground mesaj: ${message.notification?.title}');

    // Uygulama açıkken GetX snackbar göster
    final title = message.notification?.title ?? '';
    final body  = message.notification?.body  ?? '';

    if (title.isEmpty && body.isEmpty) return;

    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      onTap: (_) => _handleNotificationTap(message),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    log('[FCM] Bildirime tıklandı: ${message.data}');

    final type          = message.data['type'] ?? '';
    final universityId  = message.data['university_id'];

    if (type == 'new_university_video' && universityId != null) {
      final id = int.tryParse(universityId);
      if (id != null) {
        // Üniversite detay sayfasına yönlendir
        // AppRoutes.universityDetail'in argüman olarak int aldığını varsayıyoruz
        Get.toNamed('/university-detail', arguments: id);
      }
    }
  }
}