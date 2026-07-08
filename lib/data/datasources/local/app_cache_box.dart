// lib/data/datasources/local/app_cache_box.dart

import 'package:hive_ce/hive.dart';

/// Uygulama genelinde kullanılan tek Hive box'ı.
///
/// main.dart içinde uygulama açılırken bir kez `Hive.openBox(AppCacheBox.name)`
/// ile açılır. Açıldıktan sonra box senkron çalışır — SharedPreferences'taki
/// gibi her çağrıda `await SharedPreferences.getInstance()` beklemeye
/// gerek kalmaz, direkt `AppCacheBox.instance.get(...)` / `.put(...)` kullanılır.
class AppCacheBox {
  AppCacheBox._();

  static const String name = 'comutv_cache';

  static Box get instance => Hive.box(name);
}