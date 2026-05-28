import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // screenutil eklendi
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_theme.dart';
import 'data/datasources/local/local_datasource.dart';
import 'data/datasources/remote/supabase_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ftqjpfqzjuthoifkyqgl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0cWpwZnF6anV0aG9pZmt5cWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTM1ODAsImV4cCI6MjA5NDE4OTU4MH0.gkI3QgT7JhPA-IzVQm0805kmpJMhCwhLpcJBYtv6K40',
  );

  // Kaydedilmis temaya gore baslat
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme') ?? 'dark';

  // screenutil başlatma - uygulama başlamadan önce ekran ölçekleme ayarları
  await ScreenUtil.ensureScreenSize(); // Gerçek ekran boyutlarını almak için
  Get.put<SupabaseDataSource>(SupabaseDataSource(), permanent: true);
  Get.put<LocalDataSource>(LocalDataSource(), permanent: true);
  Get.put<AuthRepository>(
    AuthRepository(supabase: Get.find(), local: Get.find()),
    permanent: true,
  );

  await Get.putAsync<SettingsController>(() async {
    final ctrl = SettingsController(authRepository: Get.find());
    await ctrl.loadSettings();
    return ctrl;
  }, permanent: true);

  runApp(MyApp(initialTheme: savedTheme));
}

class MyApp extends StatelessWidget {
  final String initialTheme;
  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit ile tüm widget ağacını sarmalıyoruz
    return ScreenUtilInit(
      // Tasarım yapılırken kullanılan referans ekran boyutu (genellikle iPhone 11/12/13)
      designSize: const Size(375, 812),
      // Min text scale factor (opsiyonel)
      minTextAdapt: true,
      // Ekran döndüğünde yeniden ölçeklendirme
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
