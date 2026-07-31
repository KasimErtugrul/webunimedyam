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

  // FIX: Bu metod artık bildirim İZNİ İSTEMİYOR. Önceden burada
  // requestPermission() çağrılıyordu — bu da uygulama ilk açıldığı an,
  // kullanıcı login olmadan/hiç hesabı olmadan, hatta context bile
  // görmeden Android'in "bir kerelik" izin dialogunu harcıyordu.
  // (_saveTokenIfLoggedIn() zaten userId == null ise hiçbir şey
  // yapmıyordu, yani o izin isteme anı tamamen anlamsızdı.)
  //
  // Artık initialize() sadece dinleyicileri kurar; gerçek izin isteme
  // ve token kaydı, kullanıcı başarıyla giriş yaptığında onUserLogin()
  // içinde yapılır.
  Future<void> initialize() async {
    try {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );

      _messaging.onTokenRefresh.listen((newToken) async {
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

      // Kullanıcı uygulamayı kapatıp açtığında (login session zaten
      // varsa) izin durumu hâlâ "authorized" ise token'ı tazelemek için
      // dene; izin daha önce hiç istenmediyse/reddedildiyse burada
      // sessizce hiçbir şey yapmaz (requestPermission çağrılmıyor).
      final current = await _messaging.getNotificationSettings();
      if (current.authorizationStatus == AuthorizationStatus.authorized ||
          current.authorizationStatus == AuthorizationStatus.provisional) {
        if (Platform.isIOS) await _messaging.getAPNSToken();
        await _saveTokenIfLoggedIn();
      }
    } catch (e, stacktrace) {
      log('Bildirim servisi başlatılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  // ─── Auth Hooks ──────────────────────────────────────────────────────────

  // FIX: İzin isteme artık burada — kullanıcı gerçekten giriş yaptığı an.
  // Böylece Android'in tek seferlik sistem dialogu, kullanıcının
  // uygulamayla niye ilgisi olduğunu bildiği bir anda gösteriliyor.
  // FIX: İzin isteme artık burada — kullanıcı gerçekten giriş yaptığı an.
  // Böylece Android'in tek seferlik sistem dialogu, kullanıcının
  // uygulamayla niye ilgisi olduğunu bildiği bir anda gösteriliyor.
  //
  // Dönüş değeri: sistem izni verildi/provisional ise true, reddedildiyse
  // (denied) false. Çağıran taraf (örn. SignupPreferencesController) bu
  // sonuca göre UI'da tik gösterip göstermeyeceğine karar verebilir.
  Future<bool> onUserLogin() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true, badge: true, sound: true, provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return false;
      }

      if (Platform.isIOS) await _messaging.getAPNSToken();

      await _saveTokenIfLoggedIn();
      return true;
    } catch (e, stacktrace) {
      log('Kullanıcı girişinde FCM token kaydedilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      return false;
    }
  }

  Future<void> onUserLogout() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      final token = await _messaging.getToken();
      if (token == null) return;
      await _supabase
          .from('fcm_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('token', token);
    } catch (e, stacktrace) {
      log('Kullanıcı çıkışında FCM token silinirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  // ─── Token Yönetimi ───────────────────────────────────────────────────────

  Future<void> _saveTokenIfLoggedIn() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      final token = await _messaging.getToken();
      if (token == null) return;
      await _upsertToken(token);
    } catch (e, stacktrace) {
      log('FCM token kaydedilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  // FIX: Eskiden doğrudan upsert kullanılıyordu — bu, aynı token'ın (cihazın)
  // önceki sahibine ait satırını hiç kontrol etmiyordu. Kullanıcı logout
  // yapmadan cihazdan çıkarsa (uygulamayı silme, oturum sonlanması vb.) eski
  // kullanıcının satırı tabloda kalıyordu; aynı cihazda başka biri giriş
  // yapınca artık aynı token için 2 kullanıcı olabiliyordu — bu da eski
  // kullanıcının bildirimlerinin yeni kullanıcının cihazına gitmesi riski
  // taşıyordu. claim_fcm_token RPC'si, token'ı devralırken eski sahibinin
  // satırını DB tarafında atomik olarak siliyor.
  Future<void> _upsertToken(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _supabase.rpc('claim_fcm_token', params: {
        'p_token': token,
        'p_platform': platform,
      });
    } catch (e, stacktrace) {
      log('FCM token güncellenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  // FIX: ConnectivityService, internet OFF → ON geçişini yakaladığında bu
  // metodu çağırır. Bağlantı yokken sessizce başarısız olmuş olabilecek
  // token güncellemesini, internet geri gelir gelmez tekrar dener.
  // Kullanıcı login değilse _saveTokenIfLoggedIn zaten no-op olarak çıkar,
  // yani her bağlantı geldiğinde gereksiz bir istek atılmaz.
  Future<void> retryTokenSyncIfNeeded() async {
    await _saveTokenIfLoggedIn();
  }

  // ─── Mesaj İşleyiciler ────────────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    try {
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
            Get.theme.colorScheme.surfaceContainerHighest.withValues(alpha:0.95),
        colorText: Get.theme.colorScheme.onSurface,
        onTap: (_) => _handleNotificationTap(message),
      );
    } catch (e, stacktrace) {
      log('Ön plan bildirimi işlenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    try {
      final type = message.data['type'] as String? ?? '';

      switch (type) {
        case 'new_university_video':
          await _navigateToPlayer(message.data);
          break;
        default:
          break;
      }
    } catch (e, stacktrace) {
      log('Bildirim tıklanırken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

  // ─── Navigasyon Yardımcıları ──────────────────────────────────────────────

  Future<void> _navigateToPlayer(Map<String, dynamic> data) async {
    try {
      final videoId = data['video_id'] as String?;
      if (videoId == null || videoId.isEmpty) return;
      
      final ds = Get.find<SupabaseDataSource>();
      final video = await ds.getVideoById(videoId);
      if (video == null) return;
      
      Get.offAllNamed(AppRoutes.home);
      await Future.delayed(const Duration(milliseconds: 300));
      Get.toNamed(AppRoutes.player, arguments: video, parameters: {'videoId': video.videoId});
    } catch (e, stacktrace) {
      log('Bildirimden oynatıcıya yönlendirilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

}