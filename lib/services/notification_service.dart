import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/bindings/home_binding.dart';
import '../app/routes/app_routes.dart';
import '../data/datasources/remote/supabase_datasource.dart';
import '../presentation/screens/home/home_screen.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _supabase  = Supabase.instance.client;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // ÖNEMLİ: Bu kanal id'si, `send-university-notification` edge function'ında
  // gönderilen `android.notification.channel_id` ile TAM AYNI olmak zorunda.
  // Android'de bir bildirim kanalının sesi, kanal İLK OLUŞTURULDUĞUNDA kilitlenir;
  // sonradan aynı id ile tekrar oluşturmaya çalışmak sesi değiştirmez. Eğer bu
  // kanal cihazda zaten (eski/varsayılan sesle) var olarak oluşturulmuşsa, yeni
  // sesi görmek için uygulamayı cihazdan kaldırıp yeniden kurmak (veya kanal
  // id'sini değiştirmek) gerekir.
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'Önemli Bildirimler';
  static const String _channelDescription =
      'Üniversite videoları ve canlı yayın bildirimleri';
  // res/raw/notification_sound.mp3 -> uzantısız verilir
  static const String _soundResourceName = 'notification_sound';

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
      await _initLocalNotifications();

      // FIX: setForegroundNotificationPresentationOptions, iOS'a ait bir
      // API'dir ve uygulama ön plandayken FCM'in kendi sistem bildirimini
      // göstermesini sağlar. Android'de ön plandaki mesajlar zaten sistem
      // tarafında OTOMATİK gösterilmez — bu yüzden ses/görsel bildirimi
      // Android'de _handleForegroundMessage içinde flutter_local_notifications
      // ile elle tetikliyoruz (bkz. aşağısı).
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

  // ─── Local Notifications Kurulumu ────────────────────────────────────────

  // FIX: Android'de FCM, uygulama ÖN PLANDAYKEN gelen mesajlar için sistem
  // bildirimini OTOMATİK göstermez (bu davranış sadece arka plan/kapalı
  // durumda geçerlidir) — bu yüzden ön planda hem görünür bir bildirim hem
  // de özel sesin çalması için flutter_local_notifications ile elle bir
  // bildirim gösteriyoruz. Arka plan/kapalı durumda ise Android'in kendisi
  // FCM payload'ındaki `android.notification.channel_id` ile eşleşen
  // kanalın sesini otomatik çalar — bunun için burada oluşturduğumuz kanal
  // id'sinin (`_channelId`) backend'deki (`send-university-notification`
  // edge function) ile bire bir aynı olması gerekiyor.
  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          _routeByType(data);
        } catch (e, stacktrace) {
          log('Local bildirim payload çözümlenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
        }
      },
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(_soundResourceName),
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // ─── Mesaj İşleyiciler ────────────────────────────────────────────────────

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      final title = message.notification?.title ?? '';
      final body  = message.notification?.body  ?? '';
      if (title.isEmpty && body.isEmpty) return;

      // Sistem bildirimi + özel ses (Android'de ön planda otomatik gelmiyor).
      if (Platform.isAndroid) {
        await _localNotifications.show(
          id: message.hashCode,
          title: title,
          body: body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              sound: RawResourceAndroidNotificationSound(_soundResourceName),
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }

      // Uygulama içi görünür geri bildirim (snackbar) — sistem bildirimine ek.
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
    await _routeByType(message.data);
  }

  Future<void> _routeByType(Map<String, dynamic> data) async {
    try {
      final type = data['type'] as String? ?? '';

      switch (type) {
        case 'new_university_video':
          await _navigateToPlayer(data);
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
      
      // BUG FIX: Önceden burada Get.offAllNamed(AppRoutes.home) çağrılıp
      // ardından 300ms'lik yapay bir gecikme bekleniyordu — bu süre
      // boyunca ana sayfa gerçekten ekranda görünüyordu, kullanıcı
      // bildirime bastığında "önce ana sayfa, sonra player" açılıyormuş
      // gibi algılıyordu. Artık ana sayfaya geçiş ANİMASYONSUZ yapılıyor
      // (görünmeden, ama yine de geri tuşu için yığının altına
      // yerleşiyor) ve hemen ardından player normal animasyonla açılıyor.
      //
      // BUG FIX 2 (kök neden): `Navigator.pushAndRemoveUntil` (Get.offAll'ın
      // altında kullandığı mekanizma) döndürdüğü Future, rota PUSH
      // edildiğinde DEĞİL, o rota daha sonra POP edildiğinde tamamlanır.
      // Home ekranı hiçbir zaman pop edilmediği için, bu Future'ı `await`
      // etmek akışı burada SONSUZA KADAR bekletiyordu — Get.toNamed()
      // satırına asla ulaşılamıyordu (deep_link_service.dart'ta tespit
      // edilen sorunun birebir aynısı). Çözüm: awaitlemeyip bir sonraki
      // frame'i beklemek.
      Get.offAll(
        () => const HomeScreen(),
        binding: HomeBinding(),
        routeName: AppRoutes.home,
        transition: Transition.noTransition,
        duration: Duration.zero,
      );

      await WidgetsBinding.instance.endOfFrame;

      Get.toNamed(AppRoutes.player, arguments: video, parameters: {'videoId': video.videoId});
    } catch (e, stacktrace) {
      log('Bildirimden oynatıcıya yönlendirilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
    }
  }

}