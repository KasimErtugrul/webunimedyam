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

import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../core/constants/app_links.dart';

class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    // Uygulama bir link ile SIFIRDAN açıldıysa (cold start).
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handle(initial);
    } catch (e, st) {
      log('Deep link (initial) okunurken hata: $e', error: e, stackTrace: st);
    }

    // Uygulama zaten açıkken bir link ile tetiklenirse (warm start).
    _sub = _appLinks.uriLinkStream.listen(
      _handle,
      onError: (e, st) => log('Deep link stream hatası: $e', error: e),
    );
  }

  void dispose() => _sub?.cancel();

  void _handle(Uri uri) {
    final videoId = _extractVideoId(uri);
    if (videoId == null || videoId.isEmpty) return;
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

  void _navigateToPlayer(String videoId, {int attempt = 0}) {
    // GetMaterialApp'in navigator'ı henüz hazır değilse (uygulama daha
    // yeni açılıyorsa) birkaç kez kısa aralıklarla tekrar dener.
    if (Get.key.currentState == null) {
      if (attempt >= 20) return; // ~4 saniye sonra vazgeç
      Future.delayed(
        const Duration(milliseconds: 200),
        () => _navigateToPlayer(videoId, attempt: attempt + 1),
      );
      return;
    }

    // Önce ana sayfa, üstüne player — geri tuşu ana sayfaya dönsün diye.
    Get.offAllNamed(AppRoutes.home);
    Get.toNamed(AppRoutes.player, parameters: {'videoId': videoId});
  }
}
