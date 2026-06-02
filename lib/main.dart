// lib/main.dart

import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

// ─── Background mesaj handler ─────────────────────────────────────────────
// Bu fonksiyon top-level olmalı (sınıf dışı) ve Firebase.initializeApp
// çağrısı içermeli.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('[FCM] Arka planda mesaj: ${message.notification?.title}');
  // Ek işlem gerekmiyorsa boş bırakılabilir; sistem bildirimi otomatik gösterilir.
}

// ─── main ─────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==================== Firebase ====================
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ==================== Supabase ====================
  await Supabase.initialize(
    url: 'https://ftqjpfqzjuthoifkyqgl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0cWpwZnF6anV0aG9pZmt5cWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTM1ODAsImV4cCI6MjA5NDE4OTU4MH0.gkI3QgT7JhPA-IzVQm0805kmpJMhCwhLpcJBYtv6K40',
  );

  // ==================== Diğer Ayarlar ====================
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme') ?? 'dark';

  await ScreenUtil.ensureScreenSize();

  // ==================== Dependency Injection ====================
  Get.put<SupabaseDataSource>(SupabaseDataSource(), permanent: true);
  Get.put<LocalDataSource>(LocalDataSource(), permanent: true);
  Get.put<AuthRepository>(
    AuthRepository(supabase: Get.find(), local: Get.find()),
    permanent: true,
  );

  await Get.putAsync<SettingsController>(() async {
    final ctrl = SettingsController(
      authRepository: Get.find(),
      supabase: Get.find(),
    );
    await ctrl.loadSettings();
    return ctrl;
  }, permanent: true);

  // ==================== Bildirim Servisi ====================
  // FCM izni isteme, token kaydetme ve dinleyicileri kur.
  await NotificationService.instance.initialize();

  runApp(MyApp(initialTheme: savedTheme));
}

// ─── App Widget ───────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  final String initialTheme;
  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'UniTV',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: initialTheme == 'light' ? ThemeMode.light : ThemeMode.dark,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
        );
      },
    );
  }
}
