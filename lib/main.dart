// lib/main.dart

import 'dart:async';
import 'dart:developer';
import 'dart:io' as io;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'services/connectivity_service.dart';

import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_theme.dart';
import 'data/datasources/local/app_cache_box.dart';
import 'data/datasources/local/local_datasource.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/controllers/settings_controller.dart';
import 'services/analytics_service.dart';
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
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    // BUG FIX: youtube_player_iframe paketi, WebView içindeki YouTube iframe'i
    // JS köprüsü 30 saniye içinde "hazır" sinyali vermezse (kötü/kopuk internet,
    // WebView'in embed'i geç açması vb.) kendi içinde bir TimeoutException
    // fırlatıyor. Bu Future bizim kodumuzun dışında olduğundan try-catch ile
    // yakalanamıyor ve buraya "fatal" olarak düşüyor; oysa bu uygulamayı
    // gerçekten çökertmiyor, sadece video oynatıcı açılamıyor. Bu durumu
    // ayırt edip fatal olmayan bir hata olarak kaydediyoruz ki Crashlytics'teki
    // "fatal crash" oranımız bu paket kaynaklı, aslında kurtarılabilir
    // durumlarla şişmesin.
    final isYoutubePlayerInitTimeout =
        error is TimeoutException &&
        stack.toString().contains('js_bridge.dart');

    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: !isYoutubePlayerInitTimeout,
      reason: isYoutubePlayerInitTimeout ? 'youtube_player_init_timeout' : null,
    );
    return true;
  };

  await ConnectivityService.init();

  // ── Supabase ──────────────────────────────────────────────────────────────
  await Supabase.initialize(
    url: 'https://ftqjpfqzjuthoifkyqgl.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0cWpwZnF6anV0aG9pZmt5cWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTM1ODAsImV4cCI6MjA5NDE4OTU4MH0.gkI3QgT7JhPA-IzVQm0805kmpJMhCwhLpcJBYtv6K40',
  );

  // ── Analytics ──────────────────────────────────────────────────────────────
  // Supabase init'ten SONRA çağrılmalı: auth durumunu okuyup auth_status
  // user property'sini set ediyor, sonra her login/logout'ta otomatik günceller.
  await AnalyticsService.instance.initialize();

  // ── Hive (local cache) ────────────────────────────────────────────────────
  // NOT: SharedPreferences'tan geçiş — tüm local cache tek bir Hive box'ında
  // tutuluyor. Box uygulama boyunca açık kalır (main dışında bir daha
  // Hive.openBox çağrılmaz), diğer katmanlar AppCacheBox.instance ile
  // senkron erişir.
  await Hive.initFlutter();
  await Hive.openBox(AppCacheBox.name);

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
    final onboardingCompleted = await Get.find<AuthRepository>()
        .isOnboardingCompleted();
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
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Uni TV',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: widget.initialTheme == 'light'
              ? ThemeMode.light
              : ThemeMode.dark,
          initialRoute: widget.initialRoute,
          getPages: AppPages.pages,
          navigatorObservers: [AnalyticsService.instance.observer],
          builder: (context, child) {
            return Column(
              children: [
                Obx(
                  () => ConnectivityService.instance.isOnline.value
                      ? const SizedBox.shrink()
                      : Material(
                          color: Colors.red.shade700,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Center(
                                child: Text(
                                  'İnternet bağlantısı yok',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            );
          },
        );
      },
    );
  }
}
