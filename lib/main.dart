import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ftqjpfqzjuthoifkyqgl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ0cWpwZnF6anV0aG9pZmt5cWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MTM1ODAsImV4cCI6MjA5NDE4OTU4MH0.gkI3QgT7JhPA-IzVQm0805kmpJMhCwhLpcJBYtv6K40',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ÇOMÜ TV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
