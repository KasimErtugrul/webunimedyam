// lib/services/deep_link_service.dart
//
// İki tür derin bağlantıyı dinler ve uygulamayı doğrudan ilgili videonun
// player ekranına yönlendirir:
//
//   1) https://{VideoLinkConfig.webHost}/video/{videoId}  (App Links / Universal
//      Links — WhatsApp gibi uygulamalarda TIKLANABİLİR olan, paylaşımda
//      kullanılan asıl link. bkz. share_helper.dart)
//   2) unitv://video/{videoId}  (eski özel şema — geriye dönük uyumluluk
//      için hâlâ dinleniyor, ama artık paylaşımda KULLANILMIYOR çünkü
//      üçüncü parti uygulamalar bunu tıklanabilir hale getirmiyor)
//
// Davranış: her zaman önce ANA SAYFA'ya, sonra üstüne PLAYER ekranına
// gidilir (Get.offAllNamed + Get.toNamed). Böylece player ekranındayken
// geri tuşuna basıldığında kullanıcı ana sayfaya döner.
//
// ─────────────────────────────────────────────────────────────────────
// GEÇİCİ DEBUG ARAÇLARI EKLENDİ (debugSnack çağrıları) — deep link
// akışının hangi adımda takıldığını adb/logcat olmadan, doğrudan
// ekranda görmek için. Sorun çözüldükten sonra tüm debugSnack(...)
// satırlarını ve import'unu kaldır.
// ─────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../app/bindings/home_binding.dart';
import '../app/routes/app_routes.dart';
import '../core/constants/app_links.dart';
import '../core/utils/debug_snack.dart'; // ← GEÇİCİ DEBUG
import '../presentation/screens/home/home_screen.dart';

class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  // BUG FIX: app_links paketinde, uygulama SOĞUK BAŞLATILDIĞINDA (cold
  // start) hem `getInitialLink()` hem de `uriLinkStream` AYNI URI'yi
  // yayınlıyor. Bu yüzden aşağıdaki init() akışında bir linke tıklanarak
  // uygulama sıfırdan açıldığında `_handle()` İKİ KEZ çağrılıyordu:
  // bir kez getInitialLink() sonucunda, bir kez de stream'in ilk emisyonunda.
  // Sonuç: _navigateToPlayer() iki kez tetikleniyor → Get.offAllNamed +
  // Get.toNamed çifti art arda iki kez çalışıyor → gereksiz/duplicate
  // navigator işlemleri, PlayerController'ın videoyu iki kez yüklemesi ve
  // geri tuşunda beklenmedik davranış.
  //
  // Çözüm: son işlenen URI'yi (ve işlendiği zamanı) hatırlayıp, kısa bir
  // pencere içinde gelen birebir aynı URI'yi yok sayıyoruz.
  Uri? _lastHandledUri;
  DateTime? _lastHandledAt;
  static const _dedupeWindow = Duration(seconds: 2);

  Future<void> init() async {
    debugSnack('init() başladı'); // GEÇİCİ DEBUG

    // Uygulama bir link ile SIFIRDAN açıldıysa (cold start).
    Uri? initial;
    try {
      initial = await _appLinks.getInitialLink();
      debugSnack(
        // GEÇİCİ DEBUG
        initial != null
            ? 'getInitialLink() -> $initial'
            : 'getInitialLink() -> NULL (uygulama linksiz açıldı ya da native intent verisi Dart\'a hiç ulaşmadı)',
      );
    } catch (e, st) {
      debugSnack('getInitialLink() HATA fırlattı: $e'); // GEÇİCİ DEBUG
      log('Deep link (initial) okunurken hata: $e', error: e, stackTrace: st);
    }

    if (initial != null) _handle(initial);

    // Uygulama zaten açıkken bir link ile tetiklenirse (warm start).
    // NOT: cold start durumunda bu stream, yukarıda getInitialLink() ile
    // zaten işlediğimiz AYNI URI'yi de bir kez daha yayınlayabilir —
    // bu yüzden _handle() içindeki dedupe kontrolü bu tekrarı süzer.
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        debugSnack('uriLinkStream emisyonu -> $uri'); // GEÇİCİ DEBUG
        _handle(uri);
      },
      onError: (e, st) {
        debugSnack('uriLinkStream HATA: $e'); // GEÇİCİ DEBUG
        log('Deep link stream hatası: $e', error: e);
      },
    );
  }

  void dispose() => _sub?.cancel();

  void _handle(Uri uri) {
    // Aynı URI, kısa bir süre içinde tekrar geldiyse (getInitialLink +
    // uriLinkStream çakışması) yok say.
    final now = DateTime.now();
    if (_lastHandledUri == uri &&
        _lastHandledAt != null &&
        now.difference(_lastHandledAt!) < _dedupeWindow) {
      debugSnack('_handle: DEDUPE ile atlandı -> $uri'); // GEÇİCİ DEBUG
      return;
    }

    final videoId = _extractVideoId(uri);
    debugSnack(
      // GEÇİCİ DEBUG
      (videoId == null || videoId.isEmpty)
          ? '_extractVideoId -> BULUNAMADI (uri host/path eşleşmedi). uri.scheme=${uri.scheme}, uri.host=${uri.host}, uri.pathSegments=${uri.pathSegments}'
          : '_extractVideoId -> "$videoId" (navigasyon başlıyor)',
    );

    if (videoId == null || videoId.isEmpty) return;

    _lastHandledUri = uri;
    _lastHandledAt = now;
    _navigateToPlayer(videoId);
  }

  // Beklenen formatlar:
  //   https://{webHost}/video/{videoId}  (App Links / Universal Links)
  //   unitv://video/{videoId}            (eski özel şema)
  String? _extractVideoId(Uri uri) {
    final isCustomScheme =
        uri.scheme == VideoLinkConfig.customScheme &&
        uri.host == VideoLinkConfig.videoPathSegment;
    if (isCustomScheme) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    final isWebLink =
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == VideoLinkConfig.webHost &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == VideoLinkConfig.videoPathSegment;
    if (isWebLink) {
      return uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    }

    return null;
  }

  Future<void> _navigateToPlayer(String videoId, {int attempt = 0}) async {
    // GetMaterialApp'in navigator'ı henüz hazır değilse (uygulama daha
    // yeni açılıyorsa) birkaç kez kısa aralıklarla tekrar dener.
    if (Get.key.currentState == null) {
      if (attempt >= 20) {
        debugSnack(
          // GEÇİCİ DEBUG
          '_navigateToPlayer("$videoId"): navigator 4sn sonra hâlâ hazır değil, VAZGEÇİLDİ',
        );
        return; // ~4 saniye sonra vazgeç
      }
      await Future.delayed(const Duration(milliseconds: 200));
      return _navigateToPlayer(videoId, attempt: attempt + 1);
    }

    debugSnack(
      // GEÇİCİ DEBUG
      '_navigateToPlayer("$videoId") -> Get.offAll(Home) çağrılıyor (attempt=$attempt)',
    );

    // BUG FIX: offAllNamed() tamamlanmadan toNamed() çağrılırsa navigator
    // işlemleri yarışabiliyordu (özellikle geçiş animasyonları sürerken).
    // Bu yüzden ana sayfaya geçişin bitmesini bekleyip ANCAK ONDAN SONRA
    // player'a gidiyoruz — geri tuşu davranışı (ana sayfaya dönme) aynı
    // kalıyor.
    //
    // BUG FIX 2 (asıl şikayet): `Get.offAllNamed` awaitlendiğinde, o
    // rotanın GetPage'inde tanımlı VARSAYILAN geçiş animasyonu (~300ms)
    // sonuna kadar oynatılıyor — yani ana sayfa gerçekten ekranda render
    // olup GÖRÜNÜYOR, ancak ondan SONRA player açılıyor. Kullanıcı
    // WhatsApp'tan linke bastığında "önce ana sayfa açılıyor, sonra
    // player'a geçiyor" olarak algıladığı şey tam olarak bu.
    //
    // Çözüm: ana sayfaya geçişi ANİMASYONSUZ (Transition.noTransition,
    // duration: Duration.zero) yapıyoruz. Böylece ana sayfa yine yığının
    // (back stack) en altına, tam olarak aynı şekilde yerleşiyor — geri
    // tuşu davranışı değişmiyor — ama görsel olarak hiç "flash" etmiyor;
    // kullanıcı uygulamayı doğrudan player ekranında açılmış gibi görüyor.
    // `routeName` parametresi, adsız (anonymous) bir widget push'u
    // kullanmamıza rağmen rota adının hâlâ AppRoutes.home olarak
    // kaydedilmesini sağlıyor (analytics observer ve Get.currentRoute
    // gibi isme dayalı mekanizmalar etkilenmesin diye).
    await Get.offAll(
      () => const HomeScreen(),
      binding: HomeBinding(),
      routeName: AppRoutes.home,
      transition: Transition.noTransition,
      duration: Duration.zero,
    );

    debugSnack(
      // GEÇİCİ DEBUG
      'Get.offAll TAMAMLANDI -> Get.toNamed(AppRoutes.player, videoId: "$videoId") çağrılıyor',
    );
    Get.toNamed(AppRoutes.player, parameters: {'videoId': videoId});
  }
}