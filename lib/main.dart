// lib/main.dart

import 'dart:developer';
import 'dart:io' as io;

import 'package:firebase_core/firebase_core.dart';
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
import 'services/notification_service.dart';

// ─── Background mesaj handler (top-level, sınıf dışı) ─────────────────────
// Uygulama KAPALI iken gelen FCM mesajlarını işler.
// Navigasyon burada yapılmaz; getInitialMessage() ile main akışta yapılır.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('[FCM-BG] Arka planda mesaj alındı: ${message.notification?.title}');
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

  // ── Supabase ──────────────────────────────────────────────────────────────
  await Supabase.initialize(
    url:     'https://ftqjpfqzjuthoifkyqgl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0cWpwZnF6anV0aG9pZmt5cWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTM1ODAsImV4cCI6MjA5NDE4OTU4MH0.gkI3QgT7JhPA-IzVQm0805kmpJMhCwhLpcJBYtv6K40',
  );

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
class MyApp extends StatelessWidget {
  final String initialTheme;
  const MyApp({super.key, required this.initialTheme});

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
          themeMode: initialTheme == 'light' ? ThemeMode.light : ThemeMode.dark,
          initialRoute: AppRoutes.splash,
          getPages:     AppPages.pages,
        );
      },
    );
  }
}