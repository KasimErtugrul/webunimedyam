// lib/core/utils/external_navigation.dart
//
// Bildirim ve deep link gibi "dışarıdan" gelen yönlendirmeler için ortak
// yardımcı. Amaç: Kullanıcıyı player'a götürürken, altında geri tuşuyla
// dönülecek bir ANA SAYFA olmasını sağlamak — ama Ana Sayfa zaten yığındaysa
// onu ASLA yeniden kurmamak.
//
// KÖK NEDEN (bildirimden sonra ana sayfanın boş kalması):
//   Önceden her seferinde `Get.offAll(() => HomeScreen(), binding: HomeBinding())`
//   çağrılıyordu. Ana Sayfa zaten açıkken bu, ikinci bir HomeScreen kuruyor:
//     1) Yeni rota build olurken HomeBinding çalışıyor ama tüm controller'lar
//        zaten kayıtlı (Get.isRegistered == true) olduğundan hiçbir şey yapmıyor.
//        Yeni ekran ESKİ HomeController örneğini yakalıyor
//        (`late final controller = Get.find<HomeController>()`).
//     2) Ardından ESKİ rota dispose oluyor ve GetX, o rotaya bağlı
//        HomeController/FeedController/... örneklerini siliyor (fenix olduğu
//        için kayıt kalıyor, örnek sıfırlanıyor).
//     3) Sonraki her `Get.find<FeedController>()` YENİ, boş bir FeedController
//        üretiyor. Ama ekrandaki Obx'ler ESKİ FeedController'ın Rx
//        değişkenlerine abone kalıyor; HomeController.onReady da yeni örnek
//        için bir daha çalışmadığından ilk yükleme hiç tetiklenmiyor.
//   Sonuç: Liste boş, pull-to-refresh yeni controller'ı dolduruyor ama UI
//   eskisini dinlediği için hiçbir şey görünmüyor, filtre çipi değişmiyor.
//
// ÇÖZÜM: Ana Sayfa yığındaysa sadece ona kadar pop edip player'ı üstüne itiyoruz.
// Ana Sayfa yığında değilse (ör. login ekranı) eskisi gibi offAll ile kuruyoruz —
// bu durumda çakışan eski bir Home örneği olmadığı için sorun yok.


import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/bindings/home_binding.dart';
import '../../app/routes/app_routes.dart';
import '../../presentation/screens/home/home_screen.dart';

/// HomeScreen şu an widget ağacında mı? (HomeScreen state'i init/dispose'ta
/// günceller.) `Get.isRegistered<HomeController>()` bunun için GÜVENİLİR
/// DEĞİL: fenix yüzünden rota kapandıktan sonra da true dönebilir.
class HomeScreenPresence {
  HomeScreenPresence._();
  static int _count = 0;

  static bool get isMounted => _count > 0;
  static void attach() => _count++;
  static void detach() {
    if (_count > 0) _count--;
  }
}

class ExternalNavigation {
  ExternalNavigation._();

  /// Player'ı açar; altında Ana Sayfa bulunmasını garanti eder.
  static Future<void> openPlayer({
    required String videoId,
    Object? arguments,
  }) async {
    // Navigator henüz hazır değilse (soğuk açılış) kısa aralıklarla bekle.
    for (var attempt = 0; Get.key.currentState == null; attempt++) {
      if (attempt >= 20) return; // ~4 sn sonra vazgeç
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (HomeScreenPresence.isMounted) {
      // Ana Sayfa zaten yığında: YENİDEN KURMA, sadece üstündekileri kapat.
      Get.until(
        (route) => route.settings.name == AppRoutes.home || route.isFirst,
      );
    } else {
      // Ana Sayfa yığında yok: sıfırdan kur. Dönen Future'ı await ETME
      // (rota pop edilene kadar tamamlanmaz), sonraki frame'i bekle.
      Get.offAll(
        () => const HomeScreen(),
        binding: HomeBinding(),
        routeName: AppRoutes.home,
        transition: Transition.noTransition,
        duration: Duration.zero,
      );
      await WidgetsBinding.instance.endOfFrame;
    }

    Get.toNamed(
      AppRoutes.player,
      arguments: arguments,
      parameters: {'videoId': videoId},
    );
  }
}
