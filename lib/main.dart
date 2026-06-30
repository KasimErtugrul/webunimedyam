// lib/main.dart

import 'dart:io' as io;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_theme.dart';
import 'data/datasources/local/local_datasource.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/controllers/settings_controller.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

// ─── Background mesaj handler (top-level, sınıf dışı) ─────────────────────
// Uygulama KAPALI iken gelen FCM mesajlarını işler.
// Navigasyon burada yapılmaz; getInitialMessage() ile main akışta yapılır.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
 
  // Sistem bildirimi OS tarafından otomatik gösterilir.
  // Ek işlem gerekmiyorsa boş bırakılır.
}

// ─── main ──────────────────────────────────────────────────────────────────
void main() async {
   if (kDebugMode) {
    io.HttpClient.enableTimelineLogging = true;
  }
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ──────────────────────────────────────────────────────────────
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ── Crashlytics ───────────────────────────────────────────────────────────
  // Flutter framework hatalarını (build/layout vb.) otomatik Crashlytics'e
  // yönlendir. Debug modda Crashlytics raporlamayı kapatıyoruz ki geliştirme
  // sırasındaki hatalar prod istatistiklerini kirletmesin.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // ── Supabase ──────────────────────────────────────────────────────────────
  await Supabase.initialize(
    url:     'https://ftqjpfqzjuthoifkyqgl.supabase.co',
    publishableKey : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0cWpwZnF6anV0aG9pZmt5cWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTM1ODAsImV4cCI6MjA5NDE4OTU4MH0.gkI3QgT7JhPA-IzVQm0805kmpJMhCwhLpcJBYtv6K40',
  );

  // ── Analytics ──────────────────────────────────────────────────────────────
  // Supabase init'ten SONRA çağrılmalı: auth durumunu okuyup auth_status
  // user property'sini set ediyor, sonra her login/logout'ta otomatik günceller.
  await AnalyticsService.instance.initialize();

  // ── Tema ──────────────────────────────────────────────────────────────────
  final prefs      = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme') ?? 'dark';

  await ScreenUtil.ensureScreenSize();

  // ── Dependency Injection ──────────────────────────────────────────────────
  Get.put<SupabaseDataSource>(SupabaseDataSource(), permanent: true);
  Get.put<LocalDataSource>(LocalDataSource(), permanent: true);
  Get.put<AuthRepository>(
    AuthRepository(supabase: Get.find(), local: Get.find()),
    permanent: true,
  );

  await Get.putAsync<SettingsController>(() async {
    final ctrl = SettingsController(
      authRepository: Get.find(),
      supabase:       Get.find(),
    );
    await ctrl.loadSettings();
    return ctrl;
  }, permanent: true);

  // ── Bildirim Servisi ──────────────────────────────────────────────────────
  // İzin ister, token kaydeder, tüm FCM dinleyicilerini kurar.
  await NotificationService.instance.initialize();

  runApp(MyApp(initialTheme: savedTheme));
}

// ─── App Widget ────────────────────────────────────────────────────────────
class MyApp extends StatefulWidget {
  final String initialTheme;
  const MyApp({super.key, required this.initialTheme});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // FIX: Uygulama arka plandan ön plana her geçtiğinde FCM token'ı yenile.
  // Bu sayede:
  //   • Kullanıcı favoriye üniversite ekledikten sonra uygulamayı kapatıp
  //     açtığında (token daha önce DB'de yoksa) bildirim artık ulaşır.
  //   • OS token'ı yenilediğinde (onTokenRefresh dışında) DB güncellenir.
  //   • Cihaz değişikliği / uygulama güncellemesi sonrası token kaybolmaz.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final authRepo = Get.find<AuthRepository>();
      authRepo.onAppResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:      const Size(375, 812),
      minTextAdapt:    true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title:                      'Uni TV',
          debugShowCheckedModeBanner: false,
          theme:                      AppTheme.lightTheme,
          darkTheme:                  AppTheme.darkTheme,
          themeMode: widget.initialTheme == 'light' ? ThemeMode.light : ThemeMode.dark,
          initialRoute: AppRoutes.splash,
          getPages:     AppPages.pages,
          navigatorObservers: [AnalyticsService.instance.observer],
        );
      },
    );
  }
}