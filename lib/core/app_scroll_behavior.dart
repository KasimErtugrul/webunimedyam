// lib/core/app_scroll_behavior.dart
//
// Uygulama geneli scroll davranışı.
//
// Flutter, varsayılan olarak sadece dokunmatik girdilerle "sürükleerek
// kaydırma"ya izin verir; masaüstünde mouse ile bir listeyi tutup
// sürüklemek çalışmaz (mouse'da yalnızca tekerlek/trackpad beklenir).
// Web sitesi olduğu için mouse ile sürükleme beklentisi yüksektir —
// bu yüzden mouse (ve trackpad/stylus) dragDevices kümesine eklenir.
// Böylece yatay carousel'lar, video grid'leri ve dikey listeler
// mouse ile tutup sürükleyerek kaydırılabilir.
//
// Kullanım: GetMaterialApp.scrollBehavior (bkz. main.dart).

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };
}
