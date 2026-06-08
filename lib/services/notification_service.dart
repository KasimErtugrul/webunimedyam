
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
  final _supabase  = Supabase.instance.client;

  // ─── initialize ──────────────────────────────────────────────────────────

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true, provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('[FCM] Bildirim izni reddedildi.');
      return;
    }
    log('[FCM] Bildirim izni: ${settings.authorizationStatus}');

    if (Platform.isIOS) await _messaging.getAPNSToken();

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    await _saveTokenIfLoggedIn();

    _messaging.onTokenRefresh.listen((newToken) async {
      log('[FCM] Token yenilendi → Supabase güncelleniyor…');
      await _upsertToken(newToken);
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
      });
    }
  }

  // ─── Auth Hooks ──────────────────────────────────────────────────────────

  Future<void> onUserLogin()  async => _saveTokenIfLoggedIn();

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
    if (userId == null) return;
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
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

    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(12),
      backgroundColor:
          Get.theme.colorScheme.surfaceContainerHighest.withOpacity(0.95),
      colorText: Get.theme.colorScheme.onSurface,
      onTap: (_) => _handleNotificationTap(message),
    );
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    log('[FCM] Bildirime tıklandı: ${message.data}');
    final type = message.data['type'] as String? ?? '';

    switch (type) {
      case 'new_university_video':
        await _navigateToPlayer(message.data);
        break;
      case 'follow_request':
      case 'follow_accepted':
      case 'follow_rejected':
        await _navigateToNotifications();
        break;
      default:
        log('[FCM] Bilinmeyen bildirim tipi: $type');
    }
  }

  // ─── Navigasyon Yardımcıları ──────────────────────────────────────────────

  Future<void> _navigateToPlayer(Map<String, dynamic> data) async {
    final videoId = data['video_id'] as String?;
    if (videoId == null || videoId.isEmpty) return;
    try {
      final ds    = Get.find<SupabaseDataSource>();
      final video = await ds.getVideoById(videoId);
      if (video == null) { log('[FCM] Video bulunamadı: $videoId'); return; }
      Get.offAllNamed(AppRoutes.home);
      await Future.delayed(const Duration(milliseconds: 300));
      Get.toNamed(AppRoutes.player, arguments: video,parameters: {'videoId': video.videoId},);
      log('[FCM] → Player: ${video.title}');
    } catch (e) {
      log('[FCM] Player navigasyon hatası: $e');
    }
  }

  Future<void> _navigateToNotifications() async {
    try {
      // Uygulama açıksa direkt git; yoksa Home üzerinden aç
      if (Get.currentRoute == AppRoutes.notifications) return;
      if (Get.currentRoute == AppRoutes.home) {
        Get.toNamed(AppRoutes.notifications);
      } else {
        Get.offAllNamed(AppRoutes.home);
        await Future.delayed(const Duration(milliseconds: 300));
        Get.toNamed(AppRoutes.notifications);
      }
      log('[FCM] → Notifications');
    } catch (e) {
      log('[FCM] Notifications navigasyon hatası: $e');
    }
  }
}
