// lib/main.dart

import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/themes/app_theme.dart';
import 'core/app_scroll_behavior.dart';
import 'core/constants/firebase_web_options.dart';
import 'data/datasources/local/app_cache_box.dart';
import 'data/datasources/local/local_datasource.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/controllers/home/home_controller.dart';
import 'presentation/controllers/settings_controller.dart';
import 'services/connectivity_service.dart';
import 'services/deep_link_service.dart';
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
  // dart:io API'leri tarayıcıda çalışmaz (runtime'da UnsupportedError fırlatır);
  // web'de timeline logging hiç gerekmediği için sadece mobil platformlarda açılır.
  if (kDebugMode && !kIsWeb) {
    io.HttpClient.enableTimelineLogging = true;
  }
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase ──────────────────────────────────────────────────────────────
  // Mobil platformlarda options verilmez (Android: google-services.json,
  // iOS: GoogleService-Info.plist üzerinden SDK kendi çözümler). Web'de
  // ise options ZORUNLUDUR — firebase_web_options.dart'tan alınır.
  await Firebase.initializeApp(
    options: kIsWeb ? FirebaseWebOptions.current : null,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await ConnectivityService.init();

  // ── Supabase ──────────────────────────────────────────────────────────────
  await Supabase.initialize(
    url: 'https://ftqjpfqzjuthoifkyqgl.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0cWpwZnF6anV0aG9pZmt5cWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTM1ODAsImV4cCI6MjA5NDE4OTU4MH0.gkI3QgT7JhPA-IzVQm0805kmpJMhCwhLpcJBYtv6K40',
  );

  // ── Hive (local cache) ────────────────────────────────────────────────────
  // NOT: SharedPreferences'tan geçiş — tüm local cache tek bir Hive box'ında
  // tutuluyor. Box uygulama boyunca açık kalır (main dışında bir daha
  // Hive.openBox çağrılmaz), diğer katmanlar AppCacheBox.instance ile
  // senkron erişir.
  await Hive.initFlutter();
  await Hive.openBox(AppCacheBox.name);

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
      //supabase: Get.find(),
    );
    await ctrl.loadSettings();
    return ctrl;
  }, permanent: true);

  // ── Tema ──────────────────────────────────────────────────────────────────
  // BUG FIX: Önceden tema, SettingsController.loadSettings() TAMAMLANMADAN
  // ÖNCE doğrudan yerel Hive cache'inden okunuyordu. Supabase'teki
  // `user_settings.theme` değeri (ör. başka bir cihazda "açık" yapılmış)
  // ile yerel cache senkron değilse, kullanıcı Ayarlar ekranında "Açık"
  // yazdığını görse bile uygulama yerel cache'teki eski değere (ör. "dark")
  // göre açılmaya devam ediyordu. Ayrıca "Cache'i temizle" butonu bu
  // `theme` anahtarını silmediği için (bkz. LocalDataSource.clearCache)
  // sorun cache temizlemeyle de düzelmiyordu.
  //
  // Artık loadSettings() bittikten SONRA, kullanıcı giriş yapmışsa
  // Supabase'ten gelen değeri esas alıyoruz ve yerel cache'i de onunla
  // senkronize ediyoruz. Giriş yapılmamışsa (settings.value.theme null)
  // yerel cache'e, o da yoksa 'light'a düşüyoruz.
  final settingsCtrl = Get.find<SettingsController>();
  final remoteTheme = settingsCtrl.settings.value?.theme;
  final savedTheme =
      remoteTheme ?? (AppCacheBox.instance.get('theme') as String?) ?? 'light';
  if (remoteTheme != null) {
    await Get.find<AuthRepository>().saveThemeLocally(remoteTheme);
  }

  // ── Bildirim Servisi ──────────────────────────────────────────────────────
  // İzin ister, token kaydeder, tüm FCM dinleyicilerini kurar.
  await NotificationService.instance.initialize();

  // ── Başlangıç rotası ────────────────────────────────────────────────────
  // BUG FIX: Önceden ayrı bir SplashScreen vardı (2sn yapay bekleme + spinner),
  // native açılış ekranı (uygulama logosu) kaybolduktan sonra bile kullanıcı
  // bir de Flutter tarafında boş bir splash görüyordu. Artık onboarding
  // durumunu main() içinde (native logo hâlâ ekrandayken) kontrol edip
  // uygulamayı doğrudan doğru sayfada açıyoruz — native logo ekranından
  // sonra ayrı bir splash geçişi yok.
  String initialRoute;
  try {
    // WEB: tanıtım (onboarding) akışı web sitesinde gösterilmez — ziyaretçi
    // doğrudan ana sayfada karşılanır. Mobil akış aynen korunur.
    final onboardingCompleted =
        kIsWeb || await Get.find<AuthRepository>().isOnboardingCompleted();
    initialRoute = onboardingCompleted ? AppRoutes.home : AppRoutes.onboarding;
  } catch (e, stacktrace) {
    // Fail-safe: bir şey ters giderse kullanıcıyı boş ekranda bırakma, Home'a gönder.
    log(
      'Başlangıç rotası belirlenirken hata oluştu: $e',
      error: e,
      stackTrace: stacktrace,
    );
    initialRoute = AppRoutes.home;
  }

  runApp(MyApp(initialTheme: savedTheme, initialRoute: initialRoute));
  DeepLinkService.instance.init();
}

// ─── App Widget ────────────────────────────────────────────────────────────
class MyApp extends StatefulWidget {
  final String initialTheme;
  final String initialRoute;
  const MyApp({
    super.key,
    required this.initialTheme,
    required this.initialRoute,
  });

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
    return GetMaterialApp(
      title: 'ÇOMÜ TV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: widget.initialTheme == 'light'
          ? ThemeMode.light
          : ThemeMode.dark,
      initialRoute: widget.initialRoute,
      getPages: AppPages.pages,
      // WEB: mouse (ve trackpad) ile tutup sürükleyerek kaydırmayı aktif
      // eder; Material ayrıca masaüstünde otomatik scrollbar ekler.
      scrollBehavior: const AppScrollBehavior(),
      builder: (context, child) {
        return Column(
          children: [
            Obx(
              () => ConnectivityService.instance.isOnline.value
                  ? const SizedBox.shrink()
                  : Material(
                      color: Colors.red.shade700,
                      child: const SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Center(
                            child: Text(
                              'İnternet bağlantısı yok',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            Expanded(
              // WEB: Ctrl+K (macOS'ta ⌘K) arama sekmesini açar — web bar'daki
              // "⌘K" rozetinin gerçek karşılığı. Fokus nerede olursa olsun
              // çalışır (kısayol, navigator'ın üstünde yakalanır).
              child: CallbackShortcuts(
                bindings: const <SingleActivator, VoidCallback>{
                  SingleActivator(LogicalKeyboardKey.keyK, control: true):
                      _openSearchViaShortcut,
                  SingleActivator(LogicalKeyboardKey.keyK, meta: true):
                      _openSearchViaShortcut,
                },
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _openSearchViaShortcut() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().changeTab(3);
    } else {
      Get.toNamed('/search');
    }
  }
}
