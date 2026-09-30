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
// gidilir (Get.offAll + Get.toNamed). Böylece player ekranındayken geri
// tuşuna basıldığında kullanıcı ana sayfaya döner.

import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/constants/app_links.dart';
import '../core/utils/external_navigation.dart';

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
  // Sonuç: _navigateToPlayer() iki kez tetikleniyor → Get.offAll +
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
    // Uygulama bir link ile SIFIRDAN açıldıysa (cold start).
    Uri? initial;
    try {
      initial = await _appLinks.getInitialLink();
    } catch (e, st) {
      log('Deep link (initial) okunurken hata: $e', error: e, stackTrace: st);
    }

    if (initial != null) _handle(initial);

    // Uygulama zaten açıkken bir link ile tetiklenirse (warm start).
    // NOT: cold start durumunda bu stream, yukarıda getInitialLink() ile
    // zaten işlediğimiz AYNI URI'yi de bir kez daha yayınlayabilir —
    // bu yüzden _handle() içindeki dedupe kontrolü bu tekrarı süzer.
    _sub = _appLinks.uriLinkStream.listen(
      _handle,
      onError: (e, st) {
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
      return;
    }

    final videoId = _extractVideoId(uri);
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

  Future<void> _navigateToPlayer(String videoId) async {
    // Ana Sayfa zaten açıksa yeniden kurulmaz (bkz. external_navigation.dart).
    await ExternalNavigation.openPlayer(videoId: videoId);
  }
}